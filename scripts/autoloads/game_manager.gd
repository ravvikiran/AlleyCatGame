extends Node
## GameManager - Central game state coordinator (Autoload Singleton)
## Manages game state transitions, lives, and global flags.

signal state_changed(new_state: GameState)
signal lives_changed(new_lives: int)
signal game_over()

enum GameState {
	TITLE_SCREEN,
	PLAYER_REGISTRATION,
	TUTORIAL,
	LEADERBOARD,
	ALLEYWAY_HUB,
	MINIGAME_CHEESE,
	MINIGAME_VASE,
	MINIGAME_DOGFOOD,
	MINIGAME_FISHBOWL,
	MINIGAME_BIRDCAGE,
	LOVE_GAME,
	GAME_OVER
}

const SCENE_MAP: Dictionary = {
	GameState.TITLE_SCREEN: "res://scenes/title_screen.tscn",
	GameState.PLAYER_REGISTRATION: "res://scenes/player_registration.tscn",
	GameState.TUTORIAL: "res://scenes/tutorial.tscn",
	GameState.LEADERBOARD: "res://scenes/leaderboard_screen.tscn",
	GameState.ALLEYWAY_HUB: "res://scenes/alleyway_hub.tscn",
	GameState.MINIGAME_CHEESE: "res://scenes/minigames/cheese_room.tscn",
	GameState.MINIGAME_VASE: "res://scenes/minigames/vase_room.tscn",
	GameState.MINIGAME_DOGFOOD: "res://scenes/minigames/dogfood_room.tscn",
	GameState.MINIGAME_FISHBOWL: "res://scenes/minigames/fishbowl_room.tscn",
	GameState.MINIGAME_BIRDCAGE: "res://scenes/minigames/birdcage_room.tscn",
	GameState.LOVE_GAME: "res://scenes/love_game.tscn",
	GameState.GAME_OVER: "res://scenes/game_over.tscn",
}

const MINIGAME_STATES: Array = [
	GameState.MINIGAME_CHEESE,
	GameState.MINIGAME_VASE,
	GameState.MINIGAME_DOGFOOD,
	GameState.MINIGAME_FISHBOWL,
	GameState.MINIGAME_BIRDCAGE,
]

const DEFAULT_LIVES: int = 9

var current_state: GameState = GameState.TITLE_SCREEN
var lives: int = DEFAULT_LIVES
var minigame_completed: bool = false
var felicia_window_active: bool = false


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS


func change_state(new_state: GameState) -> void:
	current_state = new_state
	state_changed.emit(new_state)

	if new_state == GameState.GAME_OVER:
		game_over.emit()
		ScoreManager.check_high_score()
		SaveManager.save()
		# Submit score to local leaderboard
		if LeaderboardManager.is_player_registered():
			LeaderboardManager.submit_score(ScoreManager.get_score())

	var scene_path: String = SCENE_MAP.get(new_state, "")
	if scene_path != "":
		get_tree().change_scene_to_file(scene_path)


func lose_life() -> void:
	lives -= 1
	lives_changed.emit(lives)

	if lives <= 0:
		change_state(GameState.GAME_OVER)
	else:
		# Respawn in alleyway hub
		change_state(GameState.ALLEYWAY_HUB)


func gain_life() -> void:
	lives += 1
	lives_changed.emit(lives)


func complete_minigame() -> void:
	minigame_completed = true
	felicia_window_active = true
	change_state(GameState.ALLEYWAY_HUB)


func complete_love_game() -> void:
	felicia_window_active = false
	minigame_completed = false
	DifficultyManager.advance_tier()
	gain_life()
	change_state(GameState.ALLEYWAY_HUB)


func get_random_minigame() -> GameState:
	return MINIGAME_STATES.pick_random()


func reset_game() -> void:
	lives = DEFAULT_LIVES
	current_state = GameState.TITLE_SCREEN
	minigame_completed = false
	felicia_window_active = false
	DifficultyManager.reset()
	ScoreManager.reset()
	SaveManager.increment_games_played()
	SaveManager.reset_session_flags()
	lives_changed.emit(lives)


func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		SaveManager.save()
		get_tree().quit()
	elif what == NOTIFICATION_WM_GO_BACK_REQUEST:
		if current_state == GameState.TITLE_SCREEN:
			SaveManager.save()
			get_tree().quit()
