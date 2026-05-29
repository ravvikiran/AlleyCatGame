extends CharacterBody2D
## ElectricEel - Bounces off aquarium walls in linear paths. Kills on contact.

class_name ElectricEel

const BASE_SPEED: float = 120.0
const SPEED_PER_DIFFICULTY: float = 20.0

var bounds: Rect2 = Rect2(300, 100, 1320, 700)
var move_direction: Vector2 = Vector2.ZERO
var speed: float = BASE_SPEED


func _ready() -> void:
	speed = BASE_SPEED + DifficultyManager.current_tier * SPEED_PER_DIFFICULTY
	move_direction = Vector2.from_angle(randf() * TAU)
	velocity = move_direction * speed


func _physics_process(_delta: float) -> void:
	velocity = move_direction * speed
	move_and_slide()

	# Bounce off bounds
	if position.x <= bounds.position.x or position.x >= bounds.end.x:
		move_direction.x *= -1
		position.x = clampf(position.x, bounds.position.x + 1, bounds.end.x - 1)

	if position.y <= bounds.position.y or position.y >= bounds.end.y:
		move_direction.y *= -1
		position.y = clampf(position.y, bounds.position.y + 1, bounds.end.y - 1)


func _on_body_entered(body: Node2D) -> void:
	if body is Freddy:
		AudioManager.play_sfx("eel_zap")
		body.die()
