extends CharacterBody2D
## Spider - Tracks Freddy horizontally, drops when aligned, ascends when Freddy moves away.

class_name Spider

enum SpiderState { TRACKING, DROPPING, ASCENDING }

const H_SPEED_BASE: float = 120.0
const DROP_SPEED_BASE: float = 500.0
const ASCEND_SPEED: float = 200.0
const DROP_THRESHOLD: float = 10.0
const ASCEND_THRESHOLD: float = 60.0
const CEILING_Y: float = 20.0
const FLOOR_Y: float = 600.0

var current_state: SpiderState = SpiderState.TRACKING
var target_player: CharacterBody2D = null
var h_speed: float = H_SPEED_BASE
var drop_speed: float = DROP_SPEED_BASE


func _ready() -> void:
	var speed_mult: float = DifficultyManager.get_param("spider_speed")
	h_speed = H_SPEED_BASE * speed_mult
	drop_speed = DROP_SPEED_BASE * speed_mult
	position.y = CEILING_Y


func _physics_process(_delta: float) -> void:
	if not target_player:
		return

	match current_state:
		SpiderState.TRACKING:
			var diff_x: float = target_player.position.x - position.x
			if abs(diff_x) > DROP_THRESHOLD:
				velocity = Vector2(sign(diff_x) * h_speed, 0)
			else:
				current_state = SpiderState.DROPPING
				velocity = Vector2.ZERO

		SpiderState.DROPPING:
			velocity = Vector2(0, drop_speed)

			var diff_x: float = abs(target_player.position.x - position.x)
			if diff_x > ASCEND_THRESHOLD:
				current_state = SpiderState.ASCENDING

			if position.y > FLOOR_Y:
				current_state = SpiderState.ASCENDING

		SpiderState.ASCENDING:
			velocity = Vector2(0, -ASCEND_SPEED)

			if position.y <= CEILING_Y:
				position.y = CEILING_Y
				current_state = SpiderState.TRACKING

	move_and_slide()


func _on_body_entered(body: Node2D) -> void:
	if body is Freddy:
		body.die()
