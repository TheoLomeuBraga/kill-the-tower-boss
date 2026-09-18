extends Area3D
class_name AreaTriger

@export var triger_on_enter : bool = true
@export var triger_on_exit : bool = false
@export var targets : Array[NodePath]

@export var one_use : bool = false
var used : bool = false

var sync_data : Dictionary

@export var detect_stats_entities : bool = false

func get_stats_from_node(node:Node3D) -> Stats:
	for c : Node in node.get_children():
		if c is Stats:
			return c
	return null

func use() -> void:
	for np : NodePath in targets:
		get_node(np).triger()
	
	if one_use:
		used = true
		sync_data["used"] = true

var bodys_in : Array[Node3D]

func on_body_entered(body:Node3D) -> void:
	
	if detect_stats_entities:
		if not get_stats_from_node(body):
			return
	else:
		if not body is Player:
			return
	
	if one_use and used:
		return
	
	if bodys_in.size() == 0:
		use()
	
	bodys_in.push_back(body)
	
	

func on_body_exit(body:Node3D) -> void:
	
	if detect_stats_entities:
		if not get_stats_from_node(body):
			return
	else:
		if not body is Player:
			return
	
	if one_use and used:
		return
	
	if bodys_in.size() == 1:
		use()
	
	bodys_in.erase(body)

func _ready() -> void:
	
	sync_data["used"] = false
	if not PersistenceManager.has(self):
			PersistenceManager.register(self,sync_data)
	else:
		sync_data = PersistenceManager.get_ref(self)
	
	if sync_data["used"]:
		used = true
	
	if triger_on_enter:
		body_entered.connect(on_body_entered)
	if triger_on_exit:
		body_exited.connect(on_body_exit)
