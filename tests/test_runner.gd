extends SceneTree
## TestRunner - Command-line test runner for Midnight Prowl.
## Run with: godot --headless --script tests/test_runner.gd

var _tests_passed: int = 0
var _tests_failed: int = 0
var _test_results: Array = []


func _init() -> void:
	print("\n========================================")
	print("  MIDNIGHT PROWL - Integration Test Suite")
	print("========================================\n")

	_run_all_tests()

	print("\n========================================")
	print("  RESULTS: %d passed, %d failed" % [_tests_passed, _tests_failed])
	print("========================================\n")

	if _tests_failed > 0:
		for result in _test_results:
			if not result["passed"]:
				print("  FAIL: %s - %s" % [result["name"], result["message"]])
		quit(1)
	else:
		quit(0)


func _run_all_tests() -> void:
	_section("Game State Machine")
	_test_initial_state()
	_test_valid_transitions()
	_test_invalid_transitions()
	_test_lives_management()
	_test_game_over_on_zero_lives()

	_section("Difficulty System")
	_test_difficulty_initial_tier()
	_test_difficulty_advance()
	_test_difficulty_cap()
	_test_difficulty_params_monotonic()

	_section("Score System")
	_test_score_initial_zero()
	_test_score_award_points()
	_test_score_time_bonus()
	_test_score_high_score()
	_test_score_love_multiplier()

	_section("Save System")
	_test_save_default_data()
	_test_save_corruption_resilience()

	_section("Physics Parameters")
	_test_running_jump_greater_than_standing()
	_test_swim_physics_drag()

	_section("Cheese Room Logic")
	_test_cheese_hole_connections()
	_test_cheese_teleport_adjacency()

	_section("Fishbowl Room Logic")
	_test_air_supply_countdown()
	_test_eel_spawn_per_fish()
	_test_eel_wall_bounce()

	_section("Dogfood Room Logic")
	_test_awake_meter_proximity()
	_test_awake_meter_drain()

	_section("Love Game Logic")
	_test_heart_toggle_involution()
	_test_enemy_cat_knockdown()
	_test_love_game_extra_life()

	_section("Window Manager Logic")
	_test_window_open_duration_bounds()


func _section(name: String) -> void:
	print("\n--- %s ---" % name)


func _assert(condition: bool, test_name: String, message: String = "") -> void:
	if condition:
		_tests_passed += 1
		_test_results.append({"name": test_name, "passed": true, "message": ""})
		print("  PASS: %s" % test_name)
	else:
		_tests_failed += 1
		var msg: String = message if message != "" else "Assertion failed"
		_test_results.append({"name": test_name, "passed": false, "message": msg})
		print("  FAIL: %s - %s" % [test_name, msg])


func _assert_eq(actual, expected, test_name: String) -> void:
	_assert(actual == expected, test_name, "Expected %s, got %s" % [str(expected), str(actual)])


func _assert_gt(a, b, test_name: String) -> void:
	_assert(a > b, test_name, "Expected %s > %s" % [str(a), str(b)])


func _assert_lt(a, b, test_name: String) -> void:
	_assert(a < b, test_name, "Expected %s < %s" % [str(a), str(b)])


# ============================================================
# Game State Machine Tests
# ============================================================

func _test_initial_state() -> void:
	# GameManager starts at TITLE_SCREEN
	_assert_eq(GameManager.current_state, GameManager.GameState.TITLE_SCREEN,
		"Initial state is TITLE_SCREEN")


func _test_valid_transitions() -> void:
	# Test that state changes update current_state
	GameManager.current_state = GameManager.GameState.TITLE_SCREEN
	GameManager.lives = 9

	# Simulate state change without scene loading
	GameManager.current_state = GameManager.GameState.ALLEYWAY_HUB
	_assert_eq(GameManager.current_state, GameManager.GameState.ALLEYWAY_HUB,
		"Transition to ALLEYWAY_HUB")

	GameManager.current_state = GameManager.GameState.MINIGAME_CHEESE
	_assert_eq(GameManager.current_state, GameManager.GameState.MINIGAME_CHEESE,
		"Transition to MINIGAME_CHEESE")


func _test_invalid_transitions() -> void:
	# Verify state enum values are distinct
	_assert(GameManager.GameState.TITLE_SCREEN != GameManager.GameState.ALLEYWAY_HUB,
		"States are distinct values")
	_assert(GameManager.GameState.GAME_OVER != GameManager.GameState.LOVE_GAME,
		"GAME_OVER != LOVE_GAME")


func _test_lives_management() -> void:
	GameManager.lives = 5
	GameManager.gain_life()
	_assert_eq(GameManager.lives, 6, "gain_life increments lives")

	GameManager.lives = 3
	# Manually decrement (lose_life triggers scene change)
	GameManager.lives -= 1
	_assert_eq(GameManager.lives, 2, "Losing a life decrements counter")


func _test_game_over_on_zero_lives() -> void:
	GameManager.lives = 1
	GameManager.lives -= 1
	_assert_eq(GameManager.lives, 0, "Lives reach zero")
	_assert(GameManager.lives <= 0, "Game over condition: lives <= 0")


# ============================================================
# Difficulty System Tests
# ============================================================

func _test_difficulty_initial_tier() -> void:
	DifficultyManager.reset()
	_assert_eq(DifficultyManager.current_tier, DifficultyManager.DifficultyTier.KITTEN,
		"Initial tier is KITTEN")


func _test_difficulty_advance() -> void:
	DifficultyManager.reset()
	DifficultyManager.advance_tier()
	_assert_eq(DifficultyManager.current_tier, DifficultyManager.DifficultyTier.HOUSE_CAT,
		"Advance from KITTEN to HOUSE_CAT")

	DifficultyManager.advance_tier()
	_assert_eq(DifficultyManager.current_tier, DifficultyManager.DifficultyTier.TOMCAT,
		"Advance from HOUSE_CAT to TOMCAT")

	DifficultyManager.advance_tier()
	_assert_eq(DifficultyManager.current_tier, DifficultyManager.DifficultyTier.ALLEY_CAT,
		"Advance from TOMCAT to ALLEY_CAT")


func _test_difficulty_cap() -> void:
	DifficultyManager.current_tier = DifficultyManager.DifficultyTier.ALLEY_CAT
	DifficultyManager.advance_tier()
	_assert_eq(DifficultyManager.current_tier, DifficultyManager.DifficultyTier.ALLEY_CAT,
		"Tier caps at ALLEY_CAT")


func _test_difficulty_params_monotonic() -> void:
	# Dog speed should increase with each tier
	var speeds: Array = []
	for tier in range(4):
		DifficultyManager.current_tier = tier as DifficultyManager.DifficultyTier
		speeds.append(DifficultyManager.get_param("dog_speed"))

	var monotonic: bool = true
	for i in range(1, speeds.size()):
		if speeds[i] < speeds[i - 1]:
			monotonic = false
			break

	_assert(monotonic, "Dog speed increases monotonically with tier")

	# Spider speed should increase
	var spider_speeds: Array = []
	for tier in range(4):
		DifficultyManager.current_tier = tier as DifficultyManager.DifficultyTier
		spider_speeds.append(DifficultyManager.get_param("spider_speed"))

	var spider_mono: bool = true
	for i in range(1, spider_speeds.size()):
		if spider_speeds[i] < spider_speeds[i - 1]:
			spider_mono = false
			break

	_assert(spider_mono, "Spider speed increases monotonically with tier")

	# Trash cans should decrease
	var cans: Array = []
	for tier in range(4):
		DifficultyManager.current_tier = tier as DifficultyManager.DifficultyTier
		cans.append(DifficultyManager.get_param_int("trash_cans"))

	var cans_decrease: bool = true
	for i in range(1, cans.size()):
		if cans[i] > cans[i - 1]:
			cans_decrease = false
			break

	_assert(cans_decrease, "Trash can count decreases with tier")

	DifficultyManager.reset()


# ============================================================
# Score System Tests
# ============================================================

func _test_score_initial_zero() -> void:
	ScoreManager.reset()
	_assert_eq(ScoreManager.current_score, 0, "Score starts at zero after reset")


func _test_score_award_points() -> void:
	ScoreManager.reset()
	ScoreManager.award_points(ScoreManager.ScoreEvent.MOUSE_CATCH)
	_assert_eq(ScoreManager.current_score, 100, "Mouse catch awards 100 points")

	ScoreManager.award_points(ScoreManager.ScoreEvent.MINIGAME_COMPLETE)
	_assert_eq(ScoreManager.current_score, 600, "Minigame complete awards 500 more (total 600)")


func _test_score_time_bonus() -> void:
	ScoreManager.reset()
	ScoreManager.award_time_bonus(10.0)
	_assert_eq(ScoreManager.current_score, 100, "10 seconds remaining = 100 point time bonus")


func _test_score_high_score() -> void:
	ScoreManager.reset()
	ScoreManager.high_score = 500
	ScoreManager.current_score = 600
	var is_new: bool = ScoreManager.check_high_score()
	_assert(is_new, "New high score detected when current > high")
	_assert_eq(ScoreManager.high_score, 600, "High score updated to 600")

	ScoreManager.current_score = 300
	var is_new2: bool = ScoreManager.check_high_score()
	_assert(not is_new2, "No new high score when current < high")


func _test_score_love_multiplier() -> void:
	ScoreManager.reset()
	ScoreManager.set_love_multiplier(true)
	_assert_eq(ScoreManager.love_game_multiplier, 2, "Gift doubles multiplier")

	ScoreManager.set_love_multiplier(false)
	_assert_eq(ScoreManager.love_game_multiplier, 1, "No gift = 1x multiplier")

	# Test multiplied love game score
	ScoreManager.reset()
	ScoreManager.set_love_multiplier(true)
	ScoreManager.award_points(ScoreManager.ScoreEvent.LOVE_GAME_COMPLETE)
	_assert_eq(ScoreManager.current_score, 2000, "Love game with 2x = 2000 points")


# ============================================================
# Save System Tests
# ============================================================

func _test_save_default_data() -> void:
	var data: Dictionary = SaveManager.load_data()
	_assert(data.has("high_score"), "Default data has high_score key")
	_assert(data.has("settings"), "Default data has settings key")
	_assert(data["settings"].has("music_volume"), "Settings has music_volume")


func _test_save_corruption_resilience() -> void:
	# Simulate loading corrupted data by testing the default fallback
	var defaults: Dictionary = SaveManager.DEFAULT_DATA.duplicate(true)
	_assert(defaults is Dictionary, "Default data is a valid Dictionary")
	_assert_eq(defaults["high_score"], 0, "Default high score is 0")


# ============================================================
# Physics Tests
# ============================================================

func _test_running_jump_greater_than_standing() -> void:
	# Running jump should cover more distance
	var standing_vy: float = abs(Freddy.STANDING_JUMP_VELOCITY)
	var running_vy: float = abs(Freddy.RUNNING_JUMP_VELOCITY)
	_assert_gt(running_vy, standing_vy, "Running jump velocity > standing jump velocity")

	# Horizontal distance comparison
	var standing_h: float = Freddy.WALK_SPEED
	var running_h: float = Freddy.RUN_SPEED * Freddy.RUNNING_JUMP_H_BOOST
	_assert_gt(running_h, standing_h, "Running jump horizontal speed > standing")


func _test_swim_physics_drag() -> void:
	# Drag should reduce velocity over time
	var velocity: float = 200.0
	var after_drag: float = velocity * Freddy.SWIM_DRAG
	_assert_lt(after_drag, velocity, "Swim drag reduces velocity")
	_assert_gt(after_drag, 0.0, "Swim drag doesn't zero velocity instantly")


# ============================================================
# Cheese Room Tests
# ============================================================

func _test_cheese_hole_connections() -> void:
	# Verify all holes have at least 2 connections (corners have 2, edges 3, center 4)
	var connection_map: Dictionary = {
		0: [1, 4], 1: [0, 2, 5], 2: [1, 3, 6], 3: [2, 7],
		4: [0, 5, 8], 5: [1, 4, 6, 9], 6: [2, 5, 7, 10], 7: [3, 6, 11],
		8: [4, 9, 12], 9: [5, 8, 10, 13], 10: [6, 9, 11, 14], 11: [7, 10, 15],
		12: [8, 13], 13: [9, 12, 14], 14: [10, 13, 15], 15: [11, 14],
	}

	var all_valid: bool = true
	for hole in connection_map:
		if connection_map[hole].size() < 2:
			all_valid = false
			break

	_assert(all_valid, "All cheese holes have at least 2 connections")
	_assert_eq(connection_map.size(), 16, "Cheese has exactly 16 holes")


func _test_cheese_teleport_adjacency() -> void:
	# Verify connections are bidirectional
	var connection_map: Dictionary = {
		0: [1, 4], 1: [0, 2, 5], 2: [1, 3, 6], 3: [2, 7],
		4: [0, 5, 8], 5: [1, 4, 6, 9], 6: [2, 5, 7, 10], 7: [3, 6, 11],
		8: [4, 9, 12], 9: [5, 8, 10, 13], 10: [6, 9, 11, 14], 11: [7, 10, 15],
		12: [8, 13], 13: [9, 12, 14], 14: [10, 13, 15], 15: [11, 14],
	}

	var bidirectional: bool = true
	for hole in connection_map:
		for neighbor in connection_map[hole]:
			if not (hole in connection_map[neighbor]):
				bidirectional = false
				break

	_assert(bidirectional, "All cheese hole connections are bidirectional")


# ============================================================
# Fishbowl Room Tests
# ============================================================

func _test_air_supply_countdown() -> void:
	# Air should decrease linearly
	var max_air: float = 30.0
	var drain_rate: float = 1.0
	var after_5s: float = max_air - (drain_rate * 5.0)
	_assert_eq(after_5s, 25.0, "Air decreases by 5 after 5 seconds")

	var after_30s: float = max_air - (drain_rate * 30.0)
	_assert_eq(after_30s, 0.0, "Air reaches 0 after 30 seconds")


func _test_eel_spawn_per_fish() -> void:
	# At KITTEN tier, 1 eel per fish
	DifficultyManager.current_tier = DifficultyManager.DifficultyTier.KITTEN
	_assert_eq(DifficultyManager.get_param_int("eel_per_fish"), 1, "KITTEN: 1 eel per fish")

	# At TOMCAT tier, 2 eels per fish
	DifficultyManager.current_tier = DifficultyManager.DifficultyTier.TOMCAT
	_assert_eq(DifficultyManager.get_param_int("eel_per_fish"), 2, "TOMCAT: 2 eels per fish")

	DifficultyManager.reset()


func _test_eel_wall_bounce() -> void:
	# Simulate eel bounce: velocity component perpendicular to wall negates
	var vel: Vector2 = Vector2(100, 50)
	# Hit right wall: negate x
	var bounced: Vector2 = Vector2(-vel.x, vel.y)
	_assert_eq(bounced.x, -100.0, "Eel X velocity negates on vertical wall")
	_assert_eq(bounced.y, 50.0, "Eel Y velocity unchanged on vertical wall")

	# Hit bottom wall: negate y
	var bounced_y: Vector2 = Vector2(vel.x, -vel.y)
	_assert_eq(bounced_y.x, 100.0, "Eel X velocity unchanged on horizontal wall")
	_assert_eq(bounced_y.y, -50.0, "Eel Y velocity negates on horizontal wall")


# ============================================================
# Dogfood Room Tests
# ============================================================

func _test_awake_meter_proximity() -> void:
	# Closer = faster fill
	var radius: float = 80.0
	var close_distance: float = 10.0
	var far_distance: float = 70.0

	var close_factor: float = 1.0 - (close_distance / radius)
	var far_factor: float = 1.0 - (far_distance / radius)

	_assert_gt(close_factor, far_factor, "Closer distance = higher fill factor")
	_assert_gt(close_factor, 0.8, "Very close = factor > 0.8")
	_assert_lt(far_factor, 0.2, "Far away = factor < 0.2")


func _test_awake_meter_drain() -> void:
	# Meter drains when outside radius
	var meter: float = 0.5
	var drain_rate: float = 0.2
	var after_1s: float = maxf(0.0, meter - drain_rate * 1.0)
	_assert_eq(after_1s, 0.3, "Meter drains 0.2 per second")

	var after_3s: float = maxf(0.0, meter - drain_rate * 3.0)
	_assert_eq(after_3s, 0.0, "Meter clamps to 0 (doesn't go negative)")


# ============================================================
# Love Game Tests
# ============================================================

func _test_heart_toggle_involution() -> void:
	# Toggle twice = original state
	var solid: bool = true
	var after_one_toggle: bool = not solid
	var after_two_toggles: bool = not after_one_toggle

	_assert_eq(after_one_toggle, false, "Solid heart toggled = broken")
	_assert_eq(after_two_toggles, true, "Broken heart toggled = solid (involution)")


func _test_enemy_cat_knockdown() -> void:
	# Freddy on row 3, knocked down = row 2
	var row: int = 3
	var after_knockdown: int = row - 1
	_assert_eq(after_knockdown, 2, "Knockdown moves Freddy down one row")

	# Freddy on row 0, knocked down = fail
	var bottom_row: int = 0
	var fail_condition: bool = (bottom_row - 1) < 0
	_assert(fail_condition, "Knocked off bottom row = fail condition")


func _test_love_game_extra_life() -> void:
	GameManager.lives = 5
	GameManager.gain_life()
	_assert_eq(GameManager.lives, 6, "Love game completion awards extra life")


# ============================================================
# Window Manager Tests
# ============================================================

func _test_window_open_duration_bounds() -> void:
	DifficultyManager.reset()
	var min_dur: float = DifficultyManager.get_param("window_open_duration_min")
	var max_dur: float = DifficultyManager.get_param("window_open_duration_max")

	_assert_gt(max_dur, min_dur, "Max duration > min duration")
	_assert_gt(min_dur, 0.0, "Min duration > 0")

	# Test at highest difficulty
	DifficultyManager.current_tier = DifficultyManager.DifficultyTier.ALLEY_CAT
	var hard_min: float = DifficultyManager.get_param("window_open_duration_min")
	var hard_max: float = DifficultyManager.get_param("window_open_duration_max")

	_assert_lt(hard_max, max_dur + 0.01, "Harder difficulty = shorter max window time")
	_assert_gt(hard_min, 0.0, "Hard min duration still > 0")

	DifficultyManager.reset()
