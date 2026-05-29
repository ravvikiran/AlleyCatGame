extends State
## IdleState - Freddy standing still with tail twitch animation.


func enter(_params: Dictionary = {}) -> void:
	player.velocity.x = 0
	player.move_time = 0.0
	player.play_animation("idle")


func physics_update(delta: float) -> void:
	player.apply_gravity(delta)
	player.move_and_slide()

	# Transition to jump
	if player.is_jump_pressed:
		state_machine.transition_to("jump", {"running": false})
		return

	# Transition to walk
	if player.input_direction.x != 0:
		state_machine.transition_to("walk")
		return

	# Transition to fall if not on floor
	if not player.is_on_floor():
		state_machine.transition_to("fall")
		return
