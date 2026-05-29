extends MinigameRoomBase
## BirdcageRoom - Push birdcage off table, then catch the escaped bird.
## Two phases: PUSH (move cage to edge) and CHASE (catch bird with sine-wave flight).

const PUSH_FORCE: float = 150.0  # pixels per impact
const TABLE_LEFT_X: float = 700.0
const TABLE_RIGHT_X: float = 1200.0
const BIRD_H_SPEED: float = 200.0
const BIRD_AMPLITUDE: float = 60.0
const BIRD_FREQUENCY: float = 2.0
const BIRD_DIRECTION_CHANGE_MIN: float = 1.5
const BIRD_DIRECTION_CHANGE_MAX: float = 3.0

enum Phase { PUSH, CHASE }

var _phase: Phase = Phase.PUSH
var _cage_x: float = 950.0  # Center of table
var _bird_position: Vector2 = Vector2.ZERO
var _bird_direction: float = 1.0
var _bird_time: float = 0.0
var _bird_change_timer: float = 0.0
var _bird_change_interval: float = 2.0


func _ready() -> void:
	objective_count = 1
	has_magic_broom = true
	has_running_dog = true
	super._ready()

	# Hide action button (not needed)
	var touch: CanvasLayer = $UILayer/TouchController
	if touch:
		touch.hide_action_button()

	_phase = Phase.PUSH


func _physics_process(delta: float) -> void:
	super._physics_process(delta)

	match _phase:
		Phase.PUSH:
			_update_push_phase(delta)
		Phase.CHASE:
			_update_chase_phase(delta)


func _update_push_phase(_delta: float) -> void:
	# Check if player is pushing the cage
	if _player and _player.is_on_floor():
		var player_x: float = _player.position.x
		var cage_left: float = _cage_x - 30
		var cage_right: float = _cage_x + 30

		# Player walking into cage from left
		if player_x > cage_left - 40 and player_x < cage_left and _player.velocity.x > 0:
			_cage_x += PUSH_FORCE * get_physics_process_delta_time()

		# Player walking into cage from right
		elif player_x < cage_right + 40 and player_x > cage_right and _player.velocity.x < 0:
			_cage_x -= PUSH_FORCE * get_physics_process_delta_time()

	# Check if cage fell off table
	if _cage_x > TABLE_RIGHT_X or _cage_x < TABLE_LEFT_X:
		_free_bird()


func _free_bird() -> void:
	_phase = Phase.CHASE
	AudioManager.play_sfx("vase_break")  # Cage breaking sound

	# Bird starts at cage position
	_bird_position = Vector2(_cage_x, 300)
	_bird_direction = 1.0 if randf() > 0.5 else -1.0
	_bird_time = 0.0
	_bird_change_interval = randf_range(BIRD_DIRECTION_CHANGE_MIN, BIRD_DIRECTION_CHANGE_MAX)
	_bird_change_timer = 0.0


func _update_chase_phase(delta: float) -> void:
	_bird_time += delta
	_bird_change_timer += delta

	# Sine-wave flight pattern
	_bird_position.x += BIRD_H_SPEED * _bird_direction * delta
	_bird_position.y = 250.0 + sin(_bird_time * BIRD_FREQUENCY * TAU) * BIRD_AMPLITUDE

	# Bounce off screen edges
	if _bird_position.x > 1800 or _bird_position.x < 120:
		_bird_direction *= -1

	# Random direction change
	if _bird_change_timer >= _bird_change_interval:
		_bird_change_timer = 0.0
		_bird_change_interval = randf_range(BIRD_DIRECTION_CHANGE_MIN, BIRD_DIRECTION_CHANGE_MAX)
		_bird_direction *= -1

	# Check if Freddy caught the bird
	if _player.position.distance_to(_bird_position) < 50.0:
		_catch_bird()


func _catch_bird() -> void:
	AudioManager.play_sfx("catch_mouse")
	on_objective_completed()
