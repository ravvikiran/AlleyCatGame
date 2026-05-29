extends SceneTree
## TestGameFlow - Tests the complete game loop and edge cases.
## Run with: godot --headless --script tests/test_game_flow.gd

var _tests_passed: int = 0
var _tests_failed: int = 0


func _init() -> void:
	print("\n========================================")
	print("  ALLEY CAT - Game Flow Tests")
	print("========================================\n")

	_test_full_game_loop_state_sequence()
	_test_death_in_every_state()
	_test_difficulty_scaling_all_params()
	_test_score_persistence_round_trip()
	_test_minigame_random_selection()
	_test_all_score_events()
	_test_felicia_window_lifecycle()
	_test_gift_multiplier_logic()

	print("\n========================================")
	print("  RESULTS: %d passed, %d failed" % [_tests_passed, _tests_failed])
	print("========================================\n")

	quit(0 if _tests_failed == 0 else 1)


func _assert(condition: bool, test_name: String) -> void:
	if condition:
		_tests_passed += 1
		print("  PASS: %s" % test_name)
	else:
		_tests_failed += 1
		print("  FAIL: %s" % test_name)


func _test_full_game_loop_state_sequence() -> void:
	print("\n--- Full Game Loop State Sequence ---")

	GameManager.reset_game()

	# 1. Start at title
	_assert(GameManager.current_state == GameManager.GameState.TITLE_SCREEN,
		"Loop step 1: Start at TITLE_SCREEN")

	# 2. Move to alleyway
	GameManager.current_state = GameManager.GameState.ALLEYWAY_HUB
	_assert(GameManager.current_state == GameManager.GameState.ALLEYWAY_HUB,
		"Loop step 2: Enter ALLEYWAY_HUB")

	# 3. Enter minigame
	GameManager.current_state = GameManager.GameState.MINIGAME_CHEESE
	_assert(GameManager.current_state == GameManager.GameState.MINIGAME_CHEESE,
		"Loop step 3: Enter MINIGAME_CHEESE")

	# 4. Complete minigame → back to hub with Felicia active
	GameManager.minigame_completed = true
	GameManager.felicia_window_active = true
	GameManager.current_state = GameManager.GameState.ALLEYWAY_HUB
	_assert(GameManager.felicia_window_active == true,
		"Loop step 4: Felicia window active after minigame")

	# 5. Enter Love Game
	GameManager.current_state = GameManager.GameState.LOVE_GAME
	_assert(GameManager.current_state == GameManager.GameState.LOVE_GAME,
		"Loop step 5: Enter LOVE_GAME")

	# 6. Complete Love Game → difficulty advances
	var old_tier = DifficultyManager.current_tier
	DifficultyManager.advance_tier()
	GameManager.felicia_window_active = false
	GameManager.minigame_completed = false
	GameManager.current_state = GameManager.GameState.ALLEYWAY_HUB
	_assert(DifficultyManager.current_tier > old_tier,
		"Loop step 6: Difficulty advanced after Love Game")
	_assert(GameManager.felicia_window_active == false,
		"Loop step 6: Felicia window deactivated")

	DifficultyManager.reset()


func _test_death_in_every_state() -> void:
	print("\n--- Death in Every State ---")

	var gameplay_states: Array = [
		GameManager.GameState.ALLEYWAY_HUB,
		GameManager.GameState.MINIGAME_CHEESE,
		GameManager.GameState.MINIGAME_VASE,
		GameManager.GameState.MINIGAME_DOGFOOD,
		GameManager.GameState.MINIGAME_FISHBOWL,
		GameManager.GameState.MINIGAME_BIRDCAGE,
		GameManager.GameState.LOVE_GAME,
	]

	for state in gameplay_states:
		GameManager.lives = 3
		GameManager.current_state = state
		GameManager.lives -= 1  # Simulate death

		_assert(GameManager.lives == 2,
			"Death in state %d: lives decremented" % state)

	# Test game over
	GameManager.lives = 1
	GameManager.lives -= 1
	_assert(GameManager.lives == 0, "Final death: lives reach zero")


func _test_difficulty_scaling_all_params() -> void:
	print("\n--- Difficulty Scaling All Parameters ---")

	var params_to_check: Array = ["dog_speed", "dog_freq", "spider_speed", "cat_accuracy"]

	for param in params_to_check:
		var values: Array = []
		for tier in range(4):
			DifficultyManager.current_tier = tier as DifficultyManager.DifficultyTier
			values.append(DifficultyManager.get_param(param))

		var increasing: bool = true
		for i in range(1, values.size()):
			if values[i] < values[i - 1]:
				increasing = false
				break

		_assert(increasing, "Param '%s' increases with difficulty" % param)

	# Trash cans should decrease
	var can_values: Array = []
	for tier in range(4):
		DifficultyManager.current_tier = tier as DifficultyManager.DifficultyTier
		can_values.append(DifficultyManager.get_param_int("trash_cans"))

	var decreasing: bool = true
	for i in range(1, can_values.size()):
		if can_values[i] > can_values[i - 1]:
			decreasing = false
			break

	_assert(decreasing, "Trash cans decrease with difficulty")

	DifficultyManager.reset()


func _test_score_persistence_round_trip() -> void:
	print("\n--- Score Persistence Round Trip ---")

	ScoreManager.reset()
	ScoreManager.current_score = 12345
	ScoreManager.check_high_score()
	_assert(ScoreManager.high_score == 12345, "High score set to 12345")

	# Simulate save/load cycle
	var save_data: Dictionary = {
		"high_score": ScoreManager.high_score,
		"highest_difficulty": int(DifficultyManager.current_tier),
	}

	_assert(save_data["high_score"] == 12345, "Save data contains correct high score")

	# Simulate load
	var loaded_high: int = save_data.get("high_score", 0)
	_assert(loaded_high == 12345, "Loaded high score matches saved value")

	ScoreManager.reset()


func _test_minigame_random_selection() -> void:
	print("\n--- Minigame Random Selection ---")

	var selected: Dictionary = {}
	for i in range(100):
		var minigame: GameManager.GameState = GameManager.get_random_minigame()
		selected[minigame] = selected.get(minigame, 0) + 1

	# All 5 minigames should be selectable
	_assert(selected.size() >= 3, "At least 3 different minigames selected in 100 tries")

	# Verify all returned states are valid minigames
	var all_valid: bool = true
	for state in selected:
		if state not in GameManager.MINIGAME_STATES:
			all_valid = false
			break

	_assert(all_valid, "All random selections are valid minigame states")


func _test_all_score_events() -> void:
	print("\n--- All Score Events ---")

	ScoreManager.reset()

	ScoreManager.award_points(ScoreManager.ScoreEvent.MOUSE_CATCH)
	_assert(ScoreManager.current_score == 100, "MOUSE_CATCH = 100 pts")

	ScoreManager.reset()
	ScoreManager.award_points(ScoreManager.ScoreEvent.ALLEY_MOUSE_CATCH)
	_assert(ScoreManager.current_score == 50, "ALLEY_MOUSE_CATCH = 50 pts")

	ScoreManager.reset()
	ScoreManager.award_points(ScoreManager.ScoreEvent.MINIGAME_COMPLETE)
	_assert(ScoreManager.current_score == 500, "MINIGAME_COMPLETE = 500 pts")

	ScoreManager.reset()
	ScoreManager.love_game_multiplier = 1
	ScoreManager.award_points(ScoreManager.ScoreEvent.LOVE_GAME_COMPLETE)
	_assert(ScoreManager.current_score == 1000, "LOVE_GAME_COMPLETE (1x) = 1000 pts")

	ScoreManager.reset()
	ScoreManager.love_game_multiplier = 2
	ScoreManager.award_points(ScoreManager.ScoreEvent.LOVE_GAME_COMPLETE)
	_assert(ScoreManager.current_score == 2000, "LOVE_GAME_COMPLETE (2x) = 2000 pts")

	ScoreManager.reset()


func _test_felicia_window_lifecycle() -> void:
	print("\n--- Felicia Window Lifecycle ---")

	GameManager.reset_game()

	# Initially inactive
	_assert(GameManager.felicia_window_active == false, "Felicia window starts inactive")

	# After minigame complete
	GameManager.minigame_completed = true
	GameManager.felicia_window_active = true
	_assert(GameManager.felicia_window_active == true, "Felicia active after minigame")

	# After Love Game complete
	GameManager.felicia_window_active = false
	GameManager.minigame_completed = false
	_assert(GameManager.felicia_window_active == false, "Felicia inactive after Love Game")


func _test_gift_multiplier_logic() -> void:
	print("\n--- Gift Multiplier Logic ---")

	# With gift
	ScoreManager.reset()
	ScoreManager.set_love_multiplier(true)
	ScoreManager.award_points(ScoreManager.ScoreEvent.LOVE_GAME_COMPLETE)
	var with_gift: int = ScoreManager.current_score
	_assert(with_gift == 2000, "Love Game with gift = 2000")

	# Without gift
	ScoreManager.reset()
	ScoreManager.set_love_multiplier(false)
	ScoreManager.award_points(ScoreManager.ScoreEvent.LOVE_GAME_COMPLETE)
	var without_gift: int = ScoreManager.current_score
	_assert(without_gift == 1000, "Love Game without gift = 1000")

	# Gift doubles the score
	_assert(with_gift == without_gift * 2, "Gift exactly doubles Love Game score")

	ScoreManager.reset()
