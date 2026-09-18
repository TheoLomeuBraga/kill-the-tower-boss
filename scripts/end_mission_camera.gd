extends Camera3D
class_name EndMissionCamera

@export var mission_name : String = ""

static var current_end_camera : EndMissionCamera

func _ready() -> void:
	current_end_camera = self
	current = false



func _exit_tree() -> void:
	current_end_camera = null
