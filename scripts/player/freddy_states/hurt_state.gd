extends State
## HurtState - Freddy taking damage with knockback and brief invulnerability.

const HURT_DURATION: float = 0.8
const KNOCKBACK: Vector2 = Vector2(-200, -300)
const INVULNERABILITY_TIME: float = 1.5

var _elapsed: float = 0.0


func enter(_params: Dictionary = {}) -> void:
	_elapsed = 0.0
	player.is_invulnerable = true
	player.play_animation("hurt")

	# Apply knockback opposite to facing direction
	var kb: Vector2 = KNOCKBACK
	if player.facing_right:
		kb.x = -abs(kb.x)
	else:
		kb.x = abs(kb.x)
	player.velocity = kb


func physics_update(delta: float) -> void:
	_elapsed += delta
	player.apply_gravity(delta)
	player.move_and_slide()

	if _elapsed >= HURT_DURATION:
		# Check if this should be a death
		if GameManager.lives <= 0:
			state_machine.transition_to("dead")
		else:
			state_machine.transition_to("idle")
			# Start invulnerability timer
			_start_invulnerability_timer()


func _start_invulnerability_timer() -> void:
	var timer := player.get_tree().create_timer(INVULNERABILITY_TIME)
	timer.timeout.connect(_end_invulnerability)


func _end_invulnerability() -> void:
	player.is_invulnerable = false
