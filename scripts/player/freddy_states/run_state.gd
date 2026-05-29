extends State
## RunState - Freddy running at higher speed. Enables running jump.


func enter(_params: Dictionary = {}) -> void:
	player.play_animation("run")


func physics_update(delta: float) -> void:
	player.apply_gravity(delta)

	# Apply horizontal movement at run speed
	if player.input_direction.x != 0:
		player.velocity.x = player.input_direction.x * Freddy.RUN_SPEED
		player.set_facing(player.input_direction.x)
	else:
		# Stopped moving, decelerate to idle
		state_machine.transition_to("idle")
		return

	player.move_and_slide()

	# Transition to running jump
	if player.is_jump_pressed:
		state_machine.transition_to("jump", {"running": true})
		return

	# Transition to fall if not on floor
	if not player.is_on_floor():
		state_machine.transition_to("fall")
		return
