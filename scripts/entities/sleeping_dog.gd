extends Node2D
## SleepingDog - Dogfood Room hazard with proximity-based awake meter.

class_name SleepingDog

signal dog_woke_up(dog: SleepingDog)

enum DogState { SLEEPING, WAKING, ATTACKING }

const PROXIMITY_RADIUS: float = 80.0
const FILL_RATE_CLOSE: float = 1.0
const FILL_RATE_EDGE: float = 0.3
const DRAIN_RATE: float = 0.2
const WAKE_THRESHOLD: float = 0.8

var current_state: DogState = DogState.SLEEPING
var awake_meter: float = 0.0
var target_player: CharacterBody2D = null


func _process(delta: float) -> void:
	if current_state == DogState.ATTACKING:
		return

	if not target_player:
		return

	var distance: float = position.distance_to(target_player.position)

	if distance < PROXIMITY_RADIUS:
		# Fill rate scales inversely with distance
		var proximity_factor: float = 1.0 - (distance / PROXIMITY_RADIUS)
		var fill_rate: float = lerpf(FILL_RATE_EDGE, FILL_RATE_CLOSE, proximity_factor)
		awake_meter = minf(1.0, awake_meter + fill_rate * delta)

		# Visual warning
		if awake_meter > WAKE_THRESHOLD and current_state == DogState.SLEEPING:
			current_state = DogState.WAKING

		# Dog wakes up
		if awake_meter >= 1.0:
			current_state = DogState.ATTACKING
			dog_woke_up.emit(self)
	else:
		# Drain meter
		awake_meter = maxf(0.0, awake_meter - DRAIN_RATE * delta)
		if awake_meter < WAKE_THRESHOLD:
			current_state = DogState.SLEEPING


func reset() -> void:
	current_state = DogState.SLEEPING
	awake_meter = 0.0


func get_awake_percentage() -> float:
	return awake_meter
