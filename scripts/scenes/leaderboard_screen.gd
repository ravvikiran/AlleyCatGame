extends Control
## LeaderboardScreen - Displays local leaderboard with share options.

@onready var _entries_container: VBoxContainer = $Panel/ScrollContainer/EntriesContainer
@onready var _player_rank_label: Label = $Panel/PlayerRankLabel
@onready var _share_button: Button = $Panel/ButtonsContainer/ShareButton
@onready var _export_button: Button = $Panel/ButtonsContainer/ExportButton
@onready var _back_button: Button = $Panel/ButtonsContainer/BackButton
@onready var _toast_label: Label = $Panel/ToastLabel


func _ready() -> void:
	if _share_button:
		_share_button.pressed.connect(_on_share_pressed)
	if _export_button:
		_export_button.pressed.connect(_on_export_pressed)
	if _back_button:
		_back_button.pressed.connect(_on_back_pressed)
	if _toast_label:
		_toast_label.visible = false

	_populate_leaderboard()
	_show_player_rank()


func _populate_leaderboard() -> void:
	if not _entries_container:
		return

	# Clear existing entries
	for child in _entries_container.get_children():
		child.queue_free()

	var top_scores: Array = LeaderboardManager.get_top_scores(20)

	if top_scores.size() == 0:
		var empty_label := Label.new()
		empty_label.text = "No scores yet! Play a game to get on the board."
		empty_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		_entries_container.add_child(empty_label)
		return

	# Header
	var header := _create_entry_row("RANK", "PLAYER", "SCORE", "DIFFICULTY", "DATE", true)
	_entries_container.add_child(header)

	# Add separator
	var sep := HSeparator.new()
	_entries_container.add_child(sep)

	# Entries
	for i in range(top_scores.size()):
		var entry: Dictionary = top_scores[i]
		var rank_text: String = ""
		match i:
			0: rank_text = "🥇"
			1: rank_text = "🥈"
			2: rank_text = "🥉"
			_: rank_text = "#%d" % (i + 1)

		var is_current: bool = entry.get("player_id", "") == LeaderboardManager.get_current_player_id()
		var row := _create_entry_row(
			rank_text,
			entry.get("name", "Unknown"),
			str(entry.get("score", 0)),
			entry.get("difficulty", ""),
			entry.get("date", "").substr(0, 10),
			false,
			is_current
		)
		_entries_container.add_child(row)


func _create_entry_row(rank: String, name: String, score: String, difficulty: String, date: String, is_header: bool, is_highlighted: bool = false) -> HBoxContainer:
	var row := HBoxContainer.new()
	row.custom_minimum_size.y = 35

	var rank_label := Label.new()
	rank_label.text = rank
	rank_label.custom_minimum_size.x = 60
	rank_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER

	var name_label := Label.new()
	name_label.text = name
	name_label.custom_minimum_size.x = 200
	name_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL

	var score_label := Label.new()
	score_label.text = score
	score_label.custom_minimum_size.x = 100
	score_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT

	var diff_label := Label.new()
	diff_label.text = difficulty
	diff_label.custom_minimum_size.x = 120
	diff_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER

	var date_label := Label.new()
	date_label.text = date
	date_label.custom_minimum_size.x = 120
	date_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT

	if is_highlighted:
		var highlight_color := Color(0, 1, 1, 1)
		rank_label.add_theme_color_override("font_color", highlight_color)
		name_label.add_theme_color_override("font_color", highlight_color)
		score_label.add_theme_color_override("font_color", highlight_color)
		diff_label.add_theme_color_override("font_color", highlight_color)
		date_label.add_theme_color_override("font_color", highlight_color)

	if is_header:
		var header_color := Color(0.7, 0.7, 0.7, 1)
		rank_label.add_theme_color_override("font_color", header_color)
		name_label.add_theme_color_override("font_color", header_color)
		score_label.add_theme_color_override("font_color", header_color)
		diff_label.add_theme_color_override("font_color", header_color)
		date_label.add_theme_color_override("font_color", header_color)

	row.add_child(rank_label)
	row.add_child(name_label)
	row.add_child(score_label)
	row.add_child(diff_label)
	row.add_child(date_label)

	return row


func _show_player_rank() -> void:
	if not _player_rank_label:
		return

	var rank: int = LeaderboardManager.get_player_rank()
	var best: int = LeaderboardManager.get_player_best_score()
	var name: String = LeaderboardManager.get_current_player_name()

	if rank > 0:
		_player_rank_label.text = "You: %s | Rank #%d | Best: %d pts" % [name, rank, best]
	else:
		_player_rank_label.text = "You: %s | No scores yet" % name


func _on_share_pressed() -> void:
	var best: int = LeaderboardManager.get_player_best_score()
	var rank: int = LeaderboardManager.get_player_rank()
	LeaderboardManager.share_score(best, rank)
	_show_toast("Score shared!")


func _on_export_pressed() -> void:
	var path: String = LeaderboardManager.export_leaderboard_to_file()
	if path != "":
		# Share the leaderboard text
		var text: String = LeaderboardManager.get_leaderboard_as_text()
		LeaderboardManager.share_score(0, 0)  # Will use share intent
		_show_toast("Leaderboard exported!")
	else:
		_show_toast("Export failed")


func _on_back_pressed() -> void:
	GameManager.change_state(GameManager.GameState.TITLE_SCREEN)


func _show_toast(message: String) -> void:
	if _toast_label:
		_toast_label.text = message
		_toast_label.visible = true
		get_tree().create_timer(2.0).timeout.connect(func():
			if _toast_label:
				_toast_label.visible = false
		)
