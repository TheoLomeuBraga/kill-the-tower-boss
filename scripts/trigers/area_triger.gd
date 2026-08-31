extends Area3D
class_name AreaTriger

@export var triger_on_enter : bool = true
@export var triger_on_exit : bool = false
@export var targets : Array[NodePath]

@export var one_use : bool = false
var used : bool = false

func on_body_entered(body:Node3D) -> void:
	
	if not body is Player:
		return
	
	if one_use and used:
		return
	
	for np : NodePath in targets:
		
		get_node(np).triger()
		
		if one_use:
			used = true

func _ready() -> void:
	if triger_on_enter:
		body_entered.connect(on_body_entered)
	if triger_on_exit:
		body_exited.connect(on_body_entered)
