extends Node3D
class_name SpawnTriger

@export var targets : Array[NodePath]

var nodes : Array[Node]

var targets_remaining : int = 0
func subtract_target() -> void:
	targets_remaining-=1
	
	if targets_remaining <= 0:
		for np : NodePath in targets:
			get_node(np).triger()

func get_stats(node:Node) -> Stats:
	for n:Node in node.get_children():
		if n is Stats:
			return n
	return null

var sync_data : Dictionary = {}

func _ready() -> void:
	
	await get_tree().process_frame
	
	sync_data["spawned"] = false
	
	if not PersistenceManager.has(self):
			PersistenceManager.register(self,sync_data)
	else:
		sync_data = PersistenceManager.get_ref(self)
	
	
	
	for n:Node in get_children():
		
		
		
		nodes.push_back(n)
		remove_child(n)
		
		var stats : Stats = get_stats(n)
		if stats:
			stats.dead.connect(subtract_target)
			targets_remaining+=1
		
	
	if sync_data["spawned"]:
		for n:Node in nodes:
			add_child(n)
	

func triger() -> void:
	sync_data["spawned"] = true
	for n:Node in nodes:
		add_child(n)
