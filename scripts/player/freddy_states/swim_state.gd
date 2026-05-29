extends State
## SwimState - 8-directional swimming with inertia (Fishbowl Room only).


func enter(_params: Dictionary = {}) -> void:
	player.play_animation("swim")
	AudioManager.play_sfx("splash")


func physics_update(delta: float) -> void:
	# Apply acceleration based on input
	if player.input_direction.length() > 0.1:
		var target_velocity: Vector2 = player.input_direction.normalized() * Freddy.SWIM_MAX_SPEED
		player.velocity = player.velocity.move_toward(target_velocity, Freddy.SWIM_ACCELERATION * delta)
	else:
		# Apply drag when no input
		player.velocity *= Freddy.SWIM_DRAG

	# Clamp to max speed
	if player.velocity.length() > Freddy.SWIM_MAX_SPEED:
		player.velocity = player.velocity.normalized() * Freddy.SWIM_MAX_SPEED

	player.move_and_slide()

	# Flip sprite based on horizontal movement
	if player.velocity.x != 0:
		player.set_facing(player.velocity.x)
