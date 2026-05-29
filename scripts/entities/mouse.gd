extends Node2D
## Mouse - Moves between cheese holes or along clotheslines.

class_name Mouse

const BASE_MOVE_INTERVAL: float = 1.5
const FLEE_MULTIPLIER: float = 2.0
const FLEE_DISTANCE: float = 150.0

var current_hole: int = 0
var move_interval: float = BASE_MOVE_INTERVAL
var is_caught: bool = false
var target_player: Node2D = null
var connection_map: Dictionary = {}
var hole_positions: Array = []

var _move_timer: float = 0.0


func _process(delta: float) -> void:
	if is_caught:
		return

	_move_timer += delta

	# Adjust speed based on proximity to player
	if target_player:
		var distance: float = position.distance_to(target_player.position)
		if distance < FLEE_DISTANCE:
			move_interval = BASE_MOVE_INTERVAL / FLEE_MULTIPLIER
		else:
			move_interval = BASE_MOVE_INTERVAL

	if _move_timer >= move_interval:
		_move_timer = 0.0
		_move_to_next_hole()


func _move_to_next_hole() -> void:
	if connection_map.is_empty():
		return

	var connections: Array = connection_map.get(current_hole, [])
	if connections.size() == 0:
		return

	current_hole = connections.pick_random()

	if current_hole < hole_positions.size():
		position = hole_positions[current_hole]


func catch() -> void:
	is_caught = true
	visible = false


func setup(hole: int, connections: Dictionary, positions: Array) -> void:
	current_hole = hole
	connection_map = connections
	hole_positions = positions
	if hole < positions.size():
		position = positions[hole]
