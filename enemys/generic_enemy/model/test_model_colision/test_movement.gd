extends Node

@onready var b : CharacterBody3D = $".."

func _physics_process(delta: float) -> void:
	
	b.velocity.x = Input.get_axis("left","right") * 4.0
	b.velocity.z = Input.get_axis("foward","back") * 4.0
	
	if Input.is_action_pressed("jump"):
		b.velocity.y = 2.0
	else:
		b.velocity.y = -2.0
	
	b.move_and_slide()
