@tool
extends Node3D
class_name PlayerModel

@export var arms : ArmsModel
@export var gun_animations : GunAnimations
@export var gun : GunModel

@export var gun_animator_rotation : Vector3 :
	set(value):
		gun_animator_rotation = value
		if gun_animations != null:
			gun_animations.rotation = value


func _process(delta: float) -> void:
	if arms != null and gun_animations != null and gun != null:
		gun.gun.global_transform = gun_animations.gun.global_transform
		
		arms.arm_l.global_transform = gun.arm_l.global_transform
		arms.pole_l.global_transform = gun.pole_l.global_transform
		arms.hand_l.global_transform = gun.hand_l.global_transform
		
		arms.arm_r.global_transform = gun.arm_r.global_transform
		arms.pole_r.global_transform = gun.pole_r.global_transform
		arms.hand_r.global_transform = gun.hand_r.global_transform
		

@export var guns_models : Dictionary[String,PackedScene]

var drop_wepon_tween : Tween

func set_gun( name : String ) -> void:
	if guns_models.has(name):
		
		if drop_wepon_tween != null:
			drop_wepon_tween.stop()
		
		gun_animations.drop_wepon_estate = 1.0
		
		gun.queue_free()
		gun = guns_models[name].instantiate()
		gun.visible = false
		arms.visible = false
		add_child(gun)
		
		drop_wepon_tween = create_tween()
		drop_wepon_tween.tween_property(gun_animations, "drop_wepon_estate", 0.0, 0.5)
		
		await get_tree().process_frame
		gun.visible = true
		arms.visible = true
		
		
	else:
		drop_wepon_tween = create_tween()
		drop_wepon_tween.tween_property(gun_animations, "drop_wepon_estate", 1.0, 0.5)
	
