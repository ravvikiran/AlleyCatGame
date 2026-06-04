extends Node2D
## Draws a broom shape.

var color: Color = Color(0.6, 0.4, 0.2, 1)


func _ready() -> void:
	if has_meta("color"):
		color = get_meta("color")


func _draw() -> void:
	# Handle (long thin rect)
	draw_rect(Rect2(-3, -50, 6, 60), color)

	# Bristles (triangle shape at bottom)
	draw_polygon(PackedVector2Array([
		Vector2(-12, 10),
		Vector2(12, 10),
		Vector2(8, 30),
		Vector2(-8, 30),
	]), PackedColorArray([
		Color(0.8, 0.7, 0.3),
		Color(0.8, 0.7, 0.3),
		Color(0.6, 0.5, 0.2),
		Color(0.6, 0.5, 0.2),
	]))

	# Bristle lines
	for i in range(-8, 9, 4):
		draw_line(Vector2(i, 10), Vector2(i * 0.7, 28), Color(0.5, 0.4, 0.1), 1.0)
