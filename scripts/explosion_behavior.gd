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
	
	print(shape.get_collision_count())
	
	for i : int in shape.get_collision_count():
		
		var hit_particle : Node3D = Stats.enemy_hit_particle.instantiate()
		get_parent().add_child(hit_particle)
		hit_particle.global_position = shape.get_collision_point(i)
		
		var stats : Stats = Stats.get_stats_from_node(shape.get_collider(i))
		
		if stats != null:
			stats.health -= data.damage
	
	queue_free()
