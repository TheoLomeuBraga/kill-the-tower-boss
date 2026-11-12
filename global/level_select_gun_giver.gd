extends Node

var guns : Array[GunInfo]

func _process(delta: float) -> void:
	if guns.size() and Player.player:
		for gi : GunInfo in guns:
			Player.player.gun_control.add_gun(gi)
		guns.clear()
