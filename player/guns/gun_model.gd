@tool
extends Node3D
class_name GunModel

@export var gun : Node3D

@export var muzles : Array[Node3D]
var muzle_id : int = 0
func get_muzle() -> Node3D:
	return muzles[muzle_id]

@export var arm_l : Node3D
@export var pole_l : Node3D
@export var hand_l : Node3D

@export var arm_r : Node3D
@export var pole_r : Node3D
@export var hand_r : Node3D

@export var gun_animation_tree : GunsAnimationTree

@export var is_akimbo : bool = false

var is_shoting : bool = false
var shot_animation_id : int = 0

@export var is_auto : bool = false

@export var reload : bool : 
	set(value):
		gun_animation_tree.reload()

@export var case_ejectors : Array[GPUParticles3D]
var case_ejector_id : int = 0
func get_current_case_ejector() -> GPUParticles3D:
	return case_ejectors[case_ejector_id]

func play_shot_animation() -> void:
	if is_akimbo:
		if is_auto:
			gun_animation_tree.shot()
			gun_animation_tree.shot_2()
		else:
			[gun_animation_tree.shot,gun_animation_tree.shot_2][shot_animation_id].call()
	else:
		gun_animation_tree.shot()

@export var shot : bool : 
	set(value):
		

		
		if case_ejectors.size() > 0:
			
			case_ejector_id = (case_ejector_id + 1) % case_ejectors.size()
			
			if is_auto:
				for gp : GPUParticles3D in case_ejectors:
					gp.emitting = value
			else:
				get_current_case_ejector().emitting = value
		
		if is_auto:
			if shot != value:
				shot = value
				if value:
					play_shot_animation()
				else:
					gun_animation_tree.stop_shot()
		else:
			play_shot_animation()
			
			if case_ejectors.size() > 0:
				if is_auto:
					pass
				else:
					await get_tree().create_timer(1.0 / get_current_case_ejector().amount).timeout
					get_current_case_ejector().emitting = false
		
		shot_animation_id = (shot_animation_id + 1) % 2
		muzle_id = (muzle_id + 1) % muzles.size()

@export var alt_shot : bool : 
	set(value):
		alt_shot = value
		gun_animation_tree.shot_2()

@export var labels : Array[Label3D]

@export var display_text : String :
	set(value):
		display_text = value
		for l : Label3D in labels:
			l.text = display_text
