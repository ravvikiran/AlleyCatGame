extends State
## FallState - Freddy descending. Can transition to Hang near hangable surfaces.


func enter(_params: Dictionary = {}) -> void:
	player.play_animation("fall")


func physics_update(delta: float) -> void:
	player.apply_gravity(delta)

	# Air control
	if player.input_direction.x != 0:
		player.velocity.x = move_toward(player.velocity.x, player.input_direction.x * Freddy.WALK_SPEED, 150.0 * delta)
		player.set_facing(player.input_direction.x)

	player.move_and_slide()

	# Landed on floor
	if player.is_on_floor():
		AudioManager.play_sfx("land")
		if player.input_direction.x != 0:
			state_machine.transition_to("walk")
		else:
			state_machine.transition_to("idle")
		return

	# Check for hangable surface
	if player.near_hangable and player.input_direction.x != 0:
		state_machine.transition_to("hang")
		return
