extends Node3D
class_name AtractionTriger

@export var targets : Array[NodePath]

func triger() -> void:
	
	for t: NodePath in targets:
		if not get_node(t):
			return
		for n:Node in get_node(t).get_children():
			if n is Navegator:
				var nav : Navegator = n
				nav.alt_is_navegating = true
				nav.alt_target_position = global_position
				break
