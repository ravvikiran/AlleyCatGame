extends Node
## State - Base class for all player/entity states.
## Override enter(), exit(), update(), and physics_update() in subclasses.

class_name State

var state_machine: StateMachine
var player: CharacterBody2D  # Set by Freddy on _ready


func enter(_params: Dictionary = {}) -> void:
	pass


func exit() -> void:
	pass


func update(_delta: float) -> void:
	pass


func physics_update(_delta: float) -> void:
	pass
