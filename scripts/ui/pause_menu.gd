extends CanvasLayer
## PauseMenu - Overlay shown when game is paused.
## Handles Android back button and pause/resume lifecycle.

var _panel: Control
var _is_paused: bool = false


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	_panel = get_node_or_null("Panel")
	if _panel:
		_panel.visible = false

	# Connect buttons
	var resume_btn: Button = get_node_or_null("Panel/VBoxContainer/ResumeButton")
	var restart_btn: Button = get_node_or_null("Panel/VBoxContainer/RestartButton")
	var quit_btn: Button = get_node_or_null("Panel/VBoxContainer/QuitButton")

	if resume_btn:
		resume_btn.pressed.connect(_on_resume)
	if restart_btn:
		restart_btn.pressed.connect(_on_restart)
	if quit_btn:
		quit_btn.pressed.connect(_on_quit)


func _notification(what: int) -> void:
	match what:
		NOTIFICATION_APPLICATION_PAUSED:
			_pause_game()
		NOTIFICATION_APPLICATION_RESUMED:
			pass
		NOTIFICATION_WM_GO_BACK_REQUEST:
			if _is_paused:
				_on_resume()
			elif GameManager.current_state == GameManager.GameState.TITLE_SCREEN:
				SaveManager.save()
				get_tree().quit()
			else:
				_pause_game()


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		if _is_paused:
			_on_resume()
		else:
			_pause_game()


func _pause_game() -> void:
	if GameManager.current_state == GameManager.GameState.TITLE_SCREEN:
		return
	if GameManager.current_state == GameManager.GameState.GAME_OVER:
		return

	_is_paused = true
	if _panel:
		_panel.visible = true
	get_tree().paused = true


func _on_resume() -> void:
	_is_paused = false
	if _panel:
		_panel.visible = false
	get_tree().paused = false


func _on_restart() -> void:
	_is_paused = false
	if _panel:
		_panel.visible = false
	get_tree().paused = false
	GameManager.reset_game()
	GameManager.change_state(GameManager.GameState.ALLEYWAY_HUB)


func _on_quit() -> void:
	SaveManager.save()
	get_tree().quit()


func is_paused() -> bool:
	return _is_paused
