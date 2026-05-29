extends Node
## PlaceholderAssets - Generates colored rectangle textures at runtime for development.
## Replace these with real pixel art assets for production.

# Character colors (CGA-inspired palette)
const COLOR_FREDDY := Color(0.0, 1.0, 1.0)        # Cyan
const COLOR_DOG := Color(0.8, 0.4, 0.1)           # Brown
const COLOR_SPIDER := Color(0.2, 0.2, 0.2)        # Dark gray
const COLOR_MOUSE := Color(0.6, 0.6, 0.6)         # Light gray
const COLOR_EEL := Color(1.0, 1.0, 0.0)           # Yellow
const COLOR_BIRD := Color(0.0, 1.0, 0.0)          # Green
const COLOR_ENEMY_CAT := Color(1.0, 0.0, 1.0)     # Magenta
const COLOR_BROOM := Color(0.6, 0.4, 0.2)         # Wood brown
const COLOR_CUPID := Color(1.0, 0.8, 0.8)         # Pink
const COLOR_FELICIA := Color(1.0, 0.5, 0.8)       # Hot pink
const COLOR_HEART_SOLID := Color(1.0, 0.0, 0.3)   # Red
const COLOR_HEART_BROKEN := Color(0.3, 0.0, 0.1)  # Dark red
const COLOR_WINDOW_OPEN := Color(0.2, 0.2, 0.5)   # Dark blue
const COLOR_WINDOW_CLOSED := Color(0.1, 0.1, 0.1) # Near black
const COLOR_TRASH_CAN := Color(0.3, 0.3, 0.3)     # Gray
const COLOR_CHEESE := Color(1.0, 0.85, 0.0)       # Yellow
const COLOR_PLANT := Color(0.0, 0.7, 0.2)         # Green
const COLOR_BOWL := Color(0.8, 0.8, 0.8)          # Light gray
const COLOR_CAGE := Color(0.7, 0.7, 0.0)          # Gold

# UI colors
const COLOR_JOYSTICK_BASE := Color(0.2, 0.2, 0.2, 0.5)
const COLOR_JOYSTICK_KNOB := Color(0.5, 0.5, 0.5, 0.7)
const COLOR_BUTTON_JUMP := Color(0.0, 0.6, 0.8, 0.6)
const COLOR_BUTTON_ACTION := Color(0.8, 0.5, 0.0, 0.6)


static func create_rect_texture(width: int, height: int, color: Color) -> ImageTexture:
	var image := Image.create(width, height, false, Image.FORMAT_RGBA8)
	image.fill(color)
	# Add a 1px border for visibility
	var border_color := color.darkened(0.4)
	for x in range(width):
		image.set_pixel(x, 0, border_color)
		image.set_pixel(x, height - 1, border_color)
	for y in range(height):
		image.set_pixel(0, y, border_color)
		image.set_pixel(width - 1, y, border_color)
	return ImageTexture.create_from_image(image)


static func create_circle_texture(radius: int, color: Color) -> ImageTexture:
	var size: int = radius * 2
	var image := Image.create(size, size, false, Image.FORMAT_RGBA8)
	image.fill(Color.TRANSPARENT)
	var center := Vector2(radius, radius)
	for x in range(size):
		for y in range(size):
			if Vector2(x, y).distance_to(center) <= radius:
				image.set_pixel(x, y, color)
	return ImageTexture.create_from_image(image)


static func create_cat_texture(width: int, height: int, color: Color) -> ImageTexture:
	var image := Image.create(width, height, false, Image.FORMAT_RGBA8)
	image.fill(Color.TRANSPARENT)
	# Body (rectangle)
	for x in range(4, width - 4):
		for y in range(int(height * 0.3), height - 4):
			image.set_pixel(x, y, color)
	# Head (circle-ish)
	var head_center := Vector2(width / 2, int(height * 0.25))
	var head_radius: float = width * 0.3
	for x in range(width):
		for y in range(int(height * 0.5)):
			if Vector2(x, y).distance_to(head_center) <= head_radius:
				image.set_pixel(x, y, color)
	# Ears (triangles)
	for i in range(5):
		if int(width * 0.25) + i < width and i < height:
			image.set_pixel(int(width * 0.25) + i, i, color)
		if int(width * 0.75) - i >= 0 and int(width * 0.75) - i < width and i < height:
			image.set_pixel(int(width * 0.75) - i, i, color)
	# Eyes
	var eye_color := Color.WHITE
	if int(width * 0.35) < width and int(height * 0.2) < height:
		image.set_pixel(int(width * 0.35), int(height * 0.2), eye_color)
	if int(width * 0.65) < width and int(height * 0.2) < height:
		image.set_pixel(int(width * 0.65), int(height * 0.2), eye_color)
	return ImageTexture.create_from_image(image)


static func create_heart_texture(size: int, color: Color) -> ImageTexture:
	var image := Image.create(size, size, false, Image.FORMAT_RGBA8)
	image.fill(Color.TRANSPARENT)
	# Simple heart shape using math
	var center_x: float = size / 2.0
	var center_y: float = size / 2.0
	for x in range(size):
		for y in range(size):
			var nx: float = (x - center_x) / (size / 2.0)
			var ny: float = (y - center_y) / (size / 2.0)
			# Heart equation approximation
			var val: float = (nx * nx + ny * ny - 1.0)
			val = val * val * val - nx * nx * ny * ny * ny
			if val <= 0:
				image.set_pixel(x, y, color)
	return ImageTexture.create_from_image(image)
