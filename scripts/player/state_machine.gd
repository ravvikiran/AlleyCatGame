extends Node
## StateMachine - Generic hierarchical state machine.
## NOTE: Freddy now uses an inline state machine for simplicity.
## This class is retained for potential use by enemy AI entities.

class_name StateMachine

signal state_changed(old_state_name: String, new_state_name: String)

var current_state_name: String = ""


func transition_to(state_name: String, _params: Dictionary = {}) -> void:
	var old_name: String = current_state_name
	current_state_name = state_name
	state_changed.emit(old_name, state_name)
