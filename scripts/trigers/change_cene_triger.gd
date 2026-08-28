extends Area3D
class_name ChangeCeneTriger

@export_file("*.tscn") var next_scene : String

func on_body_entered(n:Node3D) -> void:
	SceneManager.load_map(next_scene)

func _ready() -> void:
	
	body_entered.connect(on_body_entered)
