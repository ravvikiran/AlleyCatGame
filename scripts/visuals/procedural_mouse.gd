extends Node2D
## Draws a small mouse shape.

var color: Color = Color(0.6, 0.6, 0.6, 1)


func _ready() -> void:
	if has_meta("color"):
		color = get_meta("color")


func _draw() -> void:
	var dark := color.darkened(0.3)

	# Body (small oval)
	draw_rect(Rect2(-10, -5, 20, 12), color)

	# Head
	draw_circle(Vector2(-10, -2), 6, color.lightened(0.1))

	# Ears (circles)
	draw_circle(Vector2(-12, -8), 4, Color.PINK)
	draw_circle(Vector2(-6, -8), 4, Color.PINK)

	# Eye
	draw_circle(Vector2(-12, -3), 1.5, Color.BLACK)

	# Nose
	draw_circle(Vector2(-16, -1), 1.5, Color.PINK)

	# Tail (curved line)
	draw_line(Vector2(10, 0), Vector2(18, -4), dark, 1.5)
	draw_line(Vector2(18, -4), Vector2(22, 2), dark, 1.5)

	# Whiskers
	draw_line(Vector2(-14, -1), Vector2(-22, -3), dark, 0.5)
	draw_line(Vector2(-14, 0), Vector2(-22, 1), dark, 0.5)
