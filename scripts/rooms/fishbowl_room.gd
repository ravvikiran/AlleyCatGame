extends MinigameRoomBase
## FishbowlRoom - Eat 12 fish underwater while managing air and avoiding eels.
## Two phases: ROOM (jump into bowl) and UNDERWATER (swimming gameplay).

const FISH_COUNT: int = 12
const MAX_AIR: float = 30.0
const AIR_DRAIN_RATE: float = 1.0
const FISH_SPEED_MIN: float = 80.0
const FISH_SPEED_MAX: float = 150.0
const EEL_BASE_SPEED: float = 120.0
const EEL_SPEED_PER_DIFFICULTY: float = 20.0
const AQUARIUM_BOUNDS: Rect2 = Rect2(300, 100, 1320, 700)
const WATER_SURFACE_Y: float = 120.0

enum Phase { ROOM, UNDERWATER }

var _phase: Phase = Phase.ROOM
var _air_supply: float = MAX_AIR
var _fish_entities: Array = []
var _eel_entities: Array = []
var _fish_eaten: int = 0


func _ready() -> void:
	objective_count = FISH_COUNT
	has_magic_broom = false
	has_running_dog = false
	super._ready()

	# Hide action button (not needed)
	var touch: CanvasLayer = $UILayer/TouchController
	if touch:
		touch.hide_action_button()

	_setup_room_phase()


func _setup_room_phase() -> void:
	_phase = Phase.ROOM
	# Player starts in the room, must jump into the fishbowl
	# Fishbowl Area2D triggers transition to underwater
	var fishbowl: Area2D = get_node_or_null("Fishbowl")
	if fishbowl:
		fishbowl.body_entered.connect(_on_fishbowl_entered)


func _on_fishbowl_entered(body: Node2D) -> void:
	if body is Freddy:
		_enter_underwater()


func _enter_underwater() -> void:
	_phase = Phase.UNDERWATER
	_air_supply = MAX_AIR
	AudioManager.play_sfx("splash")

	# Switch player to swim state
	_player.state_machine.transition_to("swim")

	# Spawn fish
	_spawn_fish()


func _spawn_fish() -> void:
	for i in range(FISH_COUNT):
		var fish_data: Dictionary = {
			"position": Vector2(
				randf_range(AQUARIUM_BOUNDS.position.x + 50, AQUARIUM_BOUNDS.end.x - 50),
				randf_range(AQUARIUM_BOUNDS.position.y + 50, AQUARIUM_BOUNDS.end.y - 50)
			),
			"velocity": Vector2.from_angle(randf() * TAU) * randf_range(FISH_SPEED_MIN, FISH_SPEED_MAX),
			"alive": true,
		}
		_fish_entities.append(fish_data)


func _process(delta: float) -> void:
	super._process(delta)

	if _phase == Phase.UNDERWATER:
		_update_air(delta)
		_update_fish(delta)
		_update_eels(delta)
		_check_fish_collision()
		_check_eel_collision()


func _update_air(delta: float) -> void:
	_air_supply -= AIR_DRAIN_RATE * delta

	# Check if player surfaced
	if _player.position.y <= WATER_SURFACE_Y:
		_air_supply = MAX_AIR

	# Drowned
	if _air_supply <= 0:
		_player.die()


func _update_fish(delta: float) -> void:
	for fish in _fish_entities:
		if not fish["alive"]:
			continue

		# Move fish
		fish["position"] += fish["velocity"] * delta

		# Bounce off aquarium walls
		var pos: Vector2 = fish["position"]
		if pos.x < AQUARIUM_BOUNDS.position.x or pos.x > AQUARIUM_BOUNDS.end.x:
			fish["velocity"].x *= -1
		if pos.y < AQUARIUM_BOUNDS.position.y or pos.y > AQUARIUM_BOUNDS.end.y:
			fish["velocity"].y *= -1

		# Clamp position
		fish["position"].x = clampf(pos.x, AQUARIUM_BOUNDS.position.x, AQUARIUM_BOUNDS.end.x)
		fish["position"].y = clampf(pos.y, AQUARIUM_BOUNDS.position.y, AQUARIUM_BOUNDS.end.y)

		# Random direction change
		if randf() < 0.01:
			fish["velocity"] = Vector2.from_angle(randf() * TAU) * fish["velocity"].length()


func _update_eels(delta: float) -> void:
	for eel in _eel_entities:
		eel["position"] += eel["velocity"] * delta

		# Bounce off walls
		var pos: Vector2 = eel["position"]
		if pos.x < AQUARIUM_BOUNDS.position.x or pos.x > AQUARIUM_BOUNDS.end.x:
			eel["velocity"].x *= -1
		if pos.y < AQUARIUM_BOUNDS.position.y or pos.y > AQUARIUM_BOUNDS.end.y:
			eel["velocity"].y *= -1

		eel["position"].x = clampf(pos.x, AQUARIUM_BOUNDS.position.x, AQUARIUM_BOUNDS.end.x)
		eel["position"].y = clampf(pos.y, AQUARIUM_BOUNDS.position.y, AQUARIUM_BOUNDS.end.y)


func _check_fish_collision() -> void:
	for fish in _fish_entities:
		if not fish["alive"]:
			continue

		if _player.position.distance_to(fish["position"]) < 40.0:
			_eat_fish(fish)


func _eat_fish(fish: Dictionary) -> void:
	fish["alive"] = false
	_fish_eaten += 1
	AudioManager.play_sfx("catch_mouse")  # Reuse catch sound
	on_objective_completed()

	# Spawn eel(s)
	var eel_count: int = DifficultyManager.get_param_int("eel_per_fish")
	for i in range(eel_count):
		_spawn_eel()


func _spawn_eel() -> void:
	var eel_speed: float = EEL_BASE_SPEED + DifficultyManager.current_tier * EEL_SPEED_PER_DIFFICULTY
	var eel_data: Dictionary = {
		"position": Vector2(
			randf_range(AQUARIUM_BOUNDS.position.x, AQUARIUM_BOUNDS.end.x),
			randf_range(AQUARIUM_BOUNDS.position.y, AQUARIUM_BOUNDS.end.y)
		),
		"velocity": Vector2.from_angle(randf() * TAU) * eel_speed,
	}
	_eel_entities.append(eel_data)


func _check_eel_collision() -> void:
	for eel in _eel_entities:
		if _player.position.distance_to(eel["position"]) < 35.0:
			AudioManager.play_sfx("eel_zap")
			_player.die()
			return


func get_air_percentage() -> float:
	return _air_supply / MAX_AIR
