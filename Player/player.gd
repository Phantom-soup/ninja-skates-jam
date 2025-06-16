extends CharacterBody2D

@onready var WallCDTRight = $Node2D/WCDTR
@onready var WallCDTLeft = $Node2D/WCDTL
@onready var WallCDBRight = $Node2D/WCDBR
@onready var WallCDBLeft = $Node2D/WCDBL
@onready var Animator = $AnimatedSprite2D

var fall_speed = 1000
var gravity = 1100

var direction = 0
var last_direction = 1
var speed = 350
var acceleration = 500
var friction = 1000
var turn_acceleration = 2000

var run_speed_break = 375
var run_speed = 600
var run_acceleration = 500
var running = false

var crawl_speed = 350
var crawl_acceleration = 500
var crouching = false
var sliding_speed = 410
var sliding = false

var jump_power_initial = 175
var jump_power = 2500
var jump_distance = 9000
var jump_time_max = 0.15
var jump_timer = 0
var has_jumped = false

var wall_hop_power_initial = 200
var wall_hop_power = 1200
var wall_hop_distance = 2500
var wall_hop_pushoff = 440
var wall_sliding_speed = 800
var sliding_gravity = 900
var wall_cling = false
var cling_direction = 0
var hop_off = false

var wall_kick_vert_power = 1500
var wall_kick_horzont_power = 1000

var coyote_time = 0.1
var coyote_timer = 0
var late_jump_time = 0.1
var late_jump_timer = 0

var is_knocked_back: bool = false
var knockback_duration: float = 0.3
var knockback_timer: float = 0.0
var knockback_vector: Vector2 = Vector2.ZERO

enum Act{IDLE, SKATE, AIR, WALLHUG}
var current_act: Act = Act.IDLE

func _ready():
	print("Label reference:", $Timer)
	GameManager.set_timer_label($Timer)

func _ready():
	print("Label reference:", $Timer)
	GameManager.set_timer_label($Timer)

func _unhandled_input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed("B"):
		if crouching:
			velocity.x = sliding_speed * last_direction
			sliding = true

func _physics_process(delta: float) -> void:
	if is_knocked_back:
		velocity = knockback_vector
		knockback_timer -= delta
		if knockback_timer <= 0.0:
			is_knocked_back = false
		move_and_slide()
		return
	
	update_movement(delta)
	grav_down(delta)
	get_wall_direction()
	jump(delta)
	coyote_timing(delta)
	update_acts()
	update_animation()
	flip_sprite()
	move_and_slide()

func grav_down(delta: float) -> void:
	if !wall_cling:
		velocity.y = move_toward(velocity.y, fall_speed, gravity * delta)
	else:
		velocity.y = move_toward(velocity.y, wall_sliding_speed, sliding_gravity * delta)
	if !is_on_floor():
		crouching = false
		has_jumped = false

func update_movement(delta: float) -> void:
	direction = Input.get_axis("Left", "Right")
	
	if Input.is_action_pressed("Down"):
		crouching = true
	else:
		crouching = false
	
	if direction:
		last_direction = direction
		
		if direction * velocity.x < 0: #turning around
			velocity.x = move_toward(velocity.x, direction * speed, turn_acceleration * delta)
		elif crouching: #crawling
			velocity.x = move_toward(velocity.x, direction * crawl_speed, crawl_acceleration * delta)
		elif abs(velocity.x) > run_speed_break: #speed break
			velocity.x = move_toward(velocity.x, direction * run_speed, run_acceleration * delta)
		else: #walking
			velocity.x = move_toward(velocity.x, direction * speed, acceleration * delta)
		if cling_direction != 0 and is_on_wall_only():
			wall_cling = true
		else:
			wall_cling = false
	else: #stopping
		velocity.x = move_toward(velocity.x, 0, friction * delta)

func jump(delta: float) -> void:
	if Input.is_action_just_pressed("A"):
		if is_on_floor() or coyote_timer > 0:
			velocity.y = -jump_power_initial
			jump_timer = jump_time_max
			
		if wall_cling:
			jump_timer = jump_time_max
			hop_off = true
			velocity.y = -wall_hop_power_initial
			velocity.x = wall_hop_pushoff * -cling_direction
	elif Input.is_action_pressed("A") and jump_timer > 0:
		jump_timer -= delta
		
		if !hop_off:
			velocity.y = move_toward(velocity.y, -jump_distance, jump_power * delta)
		else:
			velocity.y = move_toward(velocity.y, -wall_hop_distance, wall_hop_power * delta)
	else:
		hop_off = false
		jump_timer = -1

func coyote_timing(delta: float) -> void:
	if is_on_floor() or is_on_wall_only():
		coyote_timer = coyote_time
	else:
		coyote_timer -= delta

func get_wall_direction() -> void:
	if WallCDBLeft.is_colliding() or WallCDTLeft.is_colliding():
		cling_direction = -1
	elif WallCDBRight.is_colliding() or WallCDTRight.is_colliding():
		cling_direction = 1

func update_acts() -> void:
	print(velocity.x)
	match current_act:
		Act.IDLE:
			if velocity.x != 0:
				current_act = Act.SKATE
		
		Act.SKATE:
			if velocity.x == 0:
				current_act = Act.IDLE
			if not is_on_floor():
				current_act = Act.AIR
		
		Act.AIR:
			if is_on_floor():
				current_act = Act.SKATE

func update_animation() -> void:
	match current_act:
		Act.IDLE:
			Animator.play("idle")
		Act.SKATE:
			Animator.play("skate")
		Act.AIR:
			pass
		Act.WALLHUG:
			pass

func flip_sprite() -> void:
	if direction < 0:
		Animator.scale.x
	else:
		Animator.flip_h

func take_knockback(strength: float = 100.0, vertical_boost: float = -300.0) -> void:
	if is_knocked_back:
		return
	is_knocked_back = true
	knockback_timer = knockback_duration

	knockback_vector = Vector2(-last_direction * strength, vertical_boost)

func take_knockback_from_direction(dir: Vector2, strength: float = 100.0, vertical_boost: float = -300.0) -> void:
	is_knocked_back = true
	knockback_timer = knockback_duration

	var knockback_dir = dir.normalized()
	knockback_vector = knockback_dir * strength
	knockback_vector.y += vertical_boost
