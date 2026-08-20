extends PersistenceSync
class_name TransformPersistenceSync

@onready var parent : Node3D = $".."

func _ready() -> void:
	
	
	
	sync_data["position"] = parent.global_position
	sync_data["rotation"] = parent.global_rotation
	
	if not PersistenceManager.has(self):
		PersistenceManager.register(self,sync_data)
	else:
		sync_data = PersistenceManager.get_ref(self)
	
	parent.global_position = sync_data["position"]
	parent.global_rotation = sync_data["rotation"]

func _process(delta: float) -> void:
	sync_data["position"] = parent.global_position
	sync_data["rotation"] = parent.global_rotation
