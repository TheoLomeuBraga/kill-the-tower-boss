extends CharacterBody3D
class_name TestDumy

func recive_damage(damage : int) -> void:
	$Label3D.text = str(damage)
	$Label3D.modulate = Color.RED

func _physics_process(delta: float) -> void:
	velocity.y -= 9.8 * delta
	if is_on_floor():
		velocity.x = move_toward(velocity.x,0.0,100.0*delta)
		velocity.z = move_toward(velocity.z,0.0,100.0*delta)
	move_and_slide()
