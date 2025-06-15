extends CharacterBody2D

@export var projectile_scene: PackedScene
@export var projectile_speed: float = 400.0
@export var shoot_direction: Vector2 = Vector2.RIGHT
@export var shoot_interval: float = 2.0

var player_too_close: bool = false

func _ready() -> void:
	$ShootTimer.wait_time = shoot_interval
	$ShootTimer.start()
	$ShootTimer.timeout.connect(_on_shoot_timer_timeout)

	$PlayerDetector.body_entered.connect(_on_player_detector_body_entered)
	$PlayerDetector.body_exited.connect(_on_player_detector_body_exited)

func _on_shoot_timer_timeout() -> void:
	if not player_too_close:
		shoot_projectile()

func shoot_projectile() -> void:
	if projectile_scene:
		var bullet = projectile_scene.instantiate()
		bullet.global_position = $Muzzle.global_position
		bullet.direction = shoot_direction
		bullet.speed = projectile_speed
		get_tree().current_scene.add_child(bullet)

func _on_player_detector_body_entered(body: Node) -> void:
	if body.is_in_group("player"):
		player_too_close = true
		$AnimatedSprite2D.play("hiding")
		$AnimatedSprite2D.flip_h = true

func _on_player_detector_body_exited(body: Node) -> void:
	if body.is_in_group("player"):
		player_too_close = false
		$AnimatedSprite2D.play("default")
		$AnimatedSprite2D.flip_h = false
