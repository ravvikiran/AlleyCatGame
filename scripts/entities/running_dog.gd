extends CharacterBody2D
## RunningDog - Patrols horizontally, kills Freddy on contact.

class_name RunningDog

const BASE_SPEED: float = 250.0
const SCREEN_LEFT: float = -80.0
const SCREEN_RIGHT: float = 2000.0

var speed: float = BASE_SPEED
var direction: float = 1.0


func _ready() -> void:
	speed = BASE_SPEED * DifficultyManager.get_param("dog_speed")
	direction = 1.0 if randi() % 2 == 0 else -1.0

	if direction > 0:
		position.x = SCREEN_LEFT
	else:
		position.x = SCREEN_RIGHT


func _physics_process(delta: float) -> void:
	position.x += speed * direction * delta

	# Reverse at screen edges
	if position.x > SCREEN_RIGHT:
		direction = -1.0
	elif position.x < SCREEN_LEFT:
		direction = 1.0


func _on_body_entered(body: Node2D) -> void:
	if body is Freddy:
		body.die()
