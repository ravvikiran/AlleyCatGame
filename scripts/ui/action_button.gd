extends Control
## ActionButton - Generic touch button for Jump and Action inputs.
## Emits pressed/released/held signals for responsive input handling.

signal button_pressed()
signal button_released()
signal button_held(duration: float)

@export var button_radius: float = 60.0
@export var hold_threshold: float = 0.1  # seconds before held signal starts

var _touch_index: int = -1
var _press_time: float = 0.0
var _is_held: bool = false


func _input(event: InputEvent) -> void:
	if event is InputEventScreenTouch:
		_handle_touch(event as InputEventScreenTouch)


func _handle_touch(event: InputEventScreenTouch) -> void:
	if event.pressed:
		if _is_point_inside(event.position) and _touch_index == -1:
			_touch_index = event.index
			_press_time = 0.0
			_is_held = false
			button_pressed.emit()
	else:
		if event.index == _touch_index:
			_touch_index = -1
			_is_held = false
			button_released.emit()


func _process(delta: float) -> void:
	if _touch_index != -1:
		_press_time += delta
		if _press_time >= hold_threshold:
			_is_held = true
			button_held.emit(_press_time)


func _is_point_inside(point: Vector2) -> bool:
	var center: Vector2 = global_position + size / 2.0
	return point.distance_to(center) <= button_radius


func is_pressed() -> bool:
	return _touch_index != -1


func get_hold_duration() -> float:
	return _press_time if _touch_index != -1 else 0.0
