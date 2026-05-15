@tool
extends Node3D
class_name GunModel

@export var gun : Node3D

@export var muzle : Node3D

@export var arm_l : Node3D
@export var pole_l : Node3D
@export var hand_l : Node3D

@export var arm_r : Node3D
@export var pole_r : Node3D
@export var hand_r : Node3D

@export var animation_player : AnimationPlayer

@export var reload_animation : String = "reload"

var is_shoting : bool = false
@export var shot_animation : String = "shot"

@export var is_auto : bool = false

@export var reload : bool : 
	set(value):
		animation_player.play(reload_animation)

@export var case_ejector : GPUParticles3D

@export var shot : bool : 
	set(value):
		
		shot = value
		
		if case_ejector != null:
			case_ejector.emitting = shot
		
		if animation_player != null:
			
			if is_auto:
				if value:
					animation_player.play(shot_animation)
				else:
					animation_player.stop()
			else:
				animation_player.stop()
				animation_player.play(shot_animation)
				
				if case_ejector != null:
					await get_tree().create_timer(1.0 / case_ejector.amount).timeout
					case_ejector.emitting = false
				
			

@export var label : Label3D

@export var display_text : String :
	set(value):
		display_text = value
		if label != null:
			label.text = display_text
