extends Control
## Main - Entry point scene. Shows loading screen then transitions to title.


func _ready() -> void:
	# Brief loading delay to show splash, then go to title
	var timer := get_tree().create_timer(0.5)
	timer.timeout.connect(_go_to_title)


func _go_to_title() -> void:
	GameManager.change_state(GameManager.GameState.TITLE_SCREEN)
