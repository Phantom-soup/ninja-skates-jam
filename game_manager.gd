extends Node

var collected_items: = {}
var npc_list: Array[Node] = []
var active_npc: Node = null

var start_time: float = 60.0
var remaining_time: float
var game_over: bool = false

@onready var timer_label: Label

func register_npc(npc: Node) -> void:
	npc_list.append(npc)
	
	if active_npc == null:
		assign_new_requester()
		
func assign_new_requester() -> void:
	if npc_list.is_empty():
		return
	var candidates = npc_list.filter(func(n): return n != active_npc)
	if candidates.is_empty():
		candidates = npc_list 

	active_npc = candidates[randi() % candidates.size()]
	active_npc.make_request()

func set_timer_label(label: Label) -> void:
	timer_label = label

func _ready():
	remaining_time = start_time
	

func _process(delta: float) -> void:
	if game_over:
		return

	remaining_time -= delta
	if remaining_time <= 0:
		remaining_time = 0
		end_game()
		
	timer_label.text = "Time: " + str(int(round(remaining_time)))

func add_time(seconds: float) -> void:
	remaining_time += seconds

func end_game():
	game_over = true
	print("Time's up!")
