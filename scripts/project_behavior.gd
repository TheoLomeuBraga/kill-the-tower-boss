extends Node3D
class_name ProjectBehavior

@export var data : ProjectileInfo = ProjectileInfo.new()

var model : MeshInstance3D
var ray : RayCast3D
var shape : ShapeCast3D

var progression : float = 0.0

func start() -> void:
	model = MeshInstance3D.new()
	model.mesh = data.mesh
	add_child(model)
	
	if data.speed < 0.0:
		pass
	else:
		pass

func check_colision() -> void:
	if data.speed < 0.0:
		pass
	else:
		pass

func _physics_process(delta: float) -> void:
	if data.speed < 0.0:
		pass
	else:
		model.position.z -= data.speed * delta
		
		if data.range < model.position.length():
			queue_free()
