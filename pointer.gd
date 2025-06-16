extends Sprite2D

@export var player: Node2D
@export var spawn_point: Node2D
var target: Node2D
var targeting_food = false
var targeting_npc = true

func _process(_delta):
	if GameManager.active_npc.has_been_talked_to:
		if GameManager.collected_items.size() == 1:
			targeting_food = false
			targeting_npc = true
		else:
			targeting_food = true
			targeting_npc = false
	
	if targeting_npc and player:
		target = GameManager.active_npc
		var direction = (target.global_position - player.global_position).normalized()
		rotation = direction.angle()
	
	if targeting_food and player:
		target = spawn_point
		var direction = (target.global_position - player.global_position).normalized()
		rotation = direction.angle()
