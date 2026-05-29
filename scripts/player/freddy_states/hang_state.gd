extends State
## HangState - Freddy clinging to a surface (clothesline, shelf, cheese hole).


func enter(_params: Dictionary = {}) -> void:
	player.velocity = Vector2.ZERO
	player.play_animation("hang")


func physics_update(_delta: float) -> void:
	# No gravity while hanging
	player.velocity = Vector2.ZERO

	# Climb up
	if player.input_direction.y < -0.5:
		state_machine.transition_to("climb")
		return

	# Drop down
	if player.input_direction.y > 0.5:
		player.near_hangable = false
		state_machine.transition_to("fall")
		return

	# Jump from hang
	if player.is_jump_pressed:
		state_machine.transition_to("jump", {"running": false})
		return

	# Lost grip (set externally by hazards like mice)
	if not player.near_hangable:
		state_machine.transition_to("fall")
		return
