extends Node3D

@onready var body : CharacterBody3D = $".."
@onready var a : RayCast3D = $a
@onready var b : RayCast3D = $b

func _physics_process(delta: float) -> void:
	if not a.is_colliding() or not b.is_colliding():
		return
	
	if not Input.is_action_pressed("foward"):
		return
	
	var a_dist : float = a.global_position.distance_to(a.get_collision_point())
	body.global_position.y += a.target_position.length() - a_dist
