extends Area2D

@export var possible_items: Array[String] = ["spaghetti", "salad"]
var current_request: String = ""
var player_in_range := false

func _ready() -> void:
	_choose_new_item()
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

func _choose_new_item() -> void:
	if possible_items.size() > 0:
		current_request = possible_items[randi() % possible_items.size()]
		print("NPC: I want a ", current_request)

func _on_body_entered(body: Node) -> void:
	if body.is_in_group("player"):
		player_in_range = true

func _on_body_exited(body: Node) -> void:
	if body.is_in_group("player"):
		player_in_range = false

func _process(_delta: float) -> void:
	if player_in_range and Input.is_action_just_pressed("ui_up"):
		if current_request in GameManager.collected_items:
			GameManager.collected_items.erase(current_request)
			print("NPC: Thank you for the ", current_request, "!")
			_choose_new_item()
		else:
			print("NPC: I'm still waiting for a ", current_request)
