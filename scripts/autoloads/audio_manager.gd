extends Node
## AudioManager - Handles music and SFX playback (Autoload Singleton)
## Uses an SFX pool for concurrent sound effects and crossfading music.

const SFX_POOL_SIZE: int = 8
const CROSSFADE_DURATION: float = 1.0

# SFX clip paths
const SFX_CLIPS: Dictionary = {
	"jump": "res://assets/audio/sfx/jump.ogg",
	"land": "res://assets/audio/sfx/land.ogg",
	"hurt": "res://assets/audio/sfx/hurt.ogg",
	"catch_mouse": "res://assets/audio/sfx/catch_mouse.ogg",
	"dog_bark": "res://assets/audio/sfx/dog_bark.ogg",
	"broom_sweep": "res://assets/audio/sfx/broom_sweep.ogg",
	"vase_break": "res://assets/audio/sfx/vase_break.ogg",
	"splash": "res://assets/audio/sfx/splash.ogg",
	"meow_death": "res://assets/audio/sfx/meow_death.ogg",
	"eel_zap": "res://assets/audio/sfx/eel_zap.ogg",
}

# Music track paths mapped to game states
const MUSIC_TRACKS: Dictionary = {
	"title": "res://assets/audio/music/title_theme.ogg",
	"alleyway": "res://assets/audio/music/alleyway.ogg",
	"minigame": "res://assets/audio/music/minigame.ogg",
	"love_game": "res://assets/audio/music/love_game.ogg",
	"game_over": "res://assets/audio/music/game_over.ogg",
}

var _music_player: AudioStreamPlayer
var _music_player_fade: AudioStreamPlayer  # For crossfading
var _sfx_pool: Array[AudioStreamPlayer] = []
var _sfx_pool_index: int = 0
var _current_music_key: String = ""
var _fade_tween: Tween


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS

	# Create music players
	_music_player = AudioStreamPlayer.new()
	_music_player.bus = "Music" if AudioServer.get_bus_index("Music") >= 0 else "Master"
	add_child(_music_player)

	_music_player_fade = AudioStreamPlayer.new()
	_music_player_fade.bus = _music_player.bus
	add_child(_music_player_fade)

	# Create SFX pool
	for i in range(SFX_POOL_SIZE):
		var player := AudioStreamPlayer.new()
		player.bus = "SFX" if AudioServer.get_bus_index("SFX") >= 0 else "Master"
		add_child(player)
		_sfx_pool.append(player)


func play_sfx(clip_name: String) -> void:
	if not SFX_CLIPS.has(clip_name):
		push_warning("AudioManager: Unknown SFX clip '%s'" % clip_name)
		return

	var path: String = SFX_CLIPS[clip_name]
	var stream: AudioStream = load(path) if ResourceLoader.exists(path) else null
	if stream == null:
		# Silently skip missing audio files (placeholder phase)
		return

	var player: AudioStreamPlayer = _sfx_pool[_sfx_pool_index]
	_sfx_pool_index = (_sfx_pool_index + 1) % SFX_POOL_SIZE

	player.stream = stream
	player.play()


func play_music(track_key: String) -> void:
	if track_key == _current_music_key:
		return

	if not MUSIC_TRACKS.has(track_key):
		push_warning("AudioManager: Unknown music track '%s'" % track_key)
		return

	var path: String = MUSIC_TRACKS[track_key]
	var stream: AudioStream = load(path) if ResourceLoader.exists(path) else null
	if stream == null:
		# Silently skip missing music files (placeholder phase)
		stop_music()
		return

	_current_music_key = track_key
	_crossfade_to(stream)


func stop_music() -> void:
	_current_music_key = ""
	if _fade_tween:
		_fade_tween.kill()
	_music_player.stop()
	_music_player_fade.stop()


func set_music_volume(linear: float) -> void:
	var bus_idx: int = AudioServer.get_bus_index("Music")
	if bus_idx >= 0:
		AudioServer.set_bus_volume_db(bus_idx, linear_to_db(linear))


func set_sfx_volume(linear: float) -> void:
	var bus_idx: int = AudioServer.get_bus_index("SFX")
	if bus_idx >= 0:
		AudioServer.set_bus_volume_db(bus_idx, linear_to_db(linear))


func _crossfade_to(new_stream: AudioStream) -> void:
	if _fade_tween:
		_fade_tween.kill()

	# Swap players: current becomes fade-out, new becomes main
	var temp: AudioStreamPlayer = _music_player
	_music_player = _music_player_fade
	_music_player_fade = temp

	_music_player.stream = new_stream
	_music_player.volume_db = -80.0
	_music_player.play()

	_fade_tween = create_tween()
	_fade_tween.set_parallel(true)
	_fade_tween.tween_property(_music_player, "volume_db", 0.0, CROSSFADE_DURATION)
	_fade_tween.tween_property(_music_player_fade, "volume_db", -80.0, CROSSFADE_DURATION)
	_fade_tween.chain().tween_callback(_music_player_fade.stop)


func _notification(what: int) -> void:
	if what == NOTIFICATION_APPLICATION_PAUSED:
		# Pause all audio on Android background
		_music_player.stream_paused = true
		_music_player_fade.stream_paused = true
	elif what == NOTIFICATION_APPLICATION_RESUMED:
		_music_player.stream_paused = false
		_music_player_fade.stream_paused = false
