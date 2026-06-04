extends Node
## HazardSpawner - Manages dog, enemy cats, and thrown objects in the alleyway.

const DOG_BASE_SPEED: float = 300.0
const DOG_BASE_INTERVAL: float = 5.0
const THROWN_OBJECT_GRAVITY: float = 600.0

var _dog_timer: Timer
var _dog_active: bool = false
var _current_dog: CharacterBody2D = null
var _difficulty_tier: int = 0


func setup(tier: int) -> void:
	_difficulty_tier = tier
	_start_dog_spawner()
	_start_enemy_cat_spawner()


func _start_dog_spawner() -> void:
	_dog_timer = Timer.new()
	add_child(_dog_timer)
	var interval: float = DOG_BASE_INTERVAL / DifficultyManager.get_param("dog_freq")
	_dog_timer.wait_time = interval
	_dog_timer.timeout.connect(_spawn_dog)
	_dog_timer.start()


func _spawn_dog() -> void:
	if _dog_active:
		return

	_dog_active = true

	# Create dog entity
	var dog := CharacterBody2D.new()
	dog.name = "Dog"

	# Visual placeholder
	var visual := ColorRect.new()
	visual.color = Color(0.8, 0.4, 0.1, 1)
	visual.size = Vector2(60, 40)
	visual.position = Vector2(-30, -20)
	dog.add_child(visual)

	var collision := CollisionShape2D.new()
	var shape := RectangleShape2D.new()
	shape.size = Vector2(60, 40)
	collision.shape = shape
	dog.add_child(collision)

	# Hitbox area for detecting Freddy
	var hitbox := Area2D.new()
	hitbox.name = "Hitbox"
	hitbox.monitoring = true
	var hitbox_collision := CollisionShape2D.new()
	hitbox_collision.shape = shape.duplicate()
	hitbox.add_child(hitbox_collision)
	hitbox.body_entered.connect(_on_dog_hit_player)
	dog.add_child(hitbox)

	# Position at screen edge
	var direction: float = 1.0 if randi() % 2 == 0 else -1.0
	var start_x: float = -80.0 if direction > 0 else 2000.0
	dog.position = Vector2(start_x, 560)  # Street level

	var speed: float = DOG_BASE_SPEED * DifficultyManager.get_param("dog_speed")
	dog.set_meta("speed", speed * direction)
	dog.set_meta("direction", direction)

	get_parent().add_child(dog)
	_current_dog = dog

	AudioManager.play_sfx("dog_bark")


func _process(delta: float) -> void:
	if _current_dog and is_instance_valid(_current_dog):
		var speed: float = _current_dog.get_meta("speed")
		_current_dog.position.x += speed * delta

		# Remove when off screen
		if _current_dog.position.x > 2100 or _current_dog.position.x < -100:
			_current_dog.queue_free()
			_current_dog = null
			_dog_active = false

	# Update thrown objects
	_update_thrown_objects(delta)


func _on_dog_hit_player(body: Node2D) -> void:
	if body is Freddy:
		body.die()


func _start_enemy_cat_spawner() -> void:
	# Enemy cats pop from trash cans periodically
	var cat_timer := Timer.new()
	add_child(cat_timer)
	cat_timer.wait_time = randf_range(4.0, 8.0)
	cat_timer.timeout.connect(_spawn_enemy_cat_popup)
	cat_timer.start()


func _spawn_enemy_cat_popup() -> void:
	# Find a trash can to pop from
	var trash_cans: Array = get_tree().get_nodes_in_group("trash_cans")
	if trash_cans.size() == 0:
		return

	var can: Node2D = trash_cans.pick_random()
	# Check if Freddy is standing on this can
	var player := get_tree().get_first_node_in_group("player")
	if player and player is Freddy:
		if player.position.distance_to(can.position + Vector2(0, -40)) < 50:
			# Knock Freddy off
			player.velocity = Vector2(100, -200)
			player.current_state = Freddy.PlayerState.FALL


# --- Thrown Objects ---

var _thrown_objects: Array = []


func spawn_thrown_object(pos: Vector2, type: String) -> void:
	var obj := Area2D.new()
	obj.name = "ThrownObject_%s" % type
	obj.position = pos
	obj.set_meta("type", type)
	obj.set_meta("velocity_y", 0.0)
	obj.monitoring = true

	# Visual
	var visual := ColorRect.new()
	visual.color = Color(0.6, 0.3, 0.1, 1)
	visual.size = Vector2(25, 25)
	visual.position = Vector2(-12, -12)
	obj.add_child(visual)

	var collision := CollisionShape2D.new()
	var shape := RectangleShape2D.new()
	shape.size = Vector2(30, 30)
	collision.shape = shape
	obj.add_child(collision)

	obj.body_entered.connect(_on_thrown_object_hit.bind(obj))
	get_parent().add_child(obj)
	_thrown_objects.append(obj)


func _update_thrown_objects(delta: float) -> void:
	var to_remove: Array = []
	for obj in _thrown_objects:
		if not is_instance_valid(obj):
			to_remove.append(obj)
			continue

		var vel_y: float = obj.get_meta("velocity_y") + THROWN_OBJECT_GRAVITY * delta
		obj.set_meta("velocity_y", vel_y)
		obj.position.y += vel_y * delta

		# Remove if off screen
		if obj.position.y > 1200:
			obj.queue_free()
			to_remove.append(obj)

	for obj in to_remove:
		_thrown_objects.erase(obj)


func _on_thrown_object_hit(body: Node2D, obj: Area2D) -> void:
	if body is Freddy:
		body.die()
		obj.queue_free()
		_thrown_objects.erase(obj)
