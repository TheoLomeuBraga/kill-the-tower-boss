extends Navegator

func _process(delta: float) -> void:
	if Player.player:
		target_position = Player.player.global_position
		is_navegating = Player.player.global_position.distance_to(get_parent().global_position) > 5.0
		
		if is_navegating:
			look_target =  Navegator.LookTarget.DIRECTION
		else:
			look_target =  Navegator.LookTarget.TARGET
