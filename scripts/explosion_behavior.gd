extends Node3D
class_name ExplosionBehavior

@export var data : ExplosionInfo = ExplosionInfo.new()

var shape : ShapeCast3D

func start() -> void:
	shape = ShapeCast3D.new()
	shape.target_position = Vector3.ZERO
	var sphere_shape : SphereShape3D = SphereShape3D.new()
	sphere_shape.radius = data.radius
	shape.shape = sphere_shape
	add_child(shape)
	
	if data.model != null:
		var n : Node3D = data.model.instantiate()
		get_parent().add_child(n)
		n.global_position = global_position
	
	await get_tree().process_frame
	
	shape.force_shapecast_update()
	
	for i : int in shape.get_collision_count():
		
		var stats : Stats = Stats.get_stats_from_node(shape.get_collider(i))
		
		if stats != null:
			if stats.faction != GlobalEnums.Faction.FRIENDLY:
				var hit_particle : Node3D = Stats.enemy_hit_particle.instantiate()
				get_parent().add_child(hit_particle)
				hit_particle.global_position = shape.get_collision_point(i)
			
			if stats.faction != data.faction:
				stats.damage(data.damage,data.damage_type)
			else:
				stats.damage(data.friendly_damage,data.damage_type)
			
		
		if shape.get_collider(i) is RigidBody3D:
			var rb : RigidBody3D = shape.get_collider(i)
			rb.linear_velocity += (rb.global_position - global_position).normalized() * (data.knock_back / rb.mass)
		elif shape.get_collider(i) is CharacterBody3D:
			var cb : CharacterBody3D = shape.get_collider(i)
			cb.velocity += (cb.global_position - global_position).normalized() * data.knock_back
		
	
	queue_free()
