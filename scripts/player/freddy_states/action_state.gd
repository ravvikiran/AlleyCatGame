extends State
## ActionState - Context-dependent action (teleport, drink, drop gift).
## Duration and behavior set by the room that triggers it.

signal action_completed()

var _action_duration: float = 0.0
var _elapsed: float = 0.0
var _action_type: String = ""


func enter(params: Dictionary = {}) -> void:
	_action_type = params.get("type", "generic")
	_action_duration = params.get("duration", 0.5)
	_elapsed = 0.0
	player.velocity = Vector2.ZERO

	match _action_type:
		"drink":
			player.play_animation("eat")
		"teleport":
			player.play_animation("idle")  # Instant teleport
			_action_duration = 0.1
		"drop_gift":
			player.play_animation("idle")
			_action_duration = 0.3
		_:
			player.play_animation("eat")


func physics_update(delta: float) -> void:
	_elapsed += delta
	player.velocity = Vector2.ZERO
	player.move_and_slide()

	if _elapsed >= _action_duration:
		action_completed.emit()
		state_machine.transition_to("idle")
