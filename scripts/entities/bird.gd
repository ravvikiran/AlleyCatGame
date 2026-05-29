extends CharacterBody2D
## Bird - Flies in sine-wave pattern after being freed from cage.

class_name Bird

const H_SPEED: float = 200.0
const AMPLITUDE: float = 60.0
const FREQUENCY: float = 2.0
const DIRECTION_CHANGE_MIN: float = 1.5
const DIRECTION_CHANGE_MAX: float = 3.0
const SCREEN_LEFT: float = 120.0
const SCREEN_RIGHT: float = 1800.0

var base_y: float = 250.0
var direction: float = 1.0
var flight_time: float = 0.0
var change_timer: float = 0.0
var change_interval: float = 2.0
var is_free: bool = false


func _ready() -> void:
	direction = 1.0 if randf() > 0.5 else -1.0
	change_interval = randf_range(DIRECTION_CHANGE_MIN, DIRECTION_CHANGE_MAX)


func _physics_process(delta: float) -> void:
	if not is_free:
		return

	flight_time += delta
	change_timer += delta

	# Sine-wave flight
	position.x += H_SPEED * direction * delta
	position.y = base_y + sin(flight_time * FREQUENCY * TAU) * AMPLITUDE

	# Bounce off screen edges
	if position.x > SCREEN_RIGHT or position.x < SCREEN_LEFT:
		direction *= -1

	# Random direction change
	if change_timer >= change_interval:
		change_timer = 0.0
		change_interval = randf_range(DIRECTION_CHANGE_MIN, DIRECTION_CHANGE_MAX)
		direction *= -1


func free_bird(start_position: Vector2) -> void:
	is_free = true
	position = start_position
	base_y = start_position.y
	flight_time = 0.0
