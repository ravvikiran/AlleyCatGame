extends Control
## VirtualJoystick - Touch-based floating joystick for directional input.
## Outputs a normalized Vector2 direction and detects drop input.

signal direction_changed(direction: Vector2)
signal drop_requested()

@export var dead_zone: float = 20.0
@export var max_radius: float = 80.0
@export var drop_threshold: float = 0.7

@onready var _base: TextureRect = $Base
@onready var _knob: TextureRect = $Base/Knob

var _touch_index: int = -1
var _center: Vector2 = Vector2.ZERO
var _output: Vector2 = Vector2.ZERO
var _is_dropping: bool = false


func _ready() -> void:
	_center = _base.size / 2.0


func _input(event: InputEvent) -> void:
	if event is InputEventScreenTouch:
		_handle_touch(event as InputEventScreenTouch)
	elif event is InputEventScreenDrag:
		_handle_drag(event as InputEventScreenDrag)


func _handle_touch(event: InputEventScreenTouch) -> void:
	if event.pressed:
		# Only accept touches in the left half of the screen
		if event.position.x < get_viewport_rect().size.x * 0.4:
			if _touch_index == -1:
				_touch_index = event.index
				_update_knob_position(event.position)
	else:
		if event.index == _touch_index:
			_touch_index = -1
			_reset_knob()
			_output = Vector2.ZERO
			direction_changed.emit(_output)
			_is_dropping = false


func _handle_drag(event: InputEventScreenDrag) -> void:
	if event.index == _touch_index:
		_update_knob_position(event.position)


func _update_knob_position(touch_pos: Vector2) -> void:
	var local_pos: Vector2 = touch_pos - _base.global_position - _center
	var distance: float = local_pos.length()

	if distance < dead_zone:
		_output = Vector2.ZERO
		_knob.position = _center - _knob.size / 2.0
	else:
		var clamped: Vector2 = local_pos.limit_length(max_radius)
		_output = clamped / max_radius
		_knob.position = _center + clamped - _knob.size / 2.0

	direction_changed.emit(_output)

	# Check for drop input
	if _output.y > drop_threshold and not _is_dropping:
		_is_dropping = true
		drop_requested.emit()
	elif _output.y <= drop_threshold:
		_is_dropping = false


func _reset_knob() -> void:
	_knob.position = _center - _knob.size / 2.0


func get_direction() -> Vector2:
	return _output


func is_active() -> bool:
	return _touch_index != -1
