extends Node

var food_scenes: Dictionary = {}
@export var spawn_point: Node2D

func _ready() -> void:
	food_scenes = {
		"spaghetti": preload("res://Food/Spaghetti/spaghetti.tscn"),
		"salad": preload("res://Food/Salad/salad.tscn"),
		"soda": preload("res://Food/Soda/soda.tscn"),
		"cupcake": preload("res://Food/Cupcake/cupcake.tscn")
	}
	
	for npc in GameManager.npc_list:
		npc.request_revealed.connect(_on_request_revealed)

func _on_request_revealed(item: String) -> void:
	if item in food_scenes:
		var food = food_scenes[item].instantiate()
		food.global_position = spawn_point.global_position
		get_tree().current_scene.add_child(food)
