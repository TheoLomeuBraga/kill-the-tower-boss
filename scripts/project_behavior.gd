extends Node3D
class_name ProjectBehavior

@export var data : ProjectileInfo = ProjectileInfo.new()

var model : Node3D
var ray : RayCast3D
var shape : ShapeCast3D

var progression : float = 0.0

var muzle_position : Vector3
var target_position : Vector3



var ricochetes_left : int = 0
var penetrations_left : int = 0

func start_ray() -> void:
	
	
	
	ray = RayCast3D.new()
	ray.target_position = Vector3(0.0,0.0,-data.distance)
	add_child(ray)
	
	if data.model != null:
		model = data.model.instantiate()
		get_parent().add_child(model)
		model.global_position = muzle_position
		model.look_at(target_position)

func start_shape() -> void:
	
	
	shape = ShapeCast3D.new()
	add_child(shape)
	shape.shape = SphereShape3D.new()
	shape.shape.radius = data.radius
	shape.target_position = Vector3.ZERO
	
	if data.model != null:
		model = data.model.instantiate()
		add_child(model)
		model.global_position = muzle_position

func start() -> void:
	
	ricochetes_left = data.ricochet
	penetrations_left = data.penetrations
	
	if data.speed < 0.0:
		start_ray()
	else:
		start_shape()

func reset_bullet_position() -> void:
	if shape != null:
		shape.position = Vector3.ZERO
	
	if model != null and shape != null:
		model.position = Vector3.ZERO
	
	muzle_position = Vector3.ZERO
	
	if ray != null and data.model != null:
		model = data.model.instantiate()
		get_parent().add_child(model)
		if ray.is_colliding():
			model.position = ray.get_collision_point()
		model.look_at(global_basis.z * -100.0)

func self_destruct() -> void:
	
	var eb : ExplosionBehavior = ExplosionBehavior.new()
	eb.data = data.explosion_data
	
	if data.explosion_data != null:
		if data.speed < 0.0:
			
			if ray.is_colliding():
				
				get_parent().add_child(eb)
				
				eb.global_position = ray.get_collision_point()
				
				eb.start()
			
		else:
			
			get_parent().add_child(eb)
			
			eb.global_position = shape.global_position
			
			eb.start()
	
	
	queue_free()


func check_collision_ray() -> void:
	while true:
		var o : Node3D
		ray.force_raycast_update()
		if ray.is_colliding():
			var stats : Stats = Stats.get_stats_from_node(ray.get_collider())
			if stats == null:
				
				if ricochetes_left > 0:
					
					var new_pos : Vector3 = ray.get_collision_point()
				
					var surface_normal : Vector3 = ray.get_collision_normal()
					var recochet_dir : Vector3 = (-global_basis.z).bounce(surface_normal)
					
					global_position = new_pos + (recochet_dir * data.radius * 0.1)
					look_at(global_position+recochet_dir)
					
					ricochetes_left -= 1
					reset_bullet_position()
					
					return
					
				
				if data.spaw_on_colision != null:
					o = data.spaw_on_colision.instantiate()
					get_parent().add_child(o)
					o.global_position = ray.get_collision_point()
				
				self_destruct()
				
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
					
					o = Stats.enemy_hit_particle.instantiate()
					get_parent().add_child(o)
					o.global_position = ray.get_collision_point()
					
					if penetrations_left > 0:
						penetrations_left -= 1
						ray.add_exception(ray.get_collider())
						break
					
					self_destruct()
					break
				else:
					ray.add_exception(ray.get_collider())
					continue
			
		else:
			self_destruct()
			break

func check_collision_shape() -> void:
	var o : Node3D
	for i : int in shape.get_collision_count():
		var stats : Stats = Stats.get_stats_from_node(shape.get_collider(i))
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
				
				o = Stats.enemy_hit_particle.instantiate()
				get_parent().add_child(o)
				o.global_position = shape.get_collision_point(i)
				
				if penetrations_left > 0:
					penetrations_left -= 1
					shape.add_exception(shape.get_collider(i))
					break
				
				self_destruct()
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
				
				
				return
			
			if data.spaw_on_colision != null:
				o = data.spaw_on_colision.instantiate()
				get_parent().add_child(o)
				if model != null:
					o.global_position = model.global_position
			
			self_destruct()
	

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
		
		if model != null and data.distance < model.position.length():
			queue_free()

func _process(delta: float) -> void:
	if data.speed < 0.0:
		pass
	else:
		if model != null:
			model.position = model.position.move_toward(shape.position,delta * (data.speed / 2.0))
