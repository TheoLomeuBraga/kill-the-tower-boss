extends Control

func togle_noclip() -> void:
	if Player.player:
		Player.player.movement.toogle_noclip()

func no_hud() -> void:
	if Player.player:
		Player.player.hud.visible = not Player.player.hud.visible
		if Player.player.model.gun.cross:
			Player.player.model.gun.cross.visible = Player.player.hud.visible
		

func _ready() -> void:
	visible = false
	
	$Panel/ScrollContainer/VBoxContainer/noclip.pressed.connect(togle_noclip)
	$Panel/ScrollContainer/VBoxContainer/nohud.pressed.connect(no_hud)



func _process(delta: float) -> void:
	
	if OS.has_feature("editor"):
		if Input.is_action_just_pressed("debug"):
			visible = not visible
			if visible:
				$Panel/ScrollContainer/VBoxContainer/noclip.grab_focus()
