extends Node2D
## Draws a recognizable cat silhouette using Godot's _draw() method.
## Much better than a flat rectangle!

var color: Color = Color(0, 1, 1, 1)
var body_width: float = 30.0
var body_height: float = 40.0


func _ready() -> void:
	if has_meta("color"):
		color = get_meta("color")
	if has_meta("size"):
		var s: Vector2 = get_meta("size")
		body_width = s.x * 0.7
		body_height = s.y * 0.6


func _draw() -> void:
	var dark := color.darkened(0.3)
	var light := color.lightened(0.2)

	# Body (oval)
	var body_rect := Rect2(-body_width / 2, -body_height * 0.2, body_width, body_height)
	draw_rect(body_rect, color)

	# Head (circle)
	var head_radius := body_width * 0.45
	var head_center := Vector2(0, -body_height * 0.45)
	draw_circle(head_center, head_radius, color)

	# Ears (triangles)
	# Left ear
	draw_polygon(PackedVector2Array([
		head_center + Vector2(-head_radius * 0.6, -head_radius * 0.3),
		head_center + Vector2(-head_radius * 0.9, -head_radius * 1.1),
		head_center + Vector2(-head_radius * 0.1, -head_radius * 0.7),
	]), PackedColorArray([color, color, color]))
	# Right ear
	draw_polygon(PackedVector2Array([
		head_center + Vector2(head_radius * 0.6, -head_radius * 0.3),
		head_center + Vector2(head_radius * 0.9, -head_radius * 1.1),
		head_center + Vector2(head_radius * 0.1, -head_radius * 0.7),
	]), PackedColorArray([color, color, color]))

	# Inner ears
	draw_polygon(PackedVector2Array([
		head_center + Vector2(-head_radius * 0.55, -head_radius * 0.4),
		head_center + Vector2(-head_radius * 0.75, -head_radius * 0.9),
		head_center + Vector2(-head_radius * 0.2, -head_radius * 0.6),
	]), PackedColorArray([dark, dark, dark]))
	draw_polygon(PackedVector2Array([
		head_center + Vector2(head_radius * 0.55, -head_radius * 0.4),
		head_center + Vector2(head_radius * 0.75, -head_radius * 0.9),
		head_center + Vector2(head_radius * 0.2, -head_radius * 0.6),
	]), PackedColorArray([dark, dark, dark]))

	# Eyes (white with pupils)
	var eye_y := head_center.y + head_radius * 0.1
	draw_circle(Vector2(-head_radius * 0.3, eye_y), head_radius * 0.2, Color.WHITE)
	draw_circle(Vector2(head_radius * 0.3, eye_y), head_radius * 0.2, Color.WHITE)
	# Pupils
	draw_circle(Vector2(-head_radius * 0.25, eye_y), head_radius * 0.1, Color.BLACK)
	draw_circle(Vector2(head_radius * 0.35, eye_y), head_radius * 0.1, Color.BLACK)

	# Nose (small pink triangle)
	var nose_y := head_center.y + head_radius * 0.4
	draw_polygon(PackedVector2Array([
		Vector2(-3, nose_y - 2),
		Vector2(3, nose_y - 2),
		Vector2(0, nose_y + 2),
	]), PackedColorArray([Color.PINK, Color.PINK, Color.PINK]))

	# Tail (curved line)
	var tail_start := Vector2(body_width * 0.4, -body_height * 0.1)
	var tail_mid := Vector2(body_width * 0.7, -body_height * 0.4)
	var tail_end := Vector2(body_width * 0.5, -body_height * 0.7)
	draw_line(tail_start, tail_mid, color, 4.0)
	draw_line(tail_mid, tail_end, color, 3.0)

	# Paws (small ovals at bottom)
	draw_circle(Vector2(-body_width * 0.25, body_height * 0.75), 5, dark)
	draw_circle(Vector2(body_width * 0.25, body_height * 0.75), 5, dark)
