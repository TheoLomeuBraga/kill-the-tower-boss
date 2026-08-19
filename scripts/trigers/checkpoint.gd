extends Area3D
class_name CheckPoint

func on_body_entered(n:Node3D) -> void:
	if n is Player:
		PersistenceManager.save_state()

func _ready() -> void:
	body_entered.connect(on_body_entered)
