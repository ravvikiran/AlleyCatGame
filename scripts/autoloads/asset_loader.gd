extends Node
## AssetLoader - Plug-and-play asset loading system (Autoload Singleton).
## Loads real assets from res://assets/ folders when available.
## Falls back gracefully to null (callers use procedural placeholders).
## Caches all loaded resources to avoid reloading.

var _cache: Dictionary = {}
var _missing_logged: Dictionary = {}  # Track which missing assets we've already warned about


# --- Sprite / Texture Loading ---

func load_texture(relative_path: String) -> Texture2D:
	## Load a texture from res://assets/{relative_path}
	## Returns null if not found (caller should fall back to placeholder).
	var full_path := "res://assets/" + relative_path
	return _load_resource(full_path) as Texture2D


func load_sprite_frames(relative_path: String) -> SpriteFrames:
	## Load a SpriteFrames resource (.tres) from res://assets/{relative_path}
	var full_path := "res://assets/" + relative_path
	return _load_resource(full_path) as SpriteFrames


# --- Scene Loading (for complex objects with multiple nodes) ---

func load_scene(relative_path: String) -> PackedScene:
	## Load a scene (.tscn) from res://assets/{relative_path}
	var full_path := "res://assets/" + relative_path
	return _load_resource(full_path) as PackedScene


# --- Audio Loading ---

func load_audio(relative_path: String) -> AudioStream:
	## Load an audio stream (.ogg or .wav) from res://assets/{relative_path}
	var full_path := "res://assets/" + relative_path
	return _load_resource(full_path) as AudioStream


func load_music(track_name: String) -> AudioStream:
	## Shortcut: Load from assets/audio/music/{track_name}.ogg
	return load_audio("audio/music/%s.ogg" % track_name)


func load_sfx(sound_name: String) -> AudioStream:
	## Shortcut: Load from assets/audio/sfx/{sound_name}.ogg
	## Falls back to .wav if .ogg not found.
	var stream := load_audio("audio/sfx/%s.ogg" % sound_name)
	if stream == null:
		stream = load_audio("audio/sfx/%s.wav" % sound_name)
	return stream


# --- Character Sprite Loading ---

func load_character_texture(character_id: String, state: String = "idle") -> Texture2D:
	## Load character sprite: assets/sprites/characters/{character_id}_{state}.png
	var path := "sprites/characters/%s_%s.png" % [character_id.to_lower(), state.to_lower()]
	return load_texture(path)


func load_character_spriteframes(character_id: String) -> SpriteFrames:
	## Load full animation set: assets/sprites/characters/{character_id}.tres
	var path := "sprites/characters/%s.tres" % character_id.to_lower()
	return load_sprite_frames(path)


# --- Entity Sprite Loading ---

func load_entity_texture(entity_id: String) -> Texture2D:
	## Load entity sprite: assets/sprites/entities/{entity_id}.png
	var path := "sprites/entities/%s.png" % entity_id.to_lower()
	return load_texture(path)


# --- Environment Loading ---

func load_environment_texture(env_name: String) -> Texture2D:
	## Load environment art: assets/sprites/environments/{env_name}.png
	var path := "sprites/environments/%s.png" % env_name.to_lower()
	return load_texture(path)


func load_tileset(tileset_name: String) -> TileSet:
	## Load a tileset: assets/tilesets/{tileset_name}.tres
	var full_path := "res://assets/tilesets/%s.tres" % tileset_name.to_lower()
	return _load_resource(full_path) as TileSet


# --- UI Loading ---

func load_ui_texture(element_name: String) -> Texture2D:
	## Load UI element: assets/sprites/ui/{element_name}.png
	var path := "sprites/ui/%s.png" % element_name.to_lower()
	return load_texture(path)


# --- VFX Loading ---

func load_vfx(effect_name: String) -> PackedScene:
	## Load VFX scene: assets/vfx/{effect_name}.tscn
	var path := "vfx/%s.tscn" % effect_name.to_lower()
	return load_scene(path)


# --- Utility ---

func preload_folder(folder_path: String) -> void:
	## Preload all resources in a folder into the cache.
	var full_path := "res://assets/" + folder_path
	var dir := DirAccess.open(full_path)
	if dir == null:
		return
	dir.list_dir_begin()
	var file_name := dir.get_next()
	while file_name != "":
		if not dir.current_is_dir() and not file_name.ends_with(".import"):
			var resource_path := full_path + "/" + file_name
			_load_resource(resource_path)
		file_name = dir.get_next()
	dir.list_dir_end()


func clear_cache() -> void:
	## Clear the resource cache (useful when hot-reloading assets during development).
	_cache.clear()
	_missing_logged.clear()


func is_asset_available(relative_path: String) -> bool:
	## Check if an asset exists without loading it.
	var full_path := "res://assets/" + relative_path
	return ResourceLoader.exists(full_path)


# --- Internal ---

func _load_resource(full_path: String) -> Resource:
	# Check cache first
	if _cache.has(full_path):
		return _cache[full_path]

	# Check if file exists
	if not ResourceLoader.exists(full_path):
		if not _missing_logged.has(full_path):
			_missing_logged[full_path] = true
			if OS.is_debug_build():
				push_warning("AssetLoader: Asset not found: %s — using placeholder" % full_path)
		return null

	# Load and cache
	var resource: Resource = load(full_path)
	if resource:
		_cache[full_path] = resource
	return resource
