extends State
## DeadState - Freddy death animation, then signals GameManager.

const DEATH_ANIMATION_DURATION: float = 1.5

var _elapsed: float = 0.0


func enter(_params: Dictionary = {}) -> void:
	_elapsed = 0.0
	player.play_animation("dead")
	player.velocity = Vector2(0, -200)  # Pop up before falling
	player.set_physics_process(true)


func physics_update(delta: float) -> void:
	_elapsed += delta
	player.apply_gravity(delta)
	player.move_and_slide()

	if _elapsed >= DEATH_ANIMATION_DURATION:
		GameManager.lose_life()
