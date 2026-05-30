extends Control
## PlayerRegistration - UI for entering player name and email before playing.
## Shown on first launch or when player wants to change identity.

signal registration_complete()

@onready var _name_input: LineEdit = $Panel/VBox/NameInput
@onready var _email_input: LineEdit = $Panel/VBox/EmailInput
@onready var _play_button: Button = $Panel/VBox/PlayButton
@onready var _error_label: Label = $Panel/VBox/ErrorLabel
@onready var _skip_button: Button = $Panel/VBox/SkipButton


func _ready() -> void:
	if _play_button:
		_play_button.pressed.connect(_on_play_pressed)
	if _skip_button:
		_skip_button.pressed.connect(_on_skip_pressed)
	if _error_label:
		_error_label.visible = false

	# Pre-fill if player already registered
	if LeaderboardManager.is_player_registered():
		if _name_input:
			_name_input.text = LeaderboardManager.get_current_player_name()
		if _email_input:
			_email_input.text = LeaderboardManager.get_current_player_id()


func _on_play_pressed() -> void:
	var player_name: String = _name_input.text.strip_edges() if _name_input else ""
	var email: String = _email_input.text.strip_edges() if _email_input else ""

	if player_name.length() < 2:
		_show_error("Please enter a name (at least 2 characters)")
		return

	if email != "" and not _is_valid_email(email):
		_show_error("Please enter a valid email or leave it blank")
		return

	LeaderboardManager.register_player(player_name, email)
	_go_next()


func _on_skip_pressed() -> void:
	# Register as anonymous player
	LeaderboardManager.register_player("Player_%d" % (randi() % 9999))
	_go_next()


func _go_next() -> void:
	# If tutorial not completed, go to tutorial. Otherwise title screen.
	if not SaveManager.get_setting("tutorial_completed"):
		GameManager.change_state(GameManager.GameState.TUTORIAL)
	else:
		GameManager.change_state(GameManager.GameState.TITLE_SCREEN)


func _show_error(message: String) -> void:
	if _error_label:
		_error_label.text = message
		_error_label.visible = true
		# Auto-hide after 3 seconds
		get_tree().create_timer(3.0).timeout.connect(func(): 
			if _error_label:
				_error_label.visible = false
		)


func _is_valid_email(email: String) -> bool:
	# Basic email validation
	if email.length() < 5:
		return false
	if not "@" in email:
		return false
	var parts: PackedStringArray = email.split("@")
	if parts.size() != 2:
		return false
	if parts[0].length() == 0 or parts[1].length() < 3:
		return false
	if not "." in parts[1]:
		return false
	return true
