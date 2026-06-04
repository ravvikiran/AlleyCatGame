extends Node2D
## Draws a recognizable spider shape.

var color: Color = Color(0.2, 0.2, 0.2, 1)


func _ready() -> void:
	if has_meta("color"):
		color = get_meta("color")


func _draw() -> void:
	# Body (two circles)
	draw_circle(Vector2(0, 0), 12, color)
	draw_circle(Vector2(0, -14), 8, color.lightened(0.1))

	# Eyes (red, menacing)
	draw_circle(Vector2(-4, -16), 2, Color.RED)
	draw_circle(Vector2(4, -16), 2, Color.RED)

	# Legs (8 lines)
	var leg_color := color.lightened(0.2)
	for i in range(4):
		var angle_l := -0.8 + i * 0.4
		var angle_r := 0.8 - i * 0.4
		var leg_len := 20.0
		# Left legs
		draw_line(Vector2(-8, -4 + i * 6), Vector2(-8 - leg_len * cos(angle_l), -4 + i * 6 + leg_len * sin(angle_l)), leg_color, 2.0)
		# Right legs
		draw_line(Vector2(8, -4 + i * 6), Vector2(8 + leg_len * cos(angle_r), -4 + i * 6 + leg_len * sin(angle_r)), leg_color, 2.0)

	# Web line going up
	draw_line(Vector2(0, -22), Vector2(0, -60), Color(0.5, 0.5, 0.5, 0.4), 1.0)
