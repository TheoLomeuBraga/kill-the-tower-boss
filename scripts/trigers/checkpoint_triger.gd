extends Area3D
class_name CheckPointTriger

var sync_data : Dictionary
var is_mult_use : bool = false

func on_body_entered(n:Node3D) -> void:
	
	
	
	if n is Player:
		PersistenceManager.save_state()
		
		if not is_mult_use:
			sync_data["used"] = true
			queue_free()

func _ready() -> void:
	if not is_mult_use:
		sync_data["used"] = false
		if not PersistenceManager.has(self):
				PersistenceManager.register(self,sync_data)
		else:
			sync_data = PersistenceManager.get_ref(self)
		if sync_data["used"]:
			queue_free()
			return
	
	body_entered.connect(on_body_entered)
