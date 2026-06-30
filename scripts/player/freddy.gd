extends CharacterBody2D
## Freddy - The player-controlled cat character.
## Uses a simplified inline state machine for movement with custom physics.

class_name Freddy

signal died()
signal hurt()

# Physics constants
const GRAVITY: float = 980.0
const MAX_FALL_SPEED: float = 600.0
const WALK_SPEED: float = 200.0
const RUN_SPEED: float = 350.0
const STANDING_JUMP_VELOCITY: float = -450.0
const RUNNING_JUMP_VELOCITY: float = -520.0
const RUNNING_JUMP_H_BOOST: float = 1.4
const CLIMB_SPEED: float = 150.0
const SWIM_MAX_SPEED: float = 250.0
const SWIM_ACCELERATION: float = 400.0
const SWIM_DRAG: float = 0.92
const RUN_THRESHOLD_TIME: float = 0.3

enum PlayerState {
	IDLE, WALK, RUN, JUMP, FALL, HANG, CLIMB, SWIM, ACTION, HURT, DEAD
}

var current_state: PlayerState = PlayerState.IDLE
var input_direction: Vector2 = Vector2.ZERO
var is_jump_pressed: bool = false
var is_action_pressed: bool = false
var action_hold_duration: float = 0.0
var facing_right: bool = true
var move_time: float = 0.0
var is_invulnerable: bool = false
var near_hangable: bool = false

var _hurt_timer: float = 0.0
var _dead_timer: float = 0.0
var _action_timer: float = 0.0
var _invuln_timer: float = 0.0

# Visual
@onready var _sprite: Node = _find_visual()


func _ready() -> void:
	add_to_group("player")
	# Replace ColorRect placeholder with proper visual if available
	_upgrade_visual()


func _find_visual() -> Node:
	# Find any visual child (ColorRect, Sprite2D, or AnimatedSprite2D)
	for child in get_children():
		if child is ColorRect or child is Sprite2D or child is AnimatedSprite2D:
			return child
	return null


func _upgrade_visual() -> void:
	## Replace the placeholder ColorRect with a proper visual from VisualFactory.
	if not is_instance_valid(VisualFactory):
		return
	var new_visual: Node2D = VisualFactory.create_freddy_visual()
	if new_visual:
		# Remove old ColorRect placeholder
		var old_visual := _find_visual()
		if old_visual and old_visual is ColorRect:
			old_visual.queue_free()
		add_child(new_visual)
		_sprite = new_visual


func _physics_process(delta: float) -> void:
	match current_state:
		PlayerState.IDLE:
			_state_idle(delta)
		PlayerState.WALK:
			_state_walk(delta)
		PlayerState.RUN:
			_state_run(delta)
		PlayerState.JUMP:
			_state_jump(delta)
		PlayerState.FALL:
			_state_fall(delta)
		PlayerState.HANG:
			_state_hang(delta)
		PlayerState.CLIMB:
			_state_climb(delta)
		PlayerState.SWIM:
			_state_swim(delta)
		PlayerState.ACTION:
			_state_action(delta)
		PlayerState.HURT:
			_state_hurt(delta)
		PlayerState.DEAD:
			_state_dead(delta)

	# Update invulnerability
	if is_invulnerable:
		_invuln_timer -= delta
		if _invuln_timer <= 0:
			is_invulnerable = false
			if _sprite:
				_sprite.modulate.a = 1.0
		else:
			# Blink effect
			if _sprite:
				_sprite.modulate.a = 0.5 if fmod(_invuln_timer, 0.2) < 0.1 else 1.0

	# Update facing direction (visual only - no scale flip for ColorRect)
	if input_direction.x > 0:
		facing_right = true
	elif input_direction.x < 0:
		facing_right = false


func _state_idle(delta: float) -> void:
	velocity.x = 0
	_apply_gravity(delta)
	move_and_slide()
	move_time = 0.0

	if is_jump_pressed:
		_enter_state(PlayerState.JUMP)
		velocity.y = STANDING_JUMP_VELOCITY
		AudioManager.play_sfx("jump")
	elif input_direction.x != 0:
		_enter_state(PlayerState.WALK)
	elif not is_on_floor():
		_enter_state(PlayerState.FALL)


func _state_walk(delta: float) -> void:
	_apply_gravity(delta)
	move_time += delta

	if input_direction.x != 0:
		velocity.x = input_direction.x * WALK_SPEED
	else:
		_enter_state(PlayerState.IDLE)
		return

	move_and_slide()

	if is_jump_pressed:
		var is_running: bool = move_time >= RUN_THRESHOLD_TIME
		_enter_state(PlayerState.JUMP)
		velocity.y = RUNNING_JUMP_VELOCITY if is_running else STANDING_JUMP_VELOCITY
		if is_running:
			velocity.x = input_direction.x * RUN_SPEED * RUNNING_JUMP_H_BOOST
		AudioManager.play_sfx("jump")
	elif move_time >= RUN_THRESHOLD_TIME:
		_enter_state(PlayerState.RUN)
	elif not is_on_floor():
		_enter_state(PlayerState.FALL)


func _state_run(delta: float) -> void:
	_apply_gravity(delta)
	move_time += delta

	if input_direction.x != 0:
		velocity.x = input_direction.x * RUN_SPEED
	else:
		_enter_state(PlayerState.IDLE)
		return

	move_and_slide()

	if is_jump_pressed:
		_enter_state(PlayerState.JUMP)
		velocity.y = RUNNING_JUMP_VELOCITY
		velocity.x = input_direction.x * RUN_SPEED * RUNNING_JUMP_H_BOOST
		AudioManager.play_sfx("jump")
	elif not is_on_floor():
		_enter_state(PlayerState.FALL)


func _state_jump(delta: float) -> void:
	_apply_gravity(delta)

	# Air control
	if input_direction.x != 0:
		velocity.x = move_toward(velocity.x, input_direction.x * WALK_SPEED, 200.0 * delta)

	move_and_slide()

	if velocity.y > 0:
		_enter_state(PlayerState.FALL)
	elif is_on_ceiling():
		velocity.y = 0
		_enter_state(PlayerState.FALL)


func _state_fall(delta: float) -> void:
	_apply_gravity(delta)

	if input_direction.x != 0:
		velocity.x = move_toward(velocity.x, input_direction.x * WALK_SPEED, 150.0 * delta)

	move_and_slide()

	if is_on_floor():
		AudioManager.play_sfx("land")
		if input_direction.x != 0:
			_enter_state(PlayerState.WALK)
		else:
			_enter_state(PlayerState.IDLE)
	elif near_hangable and input_direction.x != 0:
		_enter_state(PlayerState.HANG)


func _state_hang(_delta: float) -> void:
	velocity = Vector2.ZERO

	if input_direction.y < -0.5:
		_enter_state(PlayerState.CLIMB)
	elif input_direction.y > 0.5:
		near_hangable = false
		_enter_state(PlayerState.FALL)
	elif is_jump_pressed:
		_enter_state(PlayerState.JUMP)
		velocity.y = STANDING_JUMP_VELOCITY
		AudioManager.play_sfx("jump")
	elif not near_hangable:
		_enter_state(PlayerState.FALL)


func _state_climb(_delta: float) -> void:
	velocity.y = input_direction.y * CLIMB_SPEED
	velocity.x = 0
	move_and_slide()

	if is_on_floor() and input_direction.y >= 0:
		_enter_state(PlayerState.IDLE)
	elif not near_hangable:
		_enter_state(PlayerState.FALL)
	elif is_jump_pressed:
		_enter_state(PlayerState.JUMP)
		velocity.y = STANDING_JUMP_VELOCITY
		AudioManager.play_sfx("jump")


func _state_swim(delta: float) -> void:
	if input_direction.length() > 0.1:
		var target: Vector2 = input_direction.normalized() * SWIM_MAX_SPEED
		velocity = velocity.move_toward(target, SWIM_ACCELERATION * delta)
	else:
		velocity *= SWIM_DRAG

	if velocity.length() > SWIM_MAX_SPEED:
		velocity = velocity.normalized() * SWIM_MAX_SPEED

	move_and_slide()


func _state_action(delta: float) -> void:
	velocity = Vector2.ZERO
	_action_timer -= delta
	move_and_slide()

	if _action_timer <= 0:
		_enter_state(PlayerState.IDLE)


func _state_hurt(delta: float) -> void:
	_apply_gravity(delta)
	_hurt_timer -= delta
	move_and_slide()

	if _hurt_timer <= 0:
		is_invulnerable = true
		_invuln_timer = 1.5
		_enter_state(PlayerState.IDLE)


func _state_dead(delta: float) -> void:
	_apply_gravity(delta)
	_dead_timer -= delta
	move_and_slide()

	if _dead_timer <= 0:
		GameManager.lose_life()


func _apply_gravity(delta: float) -> void:
	if not is_on_floor():
		velocity.y = minf(velocity.y + GRAVITY * delta, MAX_FALL_SPEED)


func _enter_state(new_state: PlayerState) -> void:
	current_state = new_state
	match new_state:
		PlayerState.IDLE:
			move_time = 0.0
		PlayerState.WALK:
			pass
		PlayerState.RUN:
			pass
		PlayerState.JUMP:
			pass
		PlayerState.FALL:
			pass


func take_damage() -> void:
	if is_invulnerable or current_state == PlayerState.DEAD:
		return
	hurt.emit()
	AudioManager.play_sfx("hurt")
	_hurt_timer = 0.5
	velocity = Vector2(-200 if facing_right else 200, -300)
	_enter_state(PlayerState.HURT)


func die() -> void:
	if current_state == PlayerState.DEAD:
		return
	died.emit()
	AudioManager.play_sfx("meow_death")
	_dead_timer = 1.0
	velocity = Vector2(0, -200)
	_enter_state(PlayerState.DEAD)


func enter_swim_mode() -> void:
	_enter_state(PlayerState.SWIM)
	AudioManager.play_sfx("splash")


func start_action(duration: float) -> void:
	_action_timer = duration
	_enter_state(PlayerState.ACTION)


func set_input(direction: Vector2, jump: bool, action: bool, hold_time: float) -> void:
	input_direction = direction
	is_jump_pressed = jump
	is_action_pressed = action
	action_hold_duration = hold_time
