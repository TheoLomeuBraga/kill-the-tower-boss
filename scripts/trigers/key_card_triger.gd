extends Area3D
class_name KeyCardTriger

@export var key_type : GlobalEnums.KeyCards
@export var targets : Array[NodePath]


var sync_data : Dictionary

func on_body_entered(body:Node3D) -> void:
	if sync_data["used"]:
		return
	
	if not body is Player:
		return
	var player : Player = body
	if not player.keys.keys[key_type]:
		return
	
	for np : NodePath in targets:
		get_node(np).triger()
	
	sync_data["used"] = true
	

func _ready() -> void:
	sync_data["used"] = false
	if not PersistenceManager.has(self):
			PersistenceManager.register(self,sync_data)
	else:
		sync_data = PersistenceManager.get_ref(self)
	
	
	body_entered.connect(on_body_entered)
