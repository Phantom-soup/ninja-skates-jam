extends CharacterBody2D

@export var speed: float = 1000.0
@export var direction: Vector2 = Vector2.RIGHT

func _ready() -> void:
	if not $CollisionShape2D.disabled:
		$CollisionShape2D.disabled = false

func _physics_process(delta: float) -> void:
	var motion = direction.normalized() * speed * delta
	var collision = move_and_collide(motion)
	
	if collision:
		if collision.get_collider().is_in_group("player"):
			print("Player hit!")
			var player = collision.get_collider()
			player.take_knockback_from_direction(direction)
			queue_free()
		else:
			queue_free()
