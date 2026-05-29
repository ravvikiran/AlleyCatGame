extends CharacterBody2D
## EnemyCat - Patrols a row in the Love Game, tracking Freddy's X position.

class_name EnemyCat

const BASE_SPEED: float = 150.0

var patrol_row: int = 0
var tracking_accuracy: float = 0.5
var speed: float = BASE_SPEED
var target_player: CharacterBody2D = null
var is_active: bool = true
var eliminated_timer: float = 0.0


func _ready() -> void:
	tracking_accuracy = DifficultyManager.get_param("cat_accuracy")


func _physics_process(delta: float) -> void:
	if not is_active:
		eliminated_timer -= delta
		if eliminated_timer <= 0:
			is_active = true
			visible = true
		return

	if not target_player:
		return

	# Track Freddy's X with accuracy factor
	var target_x: float = lerpf(position.x, target_player.position.x, tracking_accuracy)
	var diff: float = target_x - position.x
	velocity.x = sign(diff) * speed
	velocity.y = 0

	move_and_slide()


func eliminate(duration: float) -> void:
	is_active = false
	eliminated_timer = duration
	visible = false


func _on_body_entered(body: Node2D) -> void:
	if body is Freddy and is_active:
		# Knock Freddy down one row (handled by Love Game script)
		pass
