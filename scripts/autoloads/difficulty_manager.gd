extends Node
## DifficultyManager - Manages progressive difficulty scaling (Autoload Singleton)
## Defines four tiers with parameter multipliers for all game systems.

signal difficulty_changed(new_tier: DifficultyTier)

enum DifficultyTier {
	KITTEN = 0,
	HOUSE_CAT = 1,
	TOMCAT = 2,
	ALLEY_CAT = 3,
}

const TIER_NAMES: Dictionary = {
	DifficultyTier.KITTEN: "Kitten",
	DifficultyTier.HOUSE_CAT: "House Cat",
	DifficultyTier.TOMCAT: "Tomcat",
	DifficultyTier.ALLEY_CAT: "Alley Cat",
}

# Difficulty parameters indexed by tier ordinal
const PARAMS: Dictionary = {
	"trash_cans": [6, 5, 4, 3],
	"dog_speed": [1.0, 1.3, 1.6, 2.0],
	"dog_freq": [1.0, 1.2, 1.5, 1.8],
	"eel_per_fish": [1, 1, 2, 2],
	"spider_speed": [1.0, 1.3, 1.6, 2.0],
	"cat_accuracy": [0.5, 0.65, 0.8, 0.95],
	"mouse_speed": [1.0, 1.2, 1.4, 1.7],
	"broom_speed": [1.0, 1.1, 1.3, 1.5],
	"window_open_duration_min": [4.0, 3.5, 3.0, 2.5],
	"window_open_duration_max": [8.0, 7.0, 6.0, 5.0],
}

var current_tier: DifficultyTier = DifficultyTier.KITTEN


func advance_tier() -> void:
	if current_tier < DifficultyTier.ALLEY_CAT:
		current_tier = (current_tier + 1) as DifficultyTier
		difficulty_changed.emit(current_tier)


func get_param(key: String) -> float:
	if PARAMS.has(key):
		var values: Array = PARAMS[key]
		return float(values[current_tier])
	push_warning("DifficultyManager: Unknown param key '%s'" % key)
	return 1.0


func get_param_int(key: String) -> int:
	if PARAMS.has(key):
		var values: Array = PARAMS[key]
		return int(values[current_tier])
	push_warning("DifficultyManager: Unknown param key '%s'" % key)
	return 1


func get_tier_name() -> String:
	return TIER_NAMES.get(current_tier, "Unknown")


func reset() -> void:
	current_tier = DifficultyTier.KITTEN
	difficulty_changed.emit(current_tier)
