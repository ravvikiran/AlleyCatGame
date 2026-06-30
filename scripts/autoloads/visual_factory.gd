extends Node
## VisualFactory - Creates visual nodes for game entities.
## Uses AssetLoader to load real sprites when available.
## Falls back to procedural colored shapes when no assets exist.

# Preloaded procedural visual scripts
var _script_cat: GDScript
var _script_dog: GDScript
var _script_spider: GDScript
var _script_mouse: GDScript
var _script_bird: GDScript
var _script_broom: GDScript


func _ready() -> void:
	# Preload all procedural visual scripts safely
	_script_cat = _safe_load("res://scripts/visuals/procedural_cat.gd")
	_script_dog = _safe_load("res://scripts/visuals/procedural_dog.gd")
	_script_spider = _safe_load("res://scripts/visuals/procedural_spider.gd")
	_script_mouse = _safe_load("res://scripts/visuals/procedural_mouse.gd")
	_script_bird = _safe_load("res://scripts/visuals/procedural_bird.gd")
	_script_broom = _safe_load("res://scripts/visuals/procedural_broom.gd")


func _safe_load(path: String) -> GDScript:
	if ResourceLoader.exists(path):
		return load(path) as GDScript
	push_warning("VisualFactory: Script not found: %s" % path)
	return null


# --- Character Visuals ---

func create_freddy_visual() -> Node2D:
	## Create Freddy's visual. Uses real sprite if available, otherwise procedural cat shape.
	
	# Try SpriteFrames resource
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
	return _create_procedural_node(_script_cat, Color(0, 1, 1, 1), Vector2(40, 60))


func create_entity_visual(entity_id: String, fallback_color: Color, fallback_size: Vector2) -> Node2D:
	## Generic entity visual loader.
	
	# Try real texture
	var texture := AssetLoader.load_entity_texture(entity_id)
	if texture:
		var sprite := Sprite2D.new()
		sprite.texture = texture
		return sprite

	# Try scene
	var scene := AssetLoader.load_scene("sprites/entities/%s.tscn" % entity_id.to_lower())
	if scene:
		var instance = scene.instantiate()
		if instance is Node2D:
			return instance
		instance.queue_free()

	# Procedural fallback based on entity type
	var script: GDScript = null
	match entity_id.to_lower():
		"dog", "running_dog":
			script = _script_dog
		"spider":
			script = _script_spider
		"mouse":
			script = _script_mouse
		"bird":
			script = _script_bird
		"broom", "magic_broom":
			script = _script_broom

	if script:
		return _create_procedural_node(script, fallback_color, fallback_size)

	# Ultimate fallback: colored rectangle
	return _create_colored_rect(fallback_color, fallback_size)


func create_environment_visual(env_name: String, fallback_color: Color, fallback_size: Vector2) -> Node2D:
	## Environment piece visual.
	var texture := AssetLoader.load_environment_texture(env_name)
	if texture:
		var sprite := Sprite2D.new()
		sprite.texture = texture
		return sprite

	# Fallback: colored rect
	return _create_colored_rect(fallback_color, fallback_size)


func create_ui_visual(element_name: String, fallback_color: Color, fallback_size: Vector2) -> Control:
	## UI element visual.
	var texture := AssetLoader.load_ui_texture(element_name)
	if texture:
		var tex_rect := TextureRect.new()
		tex_rect.texture = texture
		tex_rect.custom_minimum_size = fallback_size
		return tex_rect

	var rect := ColorRect.new()
	rect.color = fallback_color
	rect.custom_minimum_size = fallback_size
	rect.size = fallback_size
	return rect


# --- Internal Helpers ---

func _create_procedural_node(script: GDScript, color: Color, size: Vector2) -> Node2D:
	## Create a Node2D with a procedural drawing script attached.
	var node := Node2D.new()
	if script:
		node.set_script(script)
	node.set_meta("color", color)
	node.set_meta("size", size)
	return node


func _create_colored_rect(color: Color, size: Vector2) -> Node2D:
	## Simple colored rectangle as ultimate fallback.
	var container := Node2D.new()
	var rect := ColorRect.new()
	rect.color = color
	rect.size = size
	rect.position = -size / 2.0
	container.add_child(rect)
	return container
