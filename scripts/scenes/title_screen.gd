extends Control
## TitleScreen - Game title, high score display, leaderboard access, and start interaction.

@onready var _title_label: Label = $TitleLabel
@onready var _high_score_label: Label = $HighScoreLabel
@onready var _start_label: Label = $StartLabel
@onready var _difficulty_label: Label = $DifficultyLabel
@onready var _player_label: Label = $PlayerLabel
@onready var _leaderboard_button: Button = $LeaderboardButton
@onready var _tutorial_button: Button = $TutorialButton

var _blink_timer: float = 0.0
var _is_first_launch: bool = false


func _ready() -> void:
	AudioManager.play_music("title")

	# Check if this is first launch (no tutorial completed)
	_is_first_launch = not SaveManager.get_setting("tutorial_completed")

	# Load and display high score
	var high_score: int = ScoreManager.get_high_score()
	if _high_score_label:
		_high_score_label.text = "HIGH SCORE: %d" % high_score

	if _difficulty_label:
		_difficulty_label.text = "Difficulty: %s" % DifficultyManager.get_tier_name()

	# Show player name if registered
	if _player_label:
		if LeaderboardManager.is_player_registered():
			_player_label.text = "Player: %s" % LeaderboardManager.get_current_player_name()
			_player_label.visible = true
		else:
			_player_label.visible = false

	# Connect buttons
	if _leaderboard_button:
		_leaderboard_button.pressed.connect(_on_leaderboard_pressed)
	if _tutorial_button:
		_tutorial_button.pressed.connect(_on_tutorial_pressed)

	# Auto-launch tutorial on first ever launch
	if _is_first_launch and not LeaderboardManager.is_player_registered():
		# Small delay then go to registration → tutorial
		get_tree().create_timer(0.5).timeout.connect(func():
			GameManager.change_state(GameManager.GameState.PLAYER_REGISTRATION)
		)


func _process(delta: float) -> void:
	_blink_timer += delta
	if _start_label:
		_start_label.visible = fmod(_blink_timer, 1.0) < 0.7


func _input(event: InputEvent) -> void:
	# Don't process taps if auto-launching registration
	if _is_first_launch and not LeaderboardManager.is_player_registered():
		return

	if event is InputEventScreenTouch and event.pressed:
		# Ignore taps on buttons
		if _leaderboard_button and _leaderboard_button.get_global_rect().has_point(event.position):
			return
		if _tutorial_button and _tutorial_button.get_global_rect().has_point(event.position):
			return
		_try_start_game()
	elif event is InputEventMouseButton and event.pressed:
		_try_start_game()


func _try_start_game() -> void:
	# If player not registered, show registration first
	if not LeaderboardManager.is_player_registered():
		GameManager.change_state(GameManager.GameState.PLAYER_REGISTRATION)
		return

	# If tutorial never completed, show it first
	if not SaveManager.get_setting("tutorial_completed"):
		GameManager.change_state(GameManager.GameState.TUTORIAL)
		return

	_start_game()


func _start_game() -> void:
	GameManager.reset_game()
	GameManager.change_state(GameManager.GameState.ALLEYWAY_HUB)


func _on_leaderboard_pressed() -> void:
	GameManager.change_state(GameManager.GameState.LEADERBOARD)


func _on_tutorial_pressed() -> void:
	GameManager.change_state(GameManager.GameState.TUTORIAL)
