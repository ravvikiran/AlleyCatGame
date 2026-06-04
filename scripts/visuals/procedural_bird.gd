extends Node2D
## Draws a bird in flight.

var color: Color = Color(0, 1, 0, 1)


func _ready() -> void:
	if has_meta("color"):
		color = get_meta("color")


func _draw() -> void:
	# Body
	draw_circle(Vector2(0, 0), 8, color)

	# Head
	draw_circle(Vector2(-10, -4), 5, color.lightened(0.1))

	# Beak
	draw_polygon(PackedVector2Array([
		Vector2(-14, -4),
		Vector2(-20, -3),
		Vector2(-14, -2),
	]), PackedColorArray([Color.ORANGE, Color.ORANGE, Color.ORANGE]))

	# Eye
	draw_circle(Vector2(-11, -5), 1.5, Color.BLACK)

	# Wings (triangles)
	draw_polygon(PackedVector2Array([
		Vector2(-4, -2),
		Vector2(4, -16),
		Vector2(8, -2),
	]), PackedColorArray([color.darkened(0.2), color.darkened(0.2), color.darkened(0.2)]))

	# Tail feathers
	draw_polygon(PackedVector2Array([
		Vector2(8, -2),
		Vector2(16, -6),
		Vector2(14, 2),
	]), PackedColorArray([color.darkened(0.1), color.darkened(0.1), color.darkened(0.1)]))
