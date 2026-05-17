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

@export var animation_player : AnimationPlayer

@export var reload_animation : String = "reload"

var is_shoting : bool = false
@export var shot_animations : Array[String] = ["shot"]
var shot_animation_id : int = 0
func get_current_shot_animation() -> String:
	return shot_animations[shot_animation_id]

@export var is_auto : bool = false

@export var reload : bool : 
	set(value):
		animation_player.play(reload_animation)

@export var case_ejectors : Array[GPUParticles3D]
var case_ejector_id : int = 0
func get_current_case_ejector() -> GPUParticles3D:
	return case_ejectors[case_ejector_id]

@export var shot : bool : 
	set(value):
		
		shot = value
		
		
		
		if case_ejectors.size() > 0:
			
			case_ejector_id = (case_ejector_id + 1) % case_ejectors.size()
			
			if is_auto:
				for gp : GPUParticles3D in case_ejectors:
					gp.emitting = shot
			else:
				get_current_case_ejector().emitting = shot
		
		if animation_player != null:
			
			if is_auto:
				if value:
					animation_player.play(get_current_shot_animation(),0.1)
				else:
					animation_player.stop()
			else:
				animation_player.stop()
				animation_player.play(get_current_shot_animation(),0.1)
				
				if case_ejectors.size() > 0:
					if is_auto:
						pass
					else:
						await get_tree().create_timer(1.0 / get_current_case_ejector().amount).timeout
						get_current_case_ejector().emitting = false
		
		shot_animation_id = (shot_animation_id + 1) % shot_animations.size()
		muzle_id = (muzle_id + 1) % shot_animations.size()

@export var labels : Array[Label3D]

@export var display_text : String :
	set(value):
		display_text = value
		for l : Label3D in labels:
			l.text = display_text
