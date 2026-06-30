extends Node2D
## MinigameRoomBase - Abstract base class for all five minigame rooms.
## Handles objective tracking, time bonus, Magic Broom, and Running Dog.

class_name MinigameRoomBase

signal room_completed()
signal objective_progressed(current: int, total: int)

@export var objective_count: int = 1
@export var time_limit: float = 120.0  # seconds for time bonus calculation
@export var has_magic_broom: bool = true
@export var has_running_dog: bool = false

var objectives_completed: int = 0
var elapsed_time: float = 0.0
var is_complete: bool = false

var _player: Freddy
var _magic_broom: Node2D
var _running_dog: CharacterBody2D
var _paw_prints: Array[Vector2] = []


func _ready() -> void:
	_player = get_node_or_null("Freddy") as Freddy
	_setup_player()
	_setup_broom()
	_setup_dog()
	AudioManager.play_music("minigame")


func _process(delta: float) -> void:
	if not is_complete:
		elapsed_time += delta
		_update_paw_prints()


func _setup_player() -> void:
	if not _player:
		push_warning("MinigameRoomBase: No Freddy node found in scene.")
		return
	_player.died.connect(_on_player_death)
	# Connect touch controller
	var touch: CanvasLayer = get_node_or_null("UILayer/TouchController")
	if touch:
			touch.move_input.connect(func(dir): _player.input_direction = dir)
			touch.jump_pressed.connect(func(): 
				_player.is_jump_pressed = true
				get_tree().create_timer(0.05).timeout.connect(func(): _player.is_jump_pressed = false)
			)
			touch.action_pressed.connect(_on_action_pressed)
			touch.action_held.connect(func(d): _player.action_hold_duration = d)


func _setup_broom() -> void:
	if not has_magic_broom:
		return

	# Create Magic Broom entity
	_magic_broom = _create_magic_broom()
	add_child(_magic_broom)


func _setup_dog() -> void:
	if not has_running_dog:
		return

	_running_dog = _create_running_dog()
	add_child(_running_dog)


func on_objective_completed() -> void:
	objectives_completed += 1
	objective_progressed.emit(objectives_completed, objective_count)

	if objectives_completed >= objective_count:
		_complete_room()


func _complete_room() -> void:
	is_complete = true
	room_completed.emit()

	# Calculate time bonus
	var time_remaining: float = maxf(0.0, time_limit - elapsed_time)
	ScoreManager.award_points(ScoreManager.ScoreEvent.MINIGAME_COMPLETE)
	ScoreManager.award_time_bonus(time_remaining)

	# Transition back to alleyway
	GameManager.complete_minigame()


func _on_player_death() -> void:
	# Handled by Freddy's dead state → GameManager.lose_life()
	pass


func _on_action_pressed() -> void:
	# Override in subclasses for room-specific action
	pass


# --- Magic Broom AI ---

func _create_magic_broom() -> Node2D:
	var broom := CharacterBody2D.new()
	broom.name = "MagicBroom"
	broom.set_meta("state", "chase")  # chase or clean
	broom.set_meta("speed", 180.0 * DifficultyManager.get_param("broom_speed"))
	broom.set_meta("push_force", Vector2(400, -200))

	# Visual from VisualFactory
	var visual: Node2D = VisualFactory.create_entity_visual("magic_broom", Color(0.6, 0.4, 0.2), Vector2(20, 70))
	broom.add_child(visual)

	var collision := CollisionShape2D.new()
	var shape := RectangleShape2D.new()
	shape.size = Vector2(30, 80)
	collision.shape = shape
	broom.add_child(collision)

	var hitbox := Area2D.new()
	hitbox.name = "Hitbox"
	hitbox.monitoring = true
	var hb_col := CollisionShape2D.new()
	hb_col.shape = shape.duplicate()
	hitbox.add_child(hb_col)
	hitbox.body_entered.connect(_on_broom_hit_player)
	broom.add_child(hitbox)

	broom.position = Vector2(1600, 500)
	return broom


func _process_broom(delta: float) -> void:
	if not _magic_broom or not is_instance_valid(_magic_broom):
		return

	var state: String = _magic_broom.get_meta("state")
	var speed: float = _magic_broom.get_meta("speed")

	if _paw_prints.size() > 0:
		# Prioritize cleaning paw prints
		_magic_broom.set_meta("state", "clean")
		var target: Vector2 = _paw_prints[0]
		var direction: Vector2 = (target - _magic_broom.position).normalized()
		_magic_broom.velocity = direction * speed
		_magic_broom.move_and_slide()

		# Clean print when close
		if _magic_broom.position.distance_to(target) < 20:
			_paw_prints.pop_front()
			AudioManager.play_sfx("broom_sweep")
	elif _player:
		# Chase Freddy
		_magic_broom.set_meta("state", "chase")
		var direction: Vector2 = (_player.position - _magic_broom.position).normalized()
		_magic_broom.velocity = direction * speed * 0.7  # Slower when chasing
		_magic_broom.move_and_slide()


func _on_broom_hit_player(body: Node2D) -> void:
	if body is Freddy and not body.is_invulnerable:
		var push: Vector2 = _magic_broom.get_meta("push_force")
		if body.position.x < _magic_broom.position.x:
			push.x = -abs(push.x)
		body.velocity = push


func _update_paw_prints() -> void:
	# Leave paw prints when Freddy walks on the floor
	if _player and _player.is_on_floor() and _player.velocity.x != 0:
		var last_print: Vector2 = _paw_prints.back() if _paw_prints.size() > 0 else Vector2(-999, -999)
		if _player.position.distance_to(last_print) > 40:
			_paw_prints.append(_player.position)
			# Cap paw prints
			if _paw_prints.size() > 20:
				_paw_prints.pop_front()


# --- Running Dog ---

func _create_running_dog() -> CharacterBody2D:
	var dog := CharacterBody2D.new()
	dog.name = "RunningDog"

	# Visual from VisualFactory
	var visual: Node2D = VisualFactory.create_entity_visual("running_dog", Color(0.8, 0.4, 0.1), Vector2(50, 30))
	dog.add_child(visual)

	var collision := CollisionShape2D.new()
	var shape := RectangleShape2D.new()
	shape.size = Vector2(60, 40)
	collision.shape = shape
	dog.add_child(collision)

	var hitbox := Area2D.new()
	hitbox.name = "Hitbox"
	hitbox.monitoring = true
	var hb_col := CollisionShape2D.new()
	hb_col.shape = shape.duplicate()
	hitbox.add_child(hb_col)
	hitbox.body_entered.connect(_on_dog_hit_player)
	dog.add_child(hitbox)

	dog.position = Vector2(-80, 550)
	dog.set_meta("speed", 250.0)
	dog.set_meta("direction", 1.0)
	return dog


func _process_dog(delta: float) -> void:
	if not _running_dog or not is_instance_valid(_running_dog):
		return

	var speed: float = _running_dog.get_meta("speed")
	var direction: float = _running_dog.get_meta("direction")
	_running_dog.position.x += speed * direction * delta

	# Reverse at screen edges
	if _running_dog.position.x > 2000:
		_running_dog.set_meta("direction", -1.0)
	elif _running_dog.position.x < -80:
		_running_dog.set_meta("direction", 1.0)


func _on_dog_hit_player(body: Node2D) -> void:
	if body is Freddy:
		body.die()


func _physics_process(delta: float) -> void:
	_process_broom(delta)
	_process_dog(delta)
