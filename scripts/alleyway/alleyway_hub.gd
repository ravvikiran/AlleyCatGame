extends Node2D
## AlleywayHub - The central hub scene with three vertical levels.
## Manages spawning, window access, and hazard coordination.

var _player: CharacterBody2D
var _touch_controller: CanvasLayer
var _window_manager: Node
var _hazard_spawner: Node

const SPAWN_POSITION: Vector2 = Vector2(960, 800)


func _ready() -> void:
	_player = $Freddy
	_touch_controller = $UILayer/TouchController
	_window_manager = $WindowManager
	_hazard_spawner = $HazardSpawner

	# Connect touch controller to player
	if _touch_controller:
		_touch_controller.move_input.connect(_on_move_input)
		_touch_controller.jump_pressed.connect(_on_jump_pressed)
		_touch_controller.action_pressed.connect(_on_action_pressed)
		_touch_controller.action_held.connect(_on_action_held)
		_touch_controller.drop_requested.connect(_on_drop_requested)
		_touch_controller.hide_action_button()

	# Setup player
	if _player:
		_player.position = SPAWN_POSITION

	# Setup window manager
	if _window_manager and _window_manager.has_signal("window_entered"):
		_window_manager.window_entered.connect(_on_window_entered)

	# Setup hazards based on difficulty
	if _hazard_spawner and _hazard_spawner.has_method("setup"):
		_hazard_spawner.setup(DifficultyManager.current_tier)

	# Play alleyway music
	AudioManager.play_music("alleyway")

	# Check if Felicia window should be active
	if GameManager.felicia_window_active:
		if _window_manager and _window_manager.has_method("activate_felicia_window"):
			_window_manager.activate_felicia_window()


func _on_move_input(direction: Vector2) -> void:
	if _player:
		_player.input_direction = direction


func _on_jump_pressed() -> void:
	if _player:
		_player.is_jump_pressed = true
		get_tree().create_timer(0.05).timeout.connect(_reset_jump)


func _reset_jump() -> void:
	if _player:
		_player.is_jump_pressed = false


func _on_action_pressed() -> void:
	if _player:
		_player.is_action_pressed = true


func _on_action_held(duration: float) -> void:
	if _player:
		_player.action_hold_duration = duration


func _on_drop_requested() -> void:
	pass


func _on_window_entered(window_type: String) -> void:
	if window_type == "felicia":
		GameManager.change_state(GameManager.GameState.LOVE_GAME)
	else:
		var minigame: GameManager.GameState = GameManager.get_random_minigame()
		GameManager.change_state(minigame)
