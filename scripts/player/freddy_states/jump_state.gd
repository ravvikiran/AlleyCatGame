extends State
## JumpState - Freddy ascending. Differentiates standing vs running jump.

var _is_running_jump: bool = false


func enter(params: Dictionary = {}) -> void:
	_is_running_jump = params.get("running", false)
	player.play_animation("jump")
	AudioManager.play_sfx("jump")

	# Apply jump velocity
	if _is_running_jump:
		player.velocity.y = Freddy.RUNNING_JUMP_VELOCITY
		player.velocity.x = player.input_direction.x * Freddy.RUN_SPEED * Freddy.RUNNING_JUMP_H_BOOST
	else:
		player.velocity.y = Freddy.STANDING_JUMP_VELOCITY
		# Maintain current horizontal velocity for standing jump
		player.velocity.x = player.input_direction.x * Freddy.WALK_SPEED


func physics_update(delta: float) -> void:
	player.apply_gravity(delta)

	# Allow air control (reduced)
	if player.input_direction.x != 0:
		var target_speed: float = Freddy.WALK_SPEED if not _is_running_jump else Freddy.RUN_SPEED
		player.velocity.x = move_toward(player.velocity.x, player.input_direction.x * target_speed, 200.0 * delta)
		player.set_facing(player.input_direction.x)

	player.move_and_slide()

	# Transition to fall when velocity becomes downward
	if player.velocity.y > 0:
		state_machine.transition_to("fall")
		return

	# Hit ceiling
	if player.is_on_ceiling():
		player.velocity.y = 0
		state_machine.transition_to("fall")
		return
