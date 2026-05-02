extends CharacterBody3D
class_name TestDumy

func recive_damage(damage : int) -> void:
	$Label3D.text = str(damage)
	$Label3D.modulate = Color.RED
