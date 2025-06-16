extends Area2D

@export var possible_items: Array[String] = ["spaghetti", "salad", "soda", "cupcake"]
@export var food_icon: Sprite2D
@export var up_icon: AnimatedSprite2D
@export var icon_textures: Dictionary = {
	"spaghetti": preload("res:///spaghetti.png"),
	"salad": preload("res:///salad.png"),
	"soda": preload("res:///soda.png"),
	"cupcake": preload("res:///cupcake.png")
}

var current_request: String = ""
var player_in_range := false
var can_request := false
var has_been_talked_to := false

signal request_revealed(item: String)

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	GameManager.register_npc(self)
	food_icon.visible = false

func make_request() -> void:
	if possible_items.size() > 0:
		current_request = possible_items[randi() % possible_items.size()]
		can_request = true
		has_been_talked_to = false
		$AnimatedSprite2D.play("ordering")

func _on_body_entered(body: Node) -> void:
	if body.is_in_group("player"):
		player_in_range = true
		if can_request:
			up_icon.visible = true;
			$indicator.play("default")

func _on_body_exited(body: Node) -> void:
	if body.is_in_group("player"):
		player_in_range = false
		up_icon.visible = false;

func _process(_delta: float) -> void:
	if player_in_range and Input.is_action_just_pressed("ui_up"):
		if can_request:
			if not has_been_talked_to:
				up_icon.visible = false;
				has_been_talked_to = true
				_show_food_icon()
				print("NPC: I want a ", current_request)
				emit_signal("request_revealed", current_request)
			elif current_request in GameManager.collected_items:
				GameManager.collected_items.erase(current_request)
				print("NPC: Thank you for the ", current_request, "!")
				$AnimatedSprite2D.play("default")
				GameManager.orders_taken += 1
				up_icon.visible = false;
				can_request = false
				current_request = ""
				has_been_talked_to = false
				food_icon.visible = false
				GameManager.add_time(20)
				GameManager.assign_new_requester()
			else:
				print("NPC: I'm still waiting for a ", current_request)

func _show_food_icon() -> void:
	if current_request in icon_textures:
		food_icon.texture = icon_textures[current_request]
		food_icon.visible = true
