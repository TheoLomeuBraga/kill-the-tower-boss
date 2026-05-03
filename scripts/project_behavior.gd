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
		model.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		add_child(model)
		
		shape = ShapeCast3D.new()
		add_child(shape)
		shape.shape = SphereShape3D.new()
		shape.shape.radius = data.radius
		shape.target_position = Vector3.ZERO
		
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
						var target : Node3D = ray.get_collider()
						var shape_id : int = ray.get_collider_shape()
						var owner_id : int = target.shape_find_owner(shape_id)
						var col_shape : CollisionShape3D = target.shape_owner_get_owner(owner_id)

						stats.health -= stats.calculate_damage_on(data.damage,col_shape)
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
					
					var target : Node3D = shape.get_collider(i)
					var shape_id : int = shape.get_collider_shape(i)
					var owner_id : int = target.shape_find_owner(shape_id)
					var col_shape : CollisionShape3D = target.shape_owner_get_owner(owner_id)
					
					stats.health -= stats.calculate_damage_on(data.damage,col_shape)
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
		model.position = model.position.move_toward(shape.position,delta * (data.speed / 2.0))
