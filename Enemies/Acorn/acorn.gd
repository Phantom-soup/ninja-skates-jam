extends CharacterBody2D

@export var gravity: float = 500.0
@onready var detection_area = $DetectionArea
@onready var enemy_collision = $CollisionShape2D 

var falling: bool = false
var original_position: Vector2

func _ready() -> void:
	original_position = global_position

func _physics_process(delta: float) -> void:
	if falling:
		velocity.y += gravity * delta
	else:
		velocity.y = 0.0

	move_and_slide()
	
	if falling:
		for i in get_slide_collision_count():
			var collision = get_slide_collision(i)
			if collision.get_collider().is_in_group("player"):
				print("player hit")
				hide()
				falling = false
				velocity = Vector2.ZERO
				enemy_collision.disabled = true
				await get_tree().create_timer(5.0).timeout
				global_position = original_position
				enemy_collision.disabled = false
				show()

func _on_detection_area_body_entered(body: Node) -> void:
	if body.is_in_group("player") and not falling:
		falling = true
		start_reset_timer()

func start_reset_timer() -> void:
	await get_tree().create_timer(5.0).timeout
	falling = false
	velocity = Vector2.ZERO
	global_position = original_position
