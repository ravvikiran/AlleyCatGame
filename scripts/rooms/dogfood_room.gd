extends MinigameRoomBase
## DogfoodRoom - Drink from all bowls while avoiding waking sleeping dogs.
## Row-based navigation: jump = +2 rows, drop = -1 row.

const ROW_COUNT: int = 4
const PROXIMITY_RADIUS: float = 80.0
const FILL_RATE_CLOSE: float = 1.0  # per second at touching distance
const FILL_RATE_EDGE: float = 0.3  # per second at radius edge
const DRAIN_RATE: float = 0.2  # per second when outside radius
const DRINK_DURATION: float = 1.5
const ROW_Y_POSITIONS: Array = [520.0, 400.0, 280.0, 160.0]  # Bottom to top

var _sleeping_dogs: Array = []  # Array of {node, awake_meter, row, state}
var _dog_bowls: Array = []  # Array of {node, consumed, row}
var _current_row: int = 0
var _is_drinking: bool = false
var _drink_timer: float = 0.0
var _current_bowl: Dictionary = {}


func _ready() -> void:
	has_magic_broom = false
	has_running_dog = false
	super._ready()

	# Show action button for drinking
	var touch: CanvasLayer = $UILayer/TouchController
	if touch:
		touch.show_action_button()

	_setup_dogs_and_bowls()
	objective_count = _dog_bowls.size()


func _setup_dogs_and_bowls() -> void:
	# Create dogs and bowls for each row
	for row in range(ROW_COUNT):
		var bowl_count: int = 2 if row < 2 else 1
		for b in range(bowl_count):
			var x_pos: float = 400.0 + b * 500.0 + randf_range(-50, 50)
			var y_pos: float = ROW_Y_POSITIONS[row]

			# Create bowl
			var bowl_data: Dictionary = {
				"position": Vector2(x_pos, y_pos),
				"consumed": false,
				"row": row,
			}
			_dog_bowls.append(bowl_data)

			# Create sleeping dog next to bowl
			var dog_data: Dictionary = {
				"position": Vector2(x_pos + 60, y_pos),
				"awake_meter": 0.0,
				"row": row,
				"state": "sleeping",  # sleeping, waking, attacking
			}
			_sleeping_dogs.append(dog_data)


func _on_action_pressed() -> void:
	if _is_drinking:
		return

	# Find nearest bowl on current row
	var nearest_bowl: Dictionary = _find_nearest_bowl()
	if nearest_bowl.is_empty():
		return

	if nearest_bowl.get("consumed", true):
		return

	# Start drinking
	_is_drinking = true
	_drink_timer = 0.0
	_current_bowl = nearest_bowl
	_player.start_action(DRINK_DURATION)


func _process(delta: float) -> void:
	super._process(delta)

	# Update drinking
	if _is_drinking:
		_drink_timer += delta
		if _drink_timer >= DRINK_DURATION:
			_complete_drink()

	# Update awake meters
	_update_awake_meters(delta)


func _complete_drink() -> void:
	_is_drinking = false
	if not _current_bowl.is_empty():
		_current_bowl["consumed"] = true
		on_objective_completed()
	_current_bowl = {}


func _update_awake_meters(delta: float) -> void:
	if not _player:
		return

	for dog in _sleeping_dogs:
		if dog["state"] == "attacking":
			continue

		var dog_pos: Vector2 = dog["position"]
		var player_pos: Vector2 = _player.position

		# Only affect dogs on the same row
		if dog["row"] != _current_row:
			# Drain meter when on different row
			dog["awake_meter"] = maxf(0.0, dog["awake_meter"] - DRAIN_RATE * delta)
			continue

		var distance: float = player_pos.distance_to(dog_pos)

		if distance < PROXIMITY_RADIUS:
			# Fill rate scales inversely with distance
			var proximity_factor: float = 1.0 - (distance / PROXIMITY_RADIUS)
			var fill_rate: float = lerpf(FILL_RATE_EDGE, FILL_RATE_CLOSE, proximity_factor)
			dog["awake_meter"] = minf(1.0, dog["awake_meter"] + fill_rate * delta)

			# Visual warning at 80%
			if dog["awake_meter"] > 0.8:
				dog["state"] = "waking"

			# Dog wakes up!
			if dog["awake_meter"] >= 1.0:
				dog["state"] = "attacking"
				_dog_attacks(dog)
		else:
			# Drain meter when outside radius
			dog["awake_meter"] = maxf(0.0, dog["awake_meter"] - DRAIN_RATE * delta)
			if dog["awake_meter"] < 0.8:
				dog["state"] = "sleeping"


func _dog_attacks(_dog: Dictionary) -> void:
	# Dog woke up and attacks Freddy
	_player.die()


func _find_nearest_bowl() -> Dictionary:
	var min_dist: float = INF
	var nearest: Dictionary = {}

	for bowl in _dog_bowls:
		if bowl["consumed"]:
			continue
		if bowl["row"] != _current_row:
			continue

		var dist: float = _player.position.distance_to(bowl["position"])
		if dist < min_dist and dist < 80.0:
			min_dist = dist
			nearest = bowl

	return nearest


func _physics_process(delta: float) -> void:
	super._physics_process(delta)

	# Override jump/drop for row navigation
	if _player.is_jump_pressed and not _is_drinking:
		_current_row = mini(_current_row + 2, ROW_COUNT - 1)
		_player.position.y = ROW_Y_POSITIONS[_current_row]
		_player.is_jump_pressed = false

	# Track current row based on player Y
	# (In case of external forces)
	var closest_row: int = 0
	var min_diff: float = INF
	for i in range(ROW_COUNT):
		var diff: float = abs(_player.position.y - ROW_Y_POSITIONS[i])
		if diff < min_diff:
			min_diff = diff
			closest_row = i
	_current_row = closest_row
