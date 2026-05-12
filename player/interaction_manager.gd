extends Node

@export var interaction_ray : RayCast3D

var rb_on_foucus : RigidBody3D

func _physics_process(delta: float) -> void:
	
	if interaction_ray == null:
		return
	
	if Input.is_action_just_pressed("interact"):
		if rb_on_foucus == null:
			if interaction_ray.is_colliding() and interaction_ray.get_collider() is RigidBody3D:
				rb_on_foucus = interaction_ray.get_collider()
		else:
			rb_on_foucus = null
	
	if rb_on_foucus != null:
		var target_pos : Vector3 = interaction_ray.global_position + ( interaction_ray.global_basis.z * -2.0 )
		rb_on_foucus.linear_velocity = (target_pos - rb_on_foucus.global_position) * 10.0
		
		rb_on_foucus.angular_velocity = (Vector3.ZERO - rb_on_foucus.global_rotation) * 10.0
		
