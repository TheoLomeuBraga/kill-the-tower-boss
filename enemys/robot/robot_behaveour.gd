extends Node

@onready var robot_animation_simplefier : RobotAnimationSimplefier = $"../RobotAnimationSimplefier"

@onready var visualizer : RayCast3D = $"../player_visualizer"

var is_player_visible : bool = false
func check_player_visibility() -> bool:
	is_player_visible = false
	
	visualizer.look_at(Player.player.global_position)
	visualizer.force_raycast_update()
	if visualizer.is_colliding() and visualizer.get_collider() == Player.player:
		is_player_visible = true
	
	return is_player_visible

var state : Callable = idle_state

func idle_state(delta:float) -> void:
	return
