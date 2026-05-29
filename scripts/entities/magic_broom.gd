extends CharacterBody2D
## MagicBroom - Sweeps the room, pushes Freddy, prioritizes cleaning paw prints.

class_name MagicBroom

enum BroomState { IDLE, CHASE_FREDDY, CLEAN_PRINTS }

const BASE_SPEED: float = 180.0
const PUSH_FORCE: Vector2 = Vector2(400, -200)
const CLEAN_RADIUS: float = 20.0

var current_state: BroomState = BroomState.CHASE_FREDDY
var speed: float = BASE_SPEED
var target_player: CharacterBody2D = null
var paw_prints: Array[Vector2] = []


func _ready() -> void:
	speed = BASE_SPEED * DifficultyManager.get_param("broom_speed")


func _physics_process(delta: float) -> void:
	if paw_prints.size() > 0:
		_state_clean_prints(delta)
	elif target_player:
		_state_chase(delta)
	else:
		velocity = Vector2.ZERO

	move_and_slide()


func _state_chase(delta: float) -> void:
	current_state = BroomState.CHASE_FREDDY
	if not target_player:
		return

	var direction: Vector2 = (target_player.position - position).normalized()
	velocity = direction * speed * 0.7  # Slower when chasing


func _state_clean_prints(_delta: float) -> void:
	current_state = BroomState.CLEAN_PRINTS
	if paw_prints.size() == 0:
		return

	var target: Vector2 = paw_prints[0]
	var direction: Vector2 = (target - position).normalized()
	velocity = direction * speed

	if position.distance_to(target) < CLEAN_RADIUS:
		paw_prints.pop_front()
		AudioManager.play_sfx("broom_sweep")


func add_paw_print(pos: Vector2) -> void:
	paw_prints.append(pos)
	if paw_prints.size() > 20:
		paw_prints.pop_front()


func push_player(player: CharacterBody2D) -> void:
	if player is Freddy:
		var push: Vector2 = PUSH_FORCE
		if player.position.x < position.x:
			push.x = -abs(push.x)
		player.velocity = push
