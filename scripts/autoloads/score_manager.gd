extends Node
## ScoreManager - Tracks points, high scores, and multipliers (Autoload Singleton)

signal score_changed(new_score: int)
signal high_score_changed(new_high: int)
signal new_high_score_achieved()

enum ScoreEvent {
	MOUSE_CATCH,
	ALLEY_MOUSE_CATCH,
	MINIGAME_COMPLETE,
	LOVE_GAME_COMPLETE,
	TIME_BONUS,
}

const POINT_VALUES: Dictionary = {
	ScoreEvent.MOUSE_CATCH: 100,
	ScoreEvent.ALLEY_MOUSE_CATCH: 50,
	ScoreEvent.MINIGAME_COMPLETE: 500,
	ScoreEvent.LOVE_GAME_COMPLETE: 1000,
	ScoreEvent.TIME_BONUS: 10,  # per second remaining
}

var current_score: int = 0
var high_score: int = 0
var love_game_multiplier: int = 1  # 1 or 2 (doubled if gift delivered)


func _ready() -> void:
	# Defer high score loading to ensure SaveManager is ready
	call_deferred("_load_high_score")


func _load_high_score() -> void:
	var save_data: Dictionary = SaveManager.load_data()
	high_score = save_data.get("high_score", 0)


func award_points(event: ScoreEvent, bonus: int = 0) -> void:
	var base_points: int = POINT_VALUES.get(event, 0)
	var total: int = base_points + bonus

	if event == ScoreEvent.LOVE_GAME_COMPLETE:
		total *= love_game_multiplier

	current_score += total
	score_changed.emit(current_score)


func award_time_bonus(seconds_remaining: float) -> void:
	var bonus: int = int(seconds_remaining) * POINT_VALUES[ScoreEvent.TIME_BONUS]
	current_score += bonus
	score_changed.emit(current_score)


func set_love_multiplier(has_gift: bool) -> void:
	love_game_multiplier = 2 if has_gift else 1


func check_high_score() -> bool:
	if current_score > high_score:
		high_score = current_score
		high_score_changed.emit(high_score)
		new_high_score_achieved.emit()
		return true
	return false


func get_score() -> int:
	return current_score


func get_high_score() -> int:
	return high_score


func reset() -> void:
	current_score = 0
	love_game_multiplier = 1
	score_changed.emit(current_score)


func reset_for_new_game() -> void:
	current_score = 0
	love_game_multiplier = 1
	score_changed.emit(current_score)
