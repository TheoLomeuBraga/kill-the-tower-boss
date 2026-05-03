extends Node3D
class_name ProjectBehavior

@export var data : ProjectileInfo = ProjectileInfo.new()

var model : MeshInstance3D
var ray : RayCast3D
var shape : ShapeCast3D

var progression : float = 0.0

var muzle_position : Vector3


func start() -> void:
	
	if data.speed < 0.0:
		ray = RayCast3D.new()
		ray.target_position = Vector3(0.0,0.0,-data.range)
		add_child(ray)
	else:
		model = MeshInstance3D.new()
		model.mesh = data.mesh
		add_child(model)
		
		shape = ShapeCast3D.new()
		add_child(shape)
		shape.shape = SphereShape3D.new()
		shape.shape.radius = data.radius
		
		model.global_position = muzle_position

func get_stats_from_node(node : Node) -> Stats:
	
	for n : Node in node.get_children():
		if n is Stats:
			return n
	
	return null

func check_colision() -> void:
	if data.speed < 0.0:
		while true:
			ray.force_raycast_update()
			if ray.is_colliding():
				var stats : Stats = get_stats_from_node(ray.get_collider())
				if stats == null:
					break
				else:
					if data.faction != stats.faction:
						stats.health -= data.damage
						queue_free()
						break
					else:
						ray.add_exception(ray.get_collider())
						continue
				
			else:
				break
	else:
		for i : int in shape.get_collision_count():
			var stats : Stats = get_stats_from_node(shape.get_collider(i))
			if stats != null:
				if data.faction != stats.faction:
					stats.health -= data.damage
					queue_free()
					break
				else:
					continue
			else:
				queue_free()

func _physics_process(delta: float) -> void:
	if data.speed < 0.0:
		check_colision()
	else:
		shape.position.z -= data.speed * delta
		
		check_colision()
		
		if data.range < model.position.length():
			queue_free()

func _process(delta: float) -> void:
	if data.speed < 0.0:
		pass
	else:
		model.position = model.position.move_toward(shape.position,delta * data.speed)
