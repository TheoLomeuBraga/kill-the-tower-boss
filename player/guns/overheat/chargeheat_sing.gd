extends MeshInstance3D

func _process(delta: float) -> void:
	visible = not $"../Cube_001".visible
