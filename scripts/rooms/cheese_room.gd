extends MinigameRoomBase
## CheeseRoom - Catch 4 mice hiding in Swiss cheese holes.
## Freddy can teleport between connected holes using the Action button.

const HOLE_COUNT: int = 16
const MOUSE_COUNT: int = 4
const MOUSE_MOVE_INTERVAL: float = 1.5
const MOUSE_FLEE_MULTIPLIER: float = 2.0
const FLEE_DISTANCE: float = 150.0  # pixels

# 4x4 grid connection map (each hole connects to adjacent holes)
const CONNECTION_MAP: Dictionary = {
	0: [1, 4],
	1: [0, 2, 5],
	2: [1, 3, 6],
	3: [2, 7],
	4: [0, 5, 8],
	5: [1, 4, 6, 9],
	6: [2, 5, 7, 10],
	7: [3, 6, 11],
	8: [4, 9, 12],
	9: [5, 8, 10, 13],
	10: [6, 9, 11, 14],
	11: [7, 10, 15],
	12: [8, 13],
	13: [9, 12, 14],
	14: [10, 13, 15],
	15: [11, 14],
}

# Hole positions in the cheese block (relative to cheese origin)
const HOLE_POSITIONS: Array = [
	Vector2(100, 100), Vector2(250, 100), Vector2(400, 100), Vector2(550, 100),
	Vector2(100, 220), Vector2(250, 220), Vector2(400, 220), Vector2(550, 220),
	Vector2(100, 340), Vector2(250, 340), Vector2(400, 340), Vector2(550, 340),
	Vector2(100, 460), Vector2(250, 460), Vector2(400, 460), Vector2(550, 460),
]

var _cheese_origin: Vector2 = Vector2(600, 100)
var _mouse_positions: Array = []  # hole index for each mouse
var _mouse_timers: Array = []
var _freddy_hole: int = -1  # -1 means not in a hole
var _mice_caught: int = 0


func _ready() -> void:
	objective_count = MOUSE_COUNT
	has_magic_broom = true
	has_running_dog = true
	super._ready()

	# Show action button for teleporting
	var touch: CanvasLayer = $UILayer/TouchController
	if touch:
		touch.show_action_button()

	_spawn_mice()


func _spawn_mice() -> void:
	# Place mice in random holes
	var available_holes: Array = range(HOLE_COUNT)
	available_holes.shuffle()

	for i in range(MOUSE_COUNT):
		_mouse_positions.append(available_holes[i])
		# Create mouse move timer
		var timer := Timer.new()
		timer.wait_time = MOUSE_MOVE_INTERVAL
		timer.timeout.connect(_move_mouse.bind(i))
		timer.autostart = true
		add_child(timer)
		_mouse_timers.append(timer)


func _move_mouse(mouse_index: int) -> void:
	if mouse_index >= _mouse_positions.size():
		return

	var current_hole: int = _mouse_positions[mouse_index]
	var connections: Array = CONNECTION_MAP[current_hole]

	# Pick a random connected hole
	var next_hole: int = connections.pick_random()
	_mouse_positions[mouse_index] = next_hole

	# Check if Freddy is nearby - speed up
	if _freddy_hole >= 0:
		var freddy_pos: Vector2 = _get_hole_world_position(_freddy_hole)
		var mouse_pos: Vector2 = _get_hole_world_position(current_hole)
		if freddy_pos.distance_to(mouse_pos) < FLEE_DISTANCE:
			_mouse_timers[mouse_index].wait_time = MOUSE_MOVE_INTERVAL / MOUSE_FLEE_MULTIPLIER
		else:
			_mouse_timers[mouse_index].wait_time = MOUSE_MOVE_INTERVAL
	
	# Check for catch
	_check_catch(mouse_index)


func _on_action_pressed() -> void:
	# Teleport Freddy to a connected hole
	_freddy_hole = _find_nearest_hole()
	if _freddy_hole < 0:
		return

	var connections: Array = CONNECTION_MAP[_freddy_hole]
	var target_hole: int = connections.pick_random()
	_freddy_hole = target_hole

	# Move player to hole position
	_player.position = _get_hole_world_position(target_hole)
	_player.state_machine.transition_to("action", {"type": "teleport", "duration": 0.1})

	# Check for catches at new position
	for i in range(_mouse_positions.size()):
		_check_catch(i)


func _check_catch(mouse_index: int) -> void:
	if mouse_index >= _mouse_positions.size():
		return

	if _freddy_hole >= 0 and _mouse_positions[mouse_index] == _freddy_hole:
		# Caught a mouse!
		AudioManager.play_sfx("catch_mouse")
		ScoreManager.award_points(ScoreManager.ScoreEvent.MOUSE_CATCH)
		_mouse_positions[mouse_index] = -1  # Mark as caught
		_mouse_timers[mouse_index].stop()
		on_objective_completed()


func _find_nearest_hole() -> int:
	var min_dist: float = INF
	var nearest: int = -1

	for i in range(HOLE_COUNT):
		var hole_pos: Vector2 = _get_hole_world_position(i)
		var dist: float = _player.position.distance_to(hole_pos)
		if dist < min_dist and dist < 60.0:  # Must be close to a hole
			min_dist = dist
			nearest = i

	return nearest


func _get_hole_world_position(hole_index: int) -> Vector2:
	if hole_index < 0 or hole_index >= HOLE_POSITIONS.size():
		return Vector2.ZERO
	return _cheese_origin + HOLE_POSITIONS[hole_index]


func _physics_process(delta: float) -> void:
	super._physics_process(delta)

	# Update Freddy's current hole tracking
	_freddy_hole = _find_nearest_hole()
