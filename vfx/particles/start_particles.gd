extends GPUParticles3D
class_name StartGPUParticles3D

func _ready() -> void:
	await get_tree().process_frame
	emitting = true
