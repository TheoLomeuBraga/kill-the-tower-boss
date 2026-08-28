extends Area3D
class_name DeathZoneTriger

func on_body_entered(n:Node3D) -> void:
	for c : Node in n.get_children():
		if c is Stats:
			c.instakill()
		

func _ready() -> void:
	body_entered.connect(on_body_entered)
