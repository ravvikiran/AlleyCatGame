extends MinigameRoomBase
## VaseRoom - Collect 3 plants from a bookcase while avoiding a giant spider.
## Spider AI: tracks horizontally, drops when above Freddy, ascends when Freddy moves away.

const PLANT_COUNT: int = 3
const SPIDER_H_SPEED_BASE: float = 120.0
const SPIDER_DROP_SPEED_BASE: float = 500.0
const SPIDER_ASCEND_SPEED: float = 200.0
const SPIDER_DROP_THRESHOLD: float = 10.0  # pixels of X alignment to trigger drop
const SPIDER_ASCEND_THRESHOLD: float = 60.0  # pixels of X misalignment to trigger ascend
const CEILING_Y: float = 20.0

enum SpiderState { TRACKING, DROPPING, ASCENDING }

var _spider: CharacterBody2D
var _spider_state: SpiderState = SpiderState.TRACKING
var _plants_collected: int = 0


func _ready() -> void:
	objective_count = PLANT_COUNT
	has_magic_broom = true
	has_running_dog = false
	super._ready()

	# Hide action button (not needed in this room)
	var touch: CanvasLayer = $UILayer/TouchController
	if touch:
		touch.hide_action_button()

	_setup_spider()
	_setup_plants()


func _setup_spider() -> void:
	_spider = CharacterBody2D.new()
	_spider.name = "Spider"

	var collision := CollisionShape2D.new()
	var shape := CircleShape2D.new()
	shape.radius = 25.0
	collision.shape = shape
	_spider.add_child(collision)

	var hitbox := Area2D.new()
	hitbox.name = "Hitbox"
	var hb_col := CollisionShape2D.new()
	hb_col.shape = shape.duplicate()
	hitbox.add_child(hb_col)
	hitbox.body_entered.connect(_on_spider_hit)
	_spider.add_child(hitbox)

	_spider.position = Vector2(960, CEILING_Y)
	add_child(_spider)


func _setup_plants() -> void:
	# Plants are placed on the bookcase shelves (set up in scene)
	# Connect their Area2D signals
	for i in range(PLANT_COUNT):
		var plant: Area2D = get_node_or_null("Bookcase/Plant%d" % i)
		if plant:
			plant.body_entered.connect(_on_plant_collected.bind(plant))


func _on_plant_collected(body: Node2D, plant: Area2D) -> void:
	if body is Freddy:
		plant.queue_free()
		_plants_collected += 1
		on_objective_completed()


func _on_spider_hit(body: Node2D) -> void:
	if body is Freddy:
		body.die()


func _physics_process(delta: float) -> void:
	super._physics_process(delta)
	_update_spider(delta)


func _update_spider(delta: float) -> void:
	if not _spider or not _player:
		return

	var speed_mult: float = DifficultyManager.get_param("spider_speed")
	var h_speed: float = SPIDER_H_SPEED_BASE * speed_mult
	var drop_speed: float = SPIDER_DROP_SPEED_BASE * speed_mult

	match _spider_state:
		SpiderState.TRACKING:
			# Move horizontally toward Freddy's X position
			var diff_x: float = _player.position.x - _spider.position.x
			if abs(diff_x) > SPIDER_DROP_THRESHOLD:
				_spider.velocity.x = sign(diff_x) * h_speed
				_spider.velocity.y = 0
			else:
				# Aligned - drop!
				_spider_state = SpiderState.DROPPING
				_spider.velocity.x = 0

		SpiderState.DROPPING:
			_spider.velocity.y = drop_speed
			_spider.velocity.x = 0

			# Check if Freddy moved away horizontally
			var diff_x: float = abs(_player.position.x - _spider.position.x)
			if diff_x > SPIDER_ASCEND_THRESHOLD:
				_spider_state = SpiderState.ASCENDING

			# Hit the floor - ascend
			if _spider.position.y > 600:
				_spider_state = SpiderState.ASCENDING

		SpiderState.ASCENDING:
			_spider.velocity.y = -SPIDER_ASCEND_SPEED
			_spider.velocity.x = 0

			# Reached ceiling
			if _spider.position.y <= CEILING_Y:
				_spider.position.y = CEILING_Y
				_spider_state = SpiderState.TRACKING

	_spider.move_and_slide()
