extends Node2D
## Tutorial - Interactive guided tutorial with step-by-step instructions.
## Player can practice each mechanic in a safe sandbox environment.

signal tutorial_completed()

enum TutorialStep {
	WELCOME,
	MOVE_LEFT_RIGHT,
	JUMP_STANDING,
	JUMP_RUNNING,
	CLIMB_HANG,
	ENTER_WINDOW,
	MINIGAME_INTRO,
	ACTION_BUTTON,
	HAZARDS_INTRO,
	LOVE_GAME_INTRO,
	COMPLETE,
}

const STEP_DATA: Dictionary = {
	TutorialStep.WELCOME: {
		"title": "Welcome to Midnight Prowl!",
		"description": "You are Freddy, a scrappy stray cat on a quest for love.\nLet's learn the basics!",
		"action": "Tap anywhere to continue",
		"show_controls": false,
		"auto_advance": false,
	},
	TutorialStep.MOVE_LEFT_RIGHT: {
		"title": "Moving Around",
		"description": "Use the joystick on the LEFT side of the screen\nto move Freddy left and right.",
		"action": "Try moving left and right!",
		"show_controls": true,
		"auto_advance": false,
		"goal": "move",
		"goal_distance": 200.0,
	},
	TutorialStep.JUMP_STANDING: {
		"title": "Standing Jump",
		"description": "Tap the JUMP button on the right side\nwhile standing still for a short hop.",
		"action": "Try a standing jump!",
		"show_controls": true,
		"auto_advance": false,
		"goal": "jump_standing",
	},
	TutorialStep.JUMP_RUNNING: {
		"title": "Running Jump",
		"description": "Hold the joystick to run, then tap JUMP\nfor a longer, higher leap!",
		"action": "Try a running jump!",
		"show_controls": true,
		"auto_advance": false,
		"goal": "jump_running",
	},
	TutorialStep.CLIMB_HANG: {
		"title": "Climbing & Hanging",
		"description": "Jump toward a clothesline or ledge to grab on.\nPush UP to climb, DOWN to drop.",
		"action": "Jump toward the clothesline above!",
		"show_controls": true,
		"auto_advance": false,
		"goal": "hang",
	},
	TutorialStep.ENTER_WINDOW: {
		"title": "Entering Windows",
		"description": "Open windows glow blue. Jump INTO them\nwhile falling downward to enter a room.",
		"action": "Jump into the open window!",
		"show_controls": true,
		"auto_advance": false,
		"goal": "enter_window",
	},
	TutorialStep.MINIGAME_INTRO: {
		"title": "Minigame Rooms",
		"description": "Each window leads to a unique challenge:\n• Cheese Maze - Catch mice\n• Library - Dodge the spider\n• Kennel - Sneak past sleeping dogs\n• Aquarium - Swim and eat fish\n• Aviary - Free and catch the bird",
		"action": "Tap to continue",
		"show_controls": false,
		"auto_advance": false,
	},
	TutorialStep.ACTION_BUTTON: {
		"title": "Action Button",
		"description": "In some rooms, an ACTION button appears.\nUse it to teleport, drink, or drop items.",
		"action": "Try pressing the Action button!",
		"show_controls": true,
		"show_action": true,
		"auto_advance": false,
		"goal": "action",
	},
	TutorialStep.HAZARDS_INTRO: {
		"title": "Watch Out for Hazards!",
		"description": "🐕 Dogs on the street = instant death\n🧹 Brooms push you around\n🕷️ Spiders drop from above\n⚡ Eels zap underwater\n📦 Objects thrown from windows hurt!",
		"action": "Tap to continue",
		"show_controls": false,
		"auto_advance": false,
	},
	TutorialStep.LOVE_GAME_INTRO: {
		"title": "The Love Game",
		"description": "After completing a room, Felicia calls from a window!\nEnter her window for the bonus Love Game stage.\nReach the top to win her heart. 💕",
		"action": "Tap to continue",
		"show_controls": false,
		"auto_advance": false,
	},
	TutorialStep.COMPLETE: {
		"title": "You're Ready!",
		"description": "Good luck out there, Freddy!\nRemember: explore, avoid hazards,\ncomplete rooms, and find Felicia!",
		"action": "Tap to start playing!",
		"show_controls": false,
		"auto_advance": false,
	},
}

var _current_step: TutorialStep = TutorialStep.WELCOME
var _player: CharacterBody2D
var _touch_controller: CanvasLayer
var _instruction_panel: Control
var _title_label: Label
var _description_label: Label
var _action_label: Label
var _progress_label: Label
var _skip_button: Button
var _highlight_rect: ColorRect

# Goal tracking
var _total_move_distance: float = 0.0
var _last_player_x: float = 0.0
var _has_jumped_standing: bool = false
var _has_jumped_running: bool = false
var _has_hung: bool = false
var _has_entered_window: bool = false
var _has_used_action: bool = false
var _player_was_on_floor: bool = true


func _ready() -> void:
	_player = $Freddy
	_touch_controller = $UILayer/TouchController
	_instruction_panel = $UILayer/InstructionPanel
	_title_label = $UILayer/InstructionPanel/VBox/TitleLabel
	_description_label = $UILayer/InstructionPanel/VBox/DescriptionLabel
	_action_label = $UILayer/InstructionPanel/VBox/ActionLabel
	_progress_label = $UILayer/InstructionPanel/ProgressLabel
	_skip_button = $UILayer/InstructionPanel/SkipButton
	_highlight_rect = $UILayer/HighlightRect

	# Connect inputs
	if _touch_controller:
		_touch_controller.move_input.connect(_on_move_input)
		_touch_controller.jump_pressed.connect(_on_jump_pressed)
		_touch_controller.action_pressed.connect(_on_action_pressed)

	if _skip_button:
		_skip_button.pressed.connect(_on_skip_pressed)

	if _player:
		_last_player_x = _player.position.x

	_show_step(_current_step)


func _process(delta: float) -> void:
	_check_goal_completion(delta)
	_update_progress_label()


func _input(event: InputEvent) -> void:
	# Tap to advance on non-interactive steps
	var step_data: Dictionary = STEP_DATA.get(_current_step, {})
	if not step_data.get("goal", ""):
		if event is InputEventScreenTouch and event.pressed:
			_advance_step()
		elif event is InputEventMouseButton and event.pressed:
			_advance_step()


func _show_step(step: TutorialStep) -> void:
	var data: Dictionary = STEP_DATA.get(step, {})
	if data.is_empty():
		return

	if _title_label:
		_title_label.text = data.get("title", "")
	if _description_label:
		_description_label.text = data.get("description", "")
	if _action_label:
		_action_label.text = "→ %s" % data.get("action", "")

	# Show/hide controls
	if _touch_controller:
		_touch_controller.visible = data.get("show_controls", false)
		if data.get("show_action", false):
			_touch_controller.show_action_button()
		else:
			_touch_controller.hide_action_button()

	# Show highlight for relevant area
	_update_highlight(step)

	# Reset goal tracking for this step
	_total_move_distance = 0.0
	_has_jumped_standing = false
	_has_jumped_running = false
	_has_hung = false
	_has_entered_window = false
	_has_used_action = false


func _advance_step() -> void:
	var next_step: int = _current_step + 1
	if next_step > TutorialStep.COMPLETE:
		_complete_tutorial()
		return

	_current_step = next_step as TutorialStep

	if _current_step == TutorialStep.COMPLETE:
		_show_step(_current_step)
	else:
		_show_step(_current_step)


func _check_goal_completion(delta: float) -> void:
	if not _player:
		return

	var step_data: Dictionary = STEP_DATA.get(_current_step, {})
	var goal: String = step_data.get("goal", "")

	match goal:
		"move":
			var dx: float = abs(_player.position.x - _last_player_x)
			_total_move_distance += dx
			_last_player_x = _player.position.x
			if _total_move_distance >= step_data.get("goal_distance", 200.0):
				_show_success("Great moving!")
				_advance_step()

		"jump_standing":
			if _has_jumped_standing:
				_show_success("Nice hop!")
				_advance_step()

		"jump_running":
			if _has_jumped_running:
				_show_success("Awesome leap!")
				_advance_step()

		"hang":
			if _has_hung:
				_show_success("You're hanging on!")
				_advance_step()

		"enter_window":
			if _has_entered_window:
				_show_success("You entered a window!")
				_advance_step()

		"action":
			if _has_used_action:
				_show_success("Action button works!")
				_advance_step()


func _on_move_input(direction: Vector2) -> void:
	if _player:
		_player.input_direction = direction


func _on_jump_pressed() -> void:
	if not _player:
		return

	_player.is_jump_pressed = true
	get_tree().create_timer(0.05).timeout.connect(func(): 
		if _player:
			_player.is_jump_pressed = false
	)

	# Track jump type
	if _player.is_on_floor():
		if _player.move_time >= Freddy.RUN_THRESHOLD_TIME:
			_has_jumped_running = true
		else:
			_has_jumped_standing = true


func _on_action_pressed() -> void:
	_has_used_action = true
	if _player:
		_player.is_action_pressed = true


func _on_skip_pressed() -> void:
	_complete_tutorial()


func _complete_tutorial() -> void:
	# Mark tutorial as seen
	SaveManager.set_setting("tutorial_completed", true)
	SaveManager.save()
	tutorial_completed.emit()
	GameManager.change_state(GameManager.GameState.ALLEYWAY_HUB)


func _show_success(message: String) -> void:
	if _action_label:
		_action_label.text = "✓ %s" % message
	# Brief pause before advancing
	await get_tree().create_timer(0.8).timeout


func _update_highlight(step: TutorialStep) -> void:
	if not _highlight_rect:
		return

	# Position a highlight rectangle to draw attention to relevant UI
	match step:
		TutorialStep.MOVE_LEFT_RIGHT:
			# Highlight joystick area
			_highlight_rect.visible = true
			_highlight_rect.position = Vector2(20, 700)
			_highlight_rect.size = Vector2(200, 200)
			_highlight_rect.color = Color(0, 1, 1, 0.1)
		TutorialStep.JUMP_STANDING, TutorialStep.JUMP_RUNNING:
			# Highlight jump button area
			_highlight_rect.visible = true
			_highlight_rect.position = Vector2(1650, 750)
			_highlight_rect.size = Vector2(150, 150)
			_highlight_rect.color = Color(0, 0.8, 1, 0.1)
		TutorialStep.ACTION_BUTTON:
			# Highlight action button area
			_highlight_rect.visible = true
			_highlight_rect.position = Vector2(1650, 550)
			_highlight_rect.size = Vector2(150, 150)
			_highlight_rect.color = Color(1, 0.5, 0, 0.1)
		_:
			_highlight_rect.visible = false


func _update_progress_label() -> void:
	if _progress_label:
		var total: int = TutorialStep.COMPLETE
		var current: int = _current_step
		_progress_label.text = "Step %d / %d" % [current + 1, total + 1]
