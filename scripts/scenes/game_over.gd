extends Control
## GameOverScreen - Displays final score, leaderboard rank, and share options.

@onready var _game_over_label: Label = $GameOverLabel
@onready var _score_label: Label = $ScoreLabel
@onready var _high_score_label: Label = $HighScoreLabel
@onready var _new_high_label: Label = $NewHighLabel
@onready var _rank_label: Label = $RankLabel
@onready var _restart_label: Label = $RestartLabel
@onready var _share_button: Button = $ShareButton
@onready var _leaderboard_button: Button = $LeaderboardButton

var _blink_timer: float = 0.0
var _input_delay: float = 1.5
var _player_rank: int = -1


func _ready() -> void:
	AudioManager.play_music("game_over")

	var score: int = ScoreManager.get_score()
	var high: int = ScoreManager.get_high_score()
	var is_new_high: bool = score >= high and score > 0

	if _score_label:
		_score_label.text = "SCORE: %d" % score

	if _high_score_label:
		_high_score_label.text = "HIGH SCORE: %d" % high

	if _new_high_label:
		_new_high_label.visible = is_new_high

	# Show leaderboard rank
	_player_rank = LeaderboardManager.get_player_rank()
	if _rank_label:
		if _player_rank > 0:
			_rank_label.text = "Leaderboard Rank: #%d of %d players" % [_player_rank, LeaderboardManager.get_total_players()]
			_rank_label.visible = true
		else:
			_rank_label.visible = false

	# Connect buttons
	if _share_button:
		_share_button.pressed.connect(_on_share_pressed)
	if _leaderboard_button:
		_leaderboard_button.pressed.connect(_on_leaderboard_pressed)


func _process(delta: float) -> void:
	_input_delay -= delta
	_blink_timer += delta
	if _restart_label and _input_delay <= 0:
		_restart_label.visible = fmod(_blink_timer, 1.0) < 0.7
	elif _restart_label:
		_restart_label.visible = false


func _input(event: InputEvent) -> void:
	if _input_delay > 0:
		return

	if event is InputEventScreenTouch and event.pressed:
		# Check if touch is not on a button
		if _share_button and _share_button.get_global_rect().has_point(event.position):
			return
		if _leaderboard_button and _leaderboard_button.get_global_rect().has_point(event.position):
			return
		_restart()
	elif event is InputEventMouseButton and event.pressed:
		_restart()


func _on_share_pressed() -> void:
	var score: int = ScoreManager.get_score()
	LeaderboardManager.share_score(score, _player_rank)


func _on_leaderboard_pressed() -> void:
	GameManager.change_state(GameManager.GameState.LEADERBOARD)


func _restart() -> void:
	GameManager.reset_game()
	GameManager.change_state(GameManager.GameState.TITLE_SCREEN)
