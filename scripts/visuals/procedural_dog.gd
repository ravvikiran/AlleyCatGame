extends Node2D
## Draws a recognizable dog shape.

var color: Color = Color(0.8, 0.4, 0.1, 1)


func _ready() -> void:
	if has_meta("color"):
		color = get_meta("color")


func _draw() -> void:
	var dark := color.darkened(0.3)

	# Body (elongated rectangle)
	draw_rect(Rect2(-30, -12, 60, 28), color)

	# Head (circle)
	draw_circle(Vector2(-28, -8), 14, color)

	# Snout
	draw_rect(Rect2(-44, -6, 12, 10), color.lightened(0.1))

	# Ear (floppy)
	draw_polygon(PackedVector2Array([
		Vector2(-22, -20),
		Vector2(-32, -22),
		Vector2(-34, -10),
	]), PackedColorArray([dark, dark, dark]))

	# Eye
	draw_circle(Vector2(-24, -12), 3, Color.WHITE)
	draw_circle(Vector2(-23, -12), 1.5, Color.BLACK)

	# Nose
	draw_circle(Vector2(-43, -2), 3, Color.BLACK)

	# Legs (4 rectangles)
	draw_rect(Rect2(-20, 14, 6, 12), dark)
	draw_rect(Rect2(-6, 14, 6, 12), dark)
	draw_rect(Rect2(10, 14, 6, 12), dark)
	draw_rect(Rect2(22, 14, 6, 12), dark)

	# Tail (line)
	draw_line(Vector2(30, -8), Vector2(38, -18), color, 3.0)
