extends Node
## LeaderboardManager - Local leaderboard with player identifiers and share functionality.
## Stores scores in a local JSON file with player name/email as unique identifier.
## Supports exporting/sharing scores via Android share intent.

signal leaderboard_updated()
signal player_registered(player_id: String)

const LEADERBOARD_PATH: String = "user://leaderboard.json"
const MAX_ENTRIES: int = 100  # Max leaderboard entries stored

var _leaderboard: Array = []  # Array of {player_id, name, score, difficulty, date}
var _current_player_id: String = ""
var _current_player_name: String = ""


func _ready() -> void:
	_load_leaderboard()


# --- Player Registration ---

func register_player(name: String, email: String = "") -> void:
	## Register a player with a display name and optional email as unique ID.
	## If email is empty, uses name as the identifier.
	_current_player_name = name.strip_edges()
	_current_player_id = email.strip_edges() if email != "" else _current_player_name.to_lower()
	player_registered.emit(_current_player_id)
	_save_player_profile()


func is_player_registered() -> bool:
	return _current_player_id != ""


func get_current_player_name() -> String:
	return _current_player_name


func get_current_player_id() -> String:
	return _current_player_id


# --- Score Submission ---

func submit_score(score: int) -> Dictionary:
	## Submit a score for the current player. Returns the entry and rank.
	if _current_player_id == "":
		push_warning("LeaderboardManager: No player registered. Score not submitted.")
		return {}

	var entry: Dictionary = {
		"player_id": _current_player_id,
		"name": _current_player_name,
		"score": score,
		"difficulty": DifficultyManager.get_tier_name(),
		"date": _get_date_string(),
		"timestamp": Time.get_unix_time_from_system(),
	}

	# Check if this player already has an entry
	var existing_index: int = _find_player_entry(_current_player_id)
	if existing_index >= 0:
		# Only update if new score is higher
		if score > _leaderboard[existing_index]["score"]:
			_leaderboard[existing_index] = entry
		else:
			# Still return the existing entry info
			return {"entry": _leaderboard[existing_index], "rank": existing_index + 1, "is_new_best": false}
	else:
		_leaderboard.append(entry)

	# Sort by score descending
	_leaderboard.sort_custom(_sort_by_score)

	# Trim to max entries
	if _leaderboard.size() > MAX_ENTRIES:
		_leaderboard.resize(MAX_ENTRIES)

	_save_leaderboard()
	leaderboard_updated.emit()

	var rank: int = _find_player_entry(_current_player_id) + 1
	return {"entry": entry, "rank": rank, "is_new_best": true}


# --- Leaderboard Queries ---

func get_top_scores(count: int = 10) -> Array:
	## Returns the top N scores from the leaderboard.
	var result: Array = []
	for i in range(mini(count, _leaderboard.size())):
		result.append(_leaderboard[i])
	return result


func get_player_rank(player_id: String = "") -> int:
	## Returns 1-based rank for a player. Returns -1 if not found.
	var id: String = player_id if player_id != "" else _current_player_id
	var index: int = _find_player_entry(id)
	return index + 1 if index >= 0 else -1


func get_player_best_score(player_id: String = "") -> int:
	## Returns the best score for a player. Returns 0 if not found.
	var id: String = player_id if player_id != "" else _current_player_id
	var index: int = _find_player_entry(id)
	if index >= 0:
		return _leaderboard[index]["score"]
	return 0


func get_total_players() -> int:
	return _leaderboard.size()


# --- Share / Export ---

func share_score(score: int, rank: int) -> void:
	## Share score via Android share intent (email, social media, messaging apps).
	var share_text: String = _build_share_text(score, rank)

	if OS.has_feature("android"):
		# Use Android share intent via Godot plugin or mailto fallback
		_android_share(share_text)
	else:
		# Desktop fallback: copy to clipboard
		DisplayServer.clipboard_set(share_text)
		print("Score copied to clipboard: %s" % share_text)


func export_leaderboard_to_file() -> String:
	## Export the full leaderboard to a shareable text file.
	## Returns the file path.
	var export_path: String = "user://midnight_prowl_leaderboard_export.txt"
	var file := FileAccess.open(export_path, FileAccess.WRITE)
	if not file:
		return ""

	file.store_line("=== MIDNIGHT PROWL LEADERBOARD ===")
	file.store_line("Exported: %s" % _get_date_string())
	file.store_line("Total Players: %d" % _leaderboard.size())
	file.store_line("")
	file.store_line("RANK | PLAYER | SCORE | DIFFICULTY | DATE")
	file.store_line("-----|--------|-------|------------|-----")

	for i in range(_leaderboard.size()):
		var entry: Dictionary = _leaderboard[i]
		file.store_line("%4d | %s | %d | %s | %s" % [
			i + 1,
			entry.get("name", "Unknown"),
			entry.get("score", 0),
			entry.get("difficulty", ""),
			entry.get("date", ""),
		])

	file.close()
	return export_path


func get_leaderboard_as_text() -> String:
	## Returns the leaderboard formatted as shareable text.
	var lines: PackedStringArray = PackedStringArray()
	lines.append("🐱 MIDNIGHT PROWL LEADERBOARD 🐱")
	lines.append("")

	var top: Array = get_top_scores(10)
	for i in range(top.size()):
		var entry: Dictionary = top[i]
		var medal: String = ""
		match i:
			0: medal = "🥇"
			1: medal = "🥈"
			2: medal = "🥉"
			_: medal = "%d." % (i + 1)
		lines.append("%s %s - %d pts (%s)" % [
			medal,
			entry.get("name", "Unknown"),
			entry.get("score", 0),
			entry.get("difficulty", ""),
		])

	lines.append("")
	lines.append("Play Midnight Prowl and beat these scores!")
	return "\n".join(lines)


# --- Private Methods ---

func _build_share_text(score: int, rank: int) -> String:
	var text: String = "🐱 I scored %d points in Midnight Prowl! " % score
	if rank > 0:
		text += "Rank #%d on the local leaderboard. " % rank
	text += "Difficulty: %s. " % DifficultyManager.get_tier_name()
	text += "Can you beat my score? #MidnightProwl #RetroGaming"
	return text


func _android_share(text: String) -> void:
	## Trigger Android share intent using Godot's OS.shell_open or JavaSingleton.
	if Engine.has_singleton("GodotShare"):
		# If a share plugin is installed
		var share = Engine.get_singleton("GodotShare")
		share.shareText("My Midnight Prowl Score!", "Share Score", text)
	else:
		# Fallback: try to open a mailto link
		var encoded_text: String = text.uri_encode()
		var mailto: String = "mailto:?subject=My%%20Midnight%%20Prowl%%20Score&body=%s" % encoded_text
		OS.shell_open(mailto)


func _find_player_entry(player_id: String) -> int:
	for i in range(_leaderboard.size()):
		if _leaderboard[i].get("player_id", "") == player_id:
			return i
	return -1


func _sort_by_score(a: Dictionary, b: Dictionary) -> bool:
	return a.get("score", 0) > b.get("score", 0)


func _get_date_string() -> String:
	var dt: Dictionary = Time.get_datetime_dict_from_system()
	return "%04d-%02d-%02d %02d:%02d" % [dt["year"], dt["month"], dt["day"], dt["hour"], dt["minute"]]


# --- Persistence ---

func _save_leaderboard() -> void:
	var data: Dictionary = {
		"version": 1,
		"entries": _leaderboard,
	}
	var json_string: String = JSON.stringify(data, "\t")
	var file := FileAccess.open(LEADERBOARD_PATH, FileAccess.WRITE)
	if file:
		file.store_string(json_string)
		file.close()


func _load_leaderboard() -> void:
	if not FileAccess.file_exists(LEADERBOARD_PATH):
		_leaderboard = []
		return

	var file := FileAccess.open(LEADERBOARD_PATH, FileAccess.READ)
	if not file:
		_leaderboard = []
		return

	var json_string: String = file.get_as_text()
	file.close()

	var json := JSON.new()
	var error: Error = json.parse(json_string)
	if error != OK:
		push_warning("LeaderboardManager: Failed to parse leaderboard file.")
		_leaderboard = []
		return

	var data: Variant = json.get_data()
	if data is Dictionary and data.has("entries"):
		_leaderboard = data["entries"]
		_leaderboard.sort_custom(_sort_by_score)
	else:
		_leaderboard = []

	# Load saved player profile
	_load_player_profile()


func _save_player_profile() -> void:
	## Save current player identity separately for quick access.
	var profile_path: String = "user://player_profile.json"
	var data: Dictionary = {
		"player_id": _current_player_id,
		"name": _current_player_name,
	}
	var file := FileAccess.open(profile_path, FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(data))
		file.close()


func _load_player_profile() -> void:
	var profile_path: String = "user://player_profile.json"
	if not FileAccess.file_exists(profile_path):
		return

	var file := FileAccess.open(profile_path, FileAccess.READ)
	if not file:
		return

	var json := JSON.new()
	if json.parse(file.get_as_text()) == OK:
		var data: Variant = json.get_data()
		if data is Dictionary:
			_current_player_id = data.get("player_id", "")
			_current_player_name = data.get("name", "")
	file.close()
