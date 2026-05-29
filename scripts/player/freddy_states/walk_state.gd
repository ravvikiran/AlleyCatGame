extends State
## WalkState - Freddy walking at normal speed. Transitions to Run after sustained input.


func enter(_params: Dictionary = {}) -> void:
	player.play_animation("walk")


func physics_update(delta: float) -> void:
	player.apply_gravity(delta)

	# Apply horizontal movement
	if player.input_direction.x != 0:
		player.velocity.x = player.input_direction.x * Freddy.WALK_SPEED
		player.set_facing(player.input_direction.x)
	else:
		# No input, return to idle
		state_machine.transition_to("idle")
		return

	player.move_and_slide()

	# Transition to jump
	if player.is_jump_pressed:
		var is_running: bool = player.move_time >= Freddy.RUN_THRESHOLD_TIME
		state_machine.transition_to("jump", {"running": is_running})
		return

	# Transition to run after sustained movement
	if player.move_time >= Freddy.RUN_THRESHOLD_TIME:
		state_machine.transition_to("run")
		return

	# Transition to fall if not on floor
	if not player.is_on_floor():
		state_machine.transition_to("fall")
		return
