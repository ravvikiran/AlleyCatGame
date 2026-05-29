extends Control
## HUD - Displays score, lives, high score, and contextual meters.

var _score_label: Label
var _high_score_label: Label
var _lives_container: HBoxContainer
var _air_meter: ProgressBar
var _difficulty_label: Label

var _air_meter_visible: bool = false


func _ready() -> void:
	# Find nodes safely
	_score_label = get_node_or_null("ScoreLabel") as Label
	_high_score_label = get_node_or_null("HighScoreLabel") as Label
	_lives_container = get_node_or_null("LivesContainer") as HBoxContainer
	_air_meter = get_node_or_null("AirMeter") as ProgressBar
	_difficulty_label = get_node_or_null("DifficultyLabel") as Label

	# Connect signals
	ScoreManager.score_changed.connect(_on_score_changed)
	GameManager.lives_changed.connect(_on_lives_changed)

	# Initial display
	_update_score(ScoreManager.get_score())
	_update_high_score(ScoreManager.get_high_score())
	_update_lives(GameManager.lives)
	_update_difficulty()

	if _air_meter:
		_air_meter.visible = false


func _on_score_changed(new_score: int) -> void:
	_update_score(new_score)


func _on_lives_changed(new_lives: int) -> void:
	_update_lives(new_lives)


func _update_score(score: int) -> void:
	if _score_label:
		_score_label.text = "SCORE: %d" % score


func _update_high_score(high: int) -> void:
	if _high_score_label:
		_high_score_label.text = "HI: %d" % high


func _update_lives(lives: int) -> void:
	if not _lives_container:
		return

	# Clear existing life icons
	for child in _lives_container.get_children():
		child.queue_free()

	# Add life icons as colored squares (placeholder for cat head sprites)
	for i in range(mini(lives, 15)):  # Cap display at 15
		var icon := ColorRect.new()
		icon.custom_minimum_size = Vector2(20, 20)
		icon.color = Color(0, 1, 1, 1)  # Cyan like Freddy
		_lives_container.add_child(icon)


func _update_difficulty() -> void:
	if _difficulty_label:
		_difficulty_label.text = DifficultyManager.get_tier_name()


func show_air_meter() -> void:
	_air_meter_visible = true
	if _air_meter:
		_air_meter.visible = true


func hide_air_meter() -> void:
	_air_meter_visible = false
	if _air_meter:
		_air_meter.visible = false


func update_air_meter(percentage: float) -> void:
	if _air_meter and _air_meter_visible:
		_air_meter.value = percentage * 100.0
