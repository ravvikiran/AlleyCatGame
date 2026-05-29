extends Node2D
## LoveGame - Bonus stage with heart platforms, enemy cats, and Cupid arrows.
## Navigate 7 rows of hearts to reach Felicia at the top.

const ROW_COUNT: int = 7
const HEARTS_PER_ROW: int = 8
const HEART_SPACING: float = 200.0
const ROW_SPACING: float = 120.0
const ROW_START_Y: float = 780.0
const ROW_START_X: float = 200.0

const ENEMY_CAT_SPEED: float = 150.0
const CUPID_SHOOT_INTERVAL: float = 3.0
const ARROW_SPEED: float = 300.0
const GIFT_ELIMINATE_DURATION: float = 5.0

var _hearts: Array = []  # 2D array [row][col] = {solid: bool, position: Vector2}
var _enemy_cats: Array = []  # Array of {position, row, direction, eliminated_timer}
var _arrows: Array = []  # Array of {position, velocity}
var _player: Freddy
var _player_row: int = 0
var _has_gift: bool = true
var _gift_position: Vector2 = Vector2.ZERO
var _gift_dropped: bool = false
var _cupid_timer: float = 0.0
var _is_complete: bool = false


func _ready() -> void:
	_player = $Freddy
	_setup_hearts()
	_setup_enemy_cats()
	_setup_player_input()
	AudioManager.play_music("love_game")

	# Show action button for dropping gift
	var touch: CanvasLayer = $UILayer/TouchController
	if touch:
		touch.show_action_button()


func _setup_hearts() -> void:
	for row in range(ROW_COUNT):
		var row_hearts: Array = []
		for col in range(HEARTS_PER_ROW):
			var heart: Dictionary = {
				"solid": true,
				"position": Vector2(
					ROW_START_X + col * HEART_SPACING,
					ROW_START_Y - row * ROW_SPACING
				),
			}
			# Randomly break some hearts (more broken at higher difficulty)
			if randf() < 0.2 + DifficultyManager.current_tier * 0.05:
				heart["solid"] = false
			row_hearts.append(heart)
		_hearts.append(row_hearts)

	# Ensure bottom row is all solid (starting platform)
	for heart in _hearts[0]:
		heart["solid"] = true


func _setup_enemy_cats() -> void:
	# One enemy cat per row (except bottom and top)
	for row in range(1, ROW_COUNT - 1):
		var cat: Dictionary = {
			"position": Vector2(
				randf_range(ROW_START_X, ROW_START_X + HEARTS_PER_ROW * HEART_SPACING),
				ROW_START_Y - row * ROW_SPACING - 30
			),
			"row": row,
			"direction": 1.0 if randf() > 0.5 else -1.0,
			"eliminated_timer": 0.0,
			"active": true,
		}
		_enemy_cats.append(cat)


func _setup_player_input() -> void:
	var touch: CanvasLayer = $UILayer/TouchController
	if touch:
		touch.move_input.connect(func(dir): _player.input_direction = dir)
		touch.jump_pressed.connect(func():
			_player.is_jump_pressed = true
			get_tree().create_timer(0.05).timeout.connect(func(): _player.is_jump_pressed = false)
		)
		touch.action_pressed.connect(_on_action_pressed)

	_player.position = Vector2(960, ROW_START_Y - 30)
	_player_row = 0


func _on_action_pressed() -> void:
	if _has_gift and not _gift_dropped:
		_drop_gift()


func _drop_gift() -> void:
	_gift_dropped = true
	_has_gift = false
	_gift_position = _player.position


func _process(delta: float) -> void:
	if _is_complete:
		return

	_update_enemy_cats(delta)
	_update_cupids(delta)
	_update_arrows(delta)
	_check_collisions()
	_update_gift(delta)
	_check_platform()
	_check_felicia()


func _update_enemy_cats(delta: float) -> void:
	var tracking_accuracy: float = DifficultyManager.get_param("cat_accuracy")

	for cat in _enemy_cats:
		if not cat["active"]:
			# Check if elimination timer expired
			cat["eliminated_timer"] -= delta
			if cat["eliminated_timer"] <= 0:
				cat["active"] = true
			continue

		# Track Freddy's X with accuracy factor
		var target_x: float = lerpf(cat["position"].x, _player.position.x, tracking_accuracy)
		var diff: float = target_x - cat["position"].x
		cat["position"].x += sign(diff) * ENEMY_CAT_SPEED * delta

		# Clamp to screen
		cat["position"].x = clampf(cat["position"].x, ROW_START_X, ROW_START_X + HEARTS_PER_ROW * HEART_SPACING)


func _update_cupids(delta: float) -> void:
	_cupid_timer += delta
	if _cupid_timer >= CUPID_SHOOT_INTERVAL:
		_cupid_timer = 0.0
		_shoot_arrow()


func _shoot_arrow() -> void:
	# Shoot from left or right edge
	var from_left: bool = randf() > 0.5
	var start_x: float = 50.0 if from_left else 1870.0
	var start_y: float = randf_range(200, 700)
	var angle: float = -PI / 4.0 if from_left else -3.0 * PI / 4.0  # 45 degrees diagonal

	var arrow: Dictionary = {
		"position": Vector2(start_x, start_y),
		"velocity": Vector2.from_angle(angle) * ARROW_SPEED,
	}
	_arrows.append(arrow)


func _update_arrows(delta: float) -> void:
	var to_remove: Array = []

	for arrow in _arrows:
		arrow["position"] += arrow["velocity"] * delta

		# Check if arrow hit a heart
		for row in _hearts:
			for heart in row:
				if arrow["position"].distance_to(heart["position"]) < 40.0:
					heart["solid"] = not heart["solid"]
					to_remove.append(arrow)
					break

		# Check if arrow hit Freddy
		if _player.position.distance_to(arrow["position"]) < 30.0:
			_knock_down_row()
			to_remove.append(arrow)

		# Remove if off screen
		if arrow["position"].x < -50 or arrow["position"].x > 2000 or arrow["position"].y < -50 or arrow["position"].y > 1200:
			to_remove.append(arrow)

	for arrow in to_remove:
		_arrows.erase(arrow)


func _check_collisions() -> void:
	# Check enemy cat collisions
	for cat in _enemy_cats:
		if not cat["active"]:
			continue

		if _player.position.distance_to(cat["position"]) < 45.0:
			_knock_down_row()
			return


func _update_gift(delta: float) -> void:
	if not _gift_dropped:
		return

	# Check if enemy cat hits the gift
	for cat in _enemy_cats:
		if not cat["active"]:
			continue

		if _gift_position.distance_to(cat["position"]) < 50.0:
			# Eliminate both
			cat["active"] = false
			cat["eliminated_timer"] = GIFT_ELIMINATE_DURATION
			_gift_dropped = false
			_gift_position = Vector2.ZERO
			return


func _check_platform() -> void:
	# Determine which row Freddy is on based on Y position
	var best_row: int = 0
	var min_diff: float = INF

	for row in range(ROW_COUNT):
		var row_y: float = ROW_START_Y - row * ROW_SPACING
		var diff: float = abs(_player.position.y - (row_y - 30))
		if diff < min_diff:
			min_diff = diff
			best_row = row

	_player_row = best_row

	# Check if standing on a broken heart
	if _player_row < ROW_COUNT:
		var col: int = _get_heart_column(_player.position.x)
		if col >= 0 and col < HEARTS_PER_ROW:
			if not _hearts[_player_row][col]["solid"]:
				_knock_down_row()


func _get_heart_column(x: float) -> int:
	return int((x - ROW_START_X + HEART_SPACING / 2.0) / HEART_SPACING)


func _knock_down_row() -> void:
	if _player_row <= 0:
		# Fell off bottom - fail the stage
		_fail_love_game()
		return

	_player_row -= 1
	_player.position.y = ROW_START_Y - _player_row * ROW_SPACING - 30
	_player.velocity.y = 0


func _check_felicia() -> void:
	# Felicia is at the top row center
	var felicia_pos: Vector2 = Vector2(960, ROW_START_Y - (ROW_COUNT - 1) * ROW_SPACING - 30)

	if _player_row == ROW_COUNT - 1 and _player.position.distance_to(felicia_pos) < 60.0:
		_complete_love_game()


func _complete_love_game() -> void:
	_is_complete = true

	# Apply multiplier if gift was delivered
	ScoreManager.set_love_multiplier(not _gift_dropped and _has_gift)
	ScoreManager.award_points(ScoreManager.ScoreEvent.LOVE_GAME_COMPLETE)

	# Award extra life and advance difficulty
	GameManager.complete_love_game()


func _fail_love_game() -> void:
	# Return to alleyway without bonus
	GameManager.change_state(GameManager.GameState.ALLEYWAY_HUB)
