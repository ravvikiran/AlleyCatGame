extends Node
## SaveManager - Local persistence using JSON (Autoload Singleton)
## Stores high scores, settings, and play statistics.

const SAVE_PATH: String = "user://alleycat_save.json"

const DEFAULT_DATA: Dictionary = {
	"high_score": 0,
	"highest_difficulty": 0,
	"total_games_played": 0,
	"settings": {
		"music_volume": 0.8,
		"sfx_volume": 1.0,
		"joystick_opacity": 0.6,
	}
}

var _cached_data: Dictionary = {}


func _ready() -> void:
	_cached_data = load_data()


func save() -> void:
	# Update cached data with current game state
	_cached_data["high_score"] = ScoreManager.get_high_score()
	_cached_data["highest_difficulty"] = int(DifficultyManager.current_tier)
	_cached_data["total_games_played"] = _cached_data.get("total_games_played", 0) + 1

	var json_string: String = JSON.stringify(_cached_data, "\t")
	var file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file:
		file.store_string(json_string)
		file.close()
	else:
		push_error("SaveManager: Failed to open save file for writing.")


func load_data() -> Dictionary:
	if not FileAccess.file_exists(SAVE_PATH):
		return DEFAULT_DATA.duplicate(true)

	var file := FileAccess.open(SAVE_PATH, FileAccess.READ)
	if not file:
		push_warning("SaveManager: Failed to open save file, using defaults.")
		return DEFAULT_DATA.duplicate(true)

	var json_string: String = file.get_as_text()
	file.close()

	var json := JSON.new()
	var error: Error = json.parse(json_string)
	if error != OK:
		push_warning("SaveManager: JSON parse error at line %d: %s. Using defaults." % [json.get_error_line(), json.get_error_message()])
		return DEFAULT_DATA.duplicate(true)

	var data: Variant = json.get_data()
	if data is Dictionary:
		# Merge with defaults to handle missing keys from older saves
		var merged: Dictionary = DEFAULT_DATA.duplicate(true)
		_merge_dict(merged, data)
		return merged
	else:
		push_warning("SaveManager: Save data is not a Dictionary. Using defaults.")
		return DEFAULT_DATA.duplicate(true)


func get_setting(key: String) -> Variant:
	var settings: Dictionary = _cached_data.get("settings", {})
	return settings.get(key, DEFAULT_DATA["settings"].get(key))


func set_setting(key: String, value: Variant) -> void:
	if not _cached_data.has("settings"):
		_cached_data["settings"] = {}
	_cached_data["settings"][key] = value


func reset() -> void:
	_cached_data = DEFAULT_DATA.duplicate(true)
	save()


func _merge_dict(base: Dictionary, override: Dictionary) -> void:
	for key in override:
		if base.has(key) and base[key] is Dictionary and override[key] is Dictionary:
			_merge_dict(base[key], override[key])
		else:
			base[key] = override[key]


func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_CLOSE_REQUEST or what == NOTIFICATION_WM_GO_BACK_REQUEST:
		save()
