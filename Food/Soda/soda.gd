extends Area2D

@export var item_id: String = "soda"

var player_in_range: bool = false

func _ready():
	if GameManager.collected_items.has(item_id):
		queue_free()

	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

func _on_body_entered(body):
	if body.is_in_group("player"):
		player_in_range = true

func _on_body_exited(body):
	if body.is_in_group("player"):
		player_in_range = false

func _process(_delta):
	if player_in_range and Input.is_action_just_pressed("ui_up"):
		GameManager.collected_items[item_id] = true
		print("Collected item: ", item_id)
		queue_free()
