extends State
## ClimbState - Freddy climbing vertically on a surface.


func enter(_params: Dictionary = {}) -> void:
	player.play_animation("climb")


func physics_update(_delta: float) -> void:
	# Vertical movement
	player.velocity.y = player.input_direction.y * Freddy.CLIMB_SPEED
	player.velocity.x = 0

	player.move_and_slide()

	# Reached top (on floor)
	if player.is_on_floor() and player.input_direction.y >= 0:
		state_machine.transition_to("idle")
		return

	# Drop down
	if player.input_direction.y > 0.5:
		state_machine.transition_to("fall")
		return

	# No longer near climbable surface
	if not player.near_hangable:
		state_machine.transition_to("fall")
		return

	# Jump off
	if player.is_jump_pressed:
		state_machine.transition_to("jump", {"running": false})
		return
