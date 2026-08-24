extends Node3D

@onready var body : CharacterBody3D = $".."
@onready var a : RayCast3D = $a
@onready var b : RayCast3D = $b

func _physics_process(delta: float) -> void:
	
	var input_dir : Vector3 = body.basis * Vector3(Input.get_axis("left","right"),0.0,Input.get_axis("foward","back")).normalized()
	var target : Vector3 = global_position + input_dir
	look_at(target)
	
	if not a.is_colliding() or not b.is_colliding():
		return
	
	if not input_dir.length() > 0.0:
		return
	
	if a.get_collision_normal().dot(b.get_collision_normal()) > 0.2:
		return
	
	var a_dist : float = a.global_position.distance_to(a.get_collision_point())
	body.global_position.y += a_dist
	body.velocity.y = 0.0
	
	
