extends Node
## VisualFactory - Creates visual nodes for game entities.
## Uses AssetLoader to load real sprites when available.
## Falls back to procedural colored shapes (the current blocks) when no assets exist.

# --- Character Visuals ---

func create_freddy_visual() -> Node2D:
	## Create Freddy's visual. Uses real sprite if available, otherwise procedural cat shape.
	var sprite_frames := AssetLoader.load_character_spriteframes("freddy")
	if sprite_frames:
		var sprite := AnimatedSprite2D.new()
		sprite.sprite_frames = sprite_frames
		sprite.play("idle")
		return sprite

	# Try single texture
	var texture := AssetLoader.load_character_texture("freddy", "idle")
	if texture:
		var sprite := Sprite2D.new()
		sprite.texture = texture
		return sprite

	# Procedural placeholder: cat-shaped
	return _create_procedural_cat(Color(0, 1, 1, 1), Vector2(40, 60))


func create_entity_visual(entity_id: String, fallback_color: Color, fallback_size: Vector2) -> Node2D:
	## Generic entity visual loader. Works for dog, spider, mouse, eel, bird, etc.
	var texture := AssetLoader.load_entity_texture(entity_id)
	if texture:
		var sprite := Sprite2D.new()
		sprite.texture = texture
		return sprite

	# Try scene
	var scene := AssetLoader.load_scene("sprites/entities/%s.tscn" % entity_id.to_lower())
	if scene:
		return scene.instantiate()

	# Procedural fallback
	return _create_procedural_entity(entity_id, fallback_color, fallback_size)


func create_environment_visual(env_name: String, fallback_color: Color, fallback_size: Vector2) -> Node2D:
	## Environment piece (window, fence, building, etc.)
	var texture := AssetLoader.load_environment_texture(env_name)
	if texture:
		var sprite := Sprite2D.new()
		sprite.texture = texture
		return sprite

	# Procedural fallback
	var rect := ColorRect.new()
	rect.color = fallback_color
	rect.size = fallback_size
	rect.position = -fallback_size / 2.0
	return rect


func create_ui_visual(element_name: String, fallback_color: Color, fallback_size: Vector2) -> Control:
	## UI element (button, joystick base, etc.)
	var texture := AssetLoader.load_ui_texture(element_name)
	if texture:
		var tex_rect := TextureRect.new()
		tex_rect.texture = texture
		tex_rect.custom_minimum_size = fallback_size
		return tex_rect

	# Procedural fallback
	var rect := ColorRect.new()
	rect.color = fallback_color
	rect.custom_minimum_size = fallback_size
	rect.size = fallback_size
	return rect


# --- Procedural Placeholder Generators ---

func _create_procedural_cat(color: Color, size: Vector2) -> Node2D:
	## Creates a recognizable cat shape using drawing.
	var container := Node2D.new()
	container.set_script(load("res://scripts/visuals/procedural_cat.gd"))
	container.set_meta("color", color)
	container.set_meta("size", size)
	return container


func _create_procedural_entity(entity_id: String, color: Color, size: Vector2) -> Node2D:
	## Creates a shaped placeholder based on entity type.
	var container := Node2D.new()

	match entity_id.to_lower():
		"dog", "running_dog":
			container.set_script(load("res://scripts/visuals/procedural_dog.gd"))
		"spider":
			container.set_script(load("res://scripts/visuals/procedural_spider.gd"))
		"mouse":
			container.set_script(load("res://scripts/visuals/procedural_mouse.gd"))
		"bird":
			container.set_script(load("res://scripts/visuals/procedural_bird.gd"))
		"broom", "magic_broom":
			container.set_script(load("res://scripts/visuals/procedural_broom.gd"))
		_:
			# Generic colored rectangle with border
			var rect := ColorRect.new()
			rect.color = color
			rect.size = size
			rect.position = -size / 2.0
			container.add_child(rect)

	container.set_meta("color", color)
	container.set_meta("size", size)
	return container
