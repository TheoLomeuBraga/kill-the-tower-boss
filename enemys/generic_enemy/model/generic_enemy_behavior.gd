extends Node

@onready var navegator : Navegator = $"../Navegator"

@onready var animation_tree : AnimationTree = $"../AnimationTree"

func _physics_process(delta: float) -> void:
	if Player.player:
		navegator.target_position = Player.player.global_position
		navegator.is_navegating = Player.player.global_position.distance_to(get_parent().global_position) > 5.0
		
		if navegator.is_navegating:
			navegator.look_target =  Navegator.LookTarget.DIRECTION
			animation_tree.set("parameters/Transition/transition_request","walk")
		else:
			navegator.look_target =  Navegator.LookTarget.TARGET
			animation_tree.set("parameters/Transition/transition_request","idle")
