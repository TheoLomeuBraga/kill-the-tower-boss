extends Node3D
class_name ProjectBehavior

@export var data : ProjectileInfo = ProjectileInfo.new()

var model : MeshInstance3D
var ray : RayCast3D
var shape : ShapeCast3D

var progression : float = 0.0

var muzle_position : Vector3

const enemy_hit_particle : PackedScene = preload("res://particles/hit_particle/hit_particle.tscn")

var ricochetes_left : int = 0

func start_ray() -> void:
	ray = RayCast3D.new()
	ray.target_position = Vector3(0.0,0.0,-data.range)
	add_child(ray)

func start_shape() -> void:
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

func start() -> void:
	
	ricochetes_left = data.ricochet
	
	if data.speed < 0.0:
		start_ray()
	else:
		start_shape()

func reset_bullet_position() -> void:
	if shape != null:
		shape.position = Vector3.ZERO
	
	if model != null:
		model.position = Vector3.ZERO
	

func get_stats_from_node(node : Node) -> Stats:
	
	for n : Node in node.get_children():
		if n is Stats:
			return n
	
	return null

func check_collision_ray() -> void:
	while true:
		var o : Node3D
		ray.force_raycast_update()
		if ray.is_colliding():
			var stats : Stats = get_stats_from_node(ray.get_collider())
			if stats == null:
				
				if ricochetes_left > 0:
					print("recochete")
					
					var new_pos : Vector3 = ray.get_collision_point()
				
					var surface_normal : Vector3 = ray.get_collision_normal()
					var recochet_dir : Vector3 = (-global_basis.z).bounce(surface_normal)
					
					global_position = new_pos + (recochet_dir * data.radius * 0.1)
					look_at(global_position+recochet_dir)
					
					ricochetes_left -= 1
					reset_bullet_position()
					
					'''
					var m : MeshInstance3D = MeshInstance3D.new()
					m.mesh = BoxMesh.new()
					get_parent().add_child(m)
					m.global_position = global_position
					'''
					
					return
					
				
				if data.spaw_on_colision != null:
					o = data.spaw_on_colision.instantiate()
					get_parent().add_child(o)
					o.global_position = ray.get_collision_point()
				
				queue_free()
				
				break
			else:
				if data.faction != stats.faction:
					var target : Node3D = ray.get_collider()
					var shape_id : int = ray.get_collider_shape()
					var owner_id : int = target.shape_find_owner(shape_id)
					var col_shape : CollisionShape3D = target.shape_owner_get_owner(owner_id)

					stats.health -= stats.calculate_damage_on(data.damage,col_shape)
					
					if data.spaw_on_colision != null:
						o = data.spaw_on_colision.instantiate()
						get_parent().add_child(o)
						o.global_position = ray.get_collision_point()
					
					o = enemy_hit_particle.instantiate()
					get_parent().add_child(o)
					o.global_position = ray.get_collision_point()
					
					
					queue_free()
					break
				else:
					ray.add_exception(ray.get_collider())
					continue
			
		else:
			queue_free()
			break

func check_collision_shape() -> void:
	var o : Node3D
	for i : int in shape.get_collision_count():
		var stats : Stats = get_stats_from_node(shape.get_collider(i))
		if stats != null:
			if data.faction != stats.faction:
				
				var target : Node3D = shape.get_collider(i)
				var shape_id : int = shape.get_collider_shape(i)
				var owner_id : int = target.shape_find_owner(shape_id)
				var col_shape : CollisionShape3D = target.shape_owner_get_owner(owner_id)
				
				stats.health -= stats.calculate_damage_on(data.damage,col_shape)
				
				if data.spaw_on_colision != null:
					o = data.spaw_on_colision.instantiate()
					get_parent().add_child(o)
					o.global_position = shape.get_collision_point(i)
				
				o = enemy_hit_particle.instantiate()
				get_parent().add_child(o)
				o.global_position = shape.get_collision_point(i)
				
				queue_free()
				break
			else:
				continue
		else:
			
			if ricochetes_left > 0:
				
				var new_pos : Vector3 = shape.get_collision_point(i)
				
				var surface_normal : Vector3 = shape.get_collision_normal(i)
				var recochet_dir : Vector3 = (-global_basis.z).bounce(surface_normal)
				
				global_position = new_pos + (surface_normal * data.radius * 2.0)
				look_at(global_position+recochet_dir)
				
				ricochetes_left -= 1
				reset_bullet_position()
				
				'''
				var m : MeshInstance3D = MeshInstance3D.new()
				m.mesh = BoxMesh.new()
				get_parent().add_child(m)
				m.global_position = global_position
				'''
				
				
				return
			
			if data.spaw_on_colision != null:
				o = data.spaw_on_colision.instantiate()
				get_parent().add_child(o)
				o.global_position = model.global_position
			
			queue_free()
	

func check_colision() -> void:
	if data.speed < 0.0:
		check_collision_ray()
	else:
		check_collision_shape()

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
