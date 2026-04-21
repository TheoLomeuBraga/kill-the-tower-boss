@tool
extends Node3D
class_name PlayerModel

@export var arms : ArmsModel
@export var gun_animations : GunAnimations
@export var gun : GunModel


func _process(delta: float) -> void:
	if arms != null and gun_animations != null and gun != null:
		gun.gun.global_transform = gun_animations.gun.global_transform
		
		arms.arm_l.global_transform = gun.arm_l.global_transform
		arms.pole_l.global_transform = gun.pole_l.global_transform
		arms.hand_l.global_transform = gun.hand_l.global_transform
		
		arms.arm_r.global_transform = gun.arm_r.global_transform
		arms.pole_r.global_transform = gun.pole_r.global_transform
		arms.hand_r.global_transform = gun.hand_r.global_transform
		
		
