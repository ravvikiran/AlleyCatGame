extends CanvasLayer
## TouchController - Aggregates all touch input and exposes unified signals.
## Self-contained: handles all touch detection without requiring child scripts.

signal move_input(direction: Vector2)
signal jump_pressed()
signal jump_released()
signal action_pressed()
signal action_held(duration: float)
signal drop_requested()

# Joystick config
const JOYSTICK_DEAD_ZONE: float = 20.0
const JOYSTICK_MAX_RADIUS: float = 80.0
const DROP_THRESHOLD: float = 0.7

# Button config
const JUMP_BUTTON_RADIUS: float = 60.0
const ACTION_BUTTON_RADIUS: float = 50.0

# Touch tracking
var _joystick_touch: int = -1
var _jump_touch: int = -1
var _action_touch: int = -1
var _joystick_center: Vector2 = Vector2.ZERO
var _joystick_output: Vector2 = Vector2.ZERO
var _is_dropping: bool = false
var _action_press_time: float = 0.0

# Screen regions (calculated on ready)
var _screen_size: Vector2 = Vector2(1920, 1080)
var _joystick_region: Rect2 = Rect2()
var _jump_region: Rect2 = Rect2()
var _action_region: Rect2 = Rect2()

var action_button_visible: bool = false:
	set(value):
		action_button_visible = value
		var btn: Control = get_node_or_null("ActionButton")
		if btn:
			btn.visible = value


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	_calculate_regions()

	# Setup visual indicators
	_setup_visuals()


func _calculate_regions() -> void:
	_screen_size = get_viewport().get_visible_rect().size
	# Joystick: left 35% of screen, bottom 40%
	_joystick_region = Rect2(0, _screen_size.y * 0.6, _screen_size.x * 0.35, _screen_size.y * 0.4)
	_joystick_center = _joystick_region.get_center()
	# Jump button: right side, bottom
	_jump_region = Rect2(_screen_size.x * 0.75, _screen_size.y * 0.65, _screen_size.x * 0.25, _screen_size.y * 0.35)
	# Action button: right side, above jump
	_action_region = Rect2(_screen_size.x * 0.75, _screen_size.y * 0.35, _screen_size.x * 0.25, _screen_size.y * 0.3)


func _setup_visuals() -> void:
	# Create joystick visual using runtime-generated textures
	var joy_base := get_node_or_null("VirtualJoystick/Base")
	if joy_base and joy_base is TextureRect:
		var img := Image.create(160, 160, false, Image.FORMAT_RGBA8)
		img.fill(Color(0.3, 0.3, 0.3, 0.4))
		joy_base.texture = ImageTexture.create_from_image(img)

	var joy_knob := get_node_or_null("VirtualJoystick/Base/Knob")
	if joy_knob and joy_knob is TextureRect:
		var img := Image.create(60, 60, false, Image.FORMAT_RGBA8)
		img.fill(Color(0.6, 0.6, 0.6, 0.6))
		joy_knob.texture = ImageTexture.create_from_image(img)

	# Create button visuals
	var jump_btn := get_node_or_null("JumpButton")
	if jump_btn and jump_btn.get_child_count() == 0:
		var btn_rect := ColorRect.new()
		btn_rect.color = Color(0.0, 0.6, 0.8, 0.4)
		btn_rect.custom_minimum_size = Vector2(120, 120)
		btn_rect.size = Vector2(120, 120)
		jump_btn.add_child(btn_rect)
		var lbl := Label.new()
		lbl.text = "JUMP"
		lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		lbl.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		lbl.size = Vector2(120, 120)
		jump_btn.add_child(lbl)

	var action_btn := get_node_or_null("ActionButton")
	if action_btn and action_btn.get_child_count() == 0:
		var btn_rect := ColorRect.new()
		btn_rect.color = Color(0.8, 0.5, 0.0, 0.4)
		btn_rect.custom_minimum_size = Vector2(100, 100)
		btn_rect.size = Vector2(100, 100)
		action_btn.add_child(btn_rect)
		var lbl := Label.new()
		lbl.text = "ACT"
		lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		lbl.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		lbl.size = Vector2(100, 100)
		action_btn.add_child(lbl)


func _input(event: InputEvent) -> void:
	if event is InputEventScreenTouch:
		_handle_screen_touch(event as InputEventScreenTouch)
	elif event is InputEventScreenDrag:
		_handle_screen_drag(event as InputEventScreenDrag)


func _handle_screen_touch(event: InputEventScreenTouch) -> void:
	if event.pressed:
		var pos: Vector2 = event.position

		# Check joystick region
		if _joystick_region.has_point(pos) and _joystick_touch == -1:
			_joystick_touch = event.index
			_joystick_center = pos
			_update_joystick(pos)

		# Check jump button region
		elif _jump_region.has_point(pos) and _jump_touch == -1:
			_jump_touch = event.index
			jump_pressed.emit()

		# Check action button region
		elif action_button_visible and _action_region.has_point(pos) and _action_touch == -1:
			_action_touch = event.index
			_action_press_time = 0.0
			action_pressed.emit()

	else:
		# Touch released
		if event.index == _joystick_touch:
			_joystick_touch = -1
			_joystick_output = Vector2.ZERO
			_is_dropping = false
			move_input.emit(Vector2.ZERO)

		elif event.index == _jump_touch:
			_jump_touch = -1
			jump_released.emit()

		elif event.index == _action_touch:
			_action_touch = -1


func _handle_screen_drag(event: InputEventScreenDrag) -> void:
	if event.index == _joystick_touch:
		_update_joystick(event.position)


func _update_joystick(touch_pos: Vector2) -> void:
	var offset: Vector2 = touch_pos - _joystick_center
	var distance: float = offset.length()

	if distance < JOYSTICK_DEAD_ZONE:
		_joystick_output = Vector2.ZERO
	else:
		var clamped: Vector2 = offset.limit_length(JOYSTICK_MAX_RADIUS)
		_joystick_output = clamped / JOYSTICK_MAX_RADIUS

	move_input.emit(_joystick_output)

	# Drop detection
	if _joystick_output.y > DROP_THRESHOLD and not _is_dropping:
		_is_dropping = true
		drop_requested.emit()
	elif _joystick_output.y <= DROP_THRESHOLD:
		_is_dropping = false


func _process(delta: float) -> void:
	if _action_touch != -1:
		_action_press_time += delta
		action_held.emit(_action_press_time)


func get_move_direction() -> Vector2:
	return _joystick_output


func is_jump_held() -> bool:
	return _jump_touch != -1


func show_action_button() -> void:
	action_button_visible = true


func hide_action_button() -> void:
	action_button_visible = false
