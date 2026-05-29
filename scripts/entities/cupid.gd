extends Node2D
## Cupid - Positioned at screen edges, shoots diagonal arrows that toggle heart platforms.

class_name Cupid

const SHOOT_INTERVAL: float = 3.0
const ARROW_SPEED: float = 300.0

var shoot_timer: float = 0.0
var is_left_side: bool = true

signal arrow_shot(position: Vector2, velocity: Vector2)


func _ready() -> void:
	shoot_timer = randf_range(0, SHOOT_INTERVAL)  # Stagger initial shots


func _process(delta: float) -> void:
	shoot_timer += delta
	if shoot_timer >= SHOOT_INTERVAL:
		shoot_timer = 0.0
		_shoot()


func _shoot() -> void:
	var angle: float
	if is_left_side:
		angle = -PI / 4.0  # 45 degrees up-right
	else:
		angle = -3.0 * PI / 4.0  # 45 degrees up-left

	var arrow_velocity: Vector2 = Vector2.from_angle(angle) * ARROW_SPEED
	arrow_shot.emit(position, arrow_velocity)
