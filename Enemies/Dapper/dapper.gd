extends CharacterBody2D

@export var speed: float = 100.0
@export var waypoints: Array[Vector2] = []

@onready var hitbox = $Hitbox

var current_index: int = 0
var moving: bool = true

func _ready():
	if waypoints.is_empty():
		push_error("No waypoints assigned to enemy.")

func _physics_process(_delta: float) -> void:
	if waypoints.is_empty() or not moving:
		return

	var target = waypoints[current_index]
	var direction = (target - global_position).normalized()
	velocity = direction * speed
	move_and_slide()

	if global_position.distance_to(target) < 5.0:
		moving = false
		_start_pause()

func _start_pause() -> void:
	await get_tree().create_timer(1.0).timeout
	current_index = (current_index + 1) % waypoints.size()
	moving = true
