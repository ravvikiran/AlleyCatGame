extends Node
## WindowManager - Controls window open/close cycles and object throwing.

signal window_entered(window_type: String)

const WINDOW_COUNT: int = 12
const OPEN_INTERVAL_MIN: float = 2.0
const OPEN_INTERVAL_MAX: float = 5.0
const THROW_CHANCE: float = 0.4

var _windows: Array = []
var _felicia_window_index: int = -1
var _felicia_active: bool = false
var _open_timer: float = 0.0
var _next_open_interval: float = 3.0


func _ready() -> void:
	# Find window nodes from parent's Windows container
	var windows_container: Node = get_parent().get_node_or_null("Windows")
	if not windows_container:
		push_warning("WindowManager: No 'Windows' node found in parent.")
		return

	for i in range(WINDOW_COUNT):
		var window_node: Node = windows_container.get_node_or_null("Window%d" % i)
		if window_node and window_node is Area2D:
			_windows.append(window_node)
			window_node.set_meta("index", i)
			window_node.set_meta("is_open", false)
			window_node.set_meta("is_felicia", false)
			window_node.body_entered.connect(_on_window_body_entered.bind(i))

	if _windows.size() > 0:
		_next_open_interval = randf_range(OPEN_INTERVAL_MIN, OPEN_INTERVAL_MAX)
		# Open one window immediately
		_open_random_window()


func _process(delta: float) -> void:
	_open_timer += delta
	if _open_timer >= _next_open_interval:
		_open_timer = 0.0
		_next_open_interval = randf_range(OPEN_INTERVAL_MIN, OPEN_INTERVAL_MAX)
		_open_random_window()


func activate_felicia_window() -> void:
	_felicia_active = true
	if _windows.size() == 0:
		return
	_felicia_window_index = randi() % _windows.size()
	var window: Area2D = _windows[_felicia_window_index]
	window.set_meta("is_felicia", true)
	window.set_meta("is_open", true)
	# Make Felicia's window visually distinct (pink)
	var sprite: Node = window.get_node_or_null("Sprite")
	if sprite and sprite is ColorRect:
		sprite.color = Color(1.0, 0.4, 0.7, 1.0)


func _open_random_window() -> void:
	if _windows.size() == 0:
		return

	var closed_indices: Array = []
	for i in range(_windows.size()):
		var w: Area2D = _windows[i]
		if not w.get_meta("is_open") and not w.get_meta("is_felicia", false):
			closed_indices.append(i)

	if closed_indices.size() > 0:
		var idx: int = closed_indices.pick_random()
		_open_window(idx)

	_ensure_one_open()


func _open_window(index: int) -> void:
	if index >= _windows.size():
		return

	var window: Area2D = _windows[index]
	window.set_meta("is_open", true)

	# Visual: change color to indicate open
	var sprite: Node = window.get_node_or_null("Sprite")
	if sprite and sprite is ColorRect:
		sprite.color = Color(0.2, 0.2, 0.5, 1.0)

	# Maybe throw an object
	if randf() < THROW_CHANCE:
		_throw_object(window)

	# Schedule close
	var duration_min: float = DifficultyManager.get_param("window_open_duration_min")
	var duration_max: float = DifficultyManager.get_param("window_open_duration_max")
	var duration: float = randf_range(duration_min, duration_max)
	get_tree().create_timer(duration).timeout.connect(_close_window.bind(index))


func _close_window(index: int) -> void:
	if index >= _windows.size():
		return

	var window: Area2D = _windows[index]
	if window.get_meta("is_felicia", false):
		return

	window.set_meta("is_open", false)

	# Visual: darken to indicate closed
	var sprite: Node = window.get_node_or_null("Sprite")
	if sprite and sprite is ColorRect:
		sprite.color = Color(0.05, 0.05, 0.1, 1.0)

	_ensure_one_open()


func _ensure_one_open() -> void:
	for window in _windows:
		if window.get_meta("is_open"):
			return
	# None open, force one
	if _windows.size() > 0:
		_open_window(randi() % _windows.size())


func _throw_object(window: Area2D) -> void:
	var spawner: Node = get_parent().get_node_or_null("HazardSpawner")
	if spawner and spawner.has_method("spawn_thrown_object"):
		var spawn_pos: Vector2 = window.global_position + Vector2(0, 40)
		var types: Array = ["boot", "telephone", "rolling_pin"]
		spawner.spawn_thrown_object(spawn_pos, types.pick_random())


func _on_window_body_entered(body: Node2D, window_index: int) -> void:
	if not body is Freddy:
		return

	var window: Area2D = _windows[window_index]

	if not window.get_meta("is_open"):
		# Bounce off closed window
		body.velocity = Vector2(0, -200)
		return

	# Must be falling (moving downward) to enter
	if body.velocity.y <= 0:
		return

	# Enter the window
	if window.get_meta("is_felicia", false):
		window_entered.emit("felicia")
	else:
		window_entered.emit("minigame")
