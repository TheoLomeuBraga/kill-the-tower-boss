extends Control

func togle_noclip() -> void:
	if Player.player:
		Player.player.movement.toogle_noclip()

func no_hud() -> void:
	if Player.player:
		Player.player.wepon_layer.visible = not Player.player.wepon_layer.visible
		if Player.player.model.gun.cross:
			Player.player.model.gun.cross.visible = Player.player.wepon_layer.visible
		

func give_all() -> void:
	if Player.player:
		Player.player.gun_control.give_all()
		Player.player.keys.give_all()
		Player.player.stats.health = Player.player.stats.max_health

func _ready() -> void:
	visible = false
	
	$Panel/ScrollContainer/VBoxContainer/noclip.pressed.connect(togle_noclip)
	$Panel/ScrollContainer/VBoxContainer/nohud.pressed.connect(no_hud)
	$Panel/ScrollContainer/VBoxContainer/give_all.pressed.connect(give_all)


func _process(delta: float) -> void:
	
	if OS.has_feature("editor"):
		if Input.is_action_just_pressed("debug"):
			visible = not visible
			if visible:
				$Panel/ScrollContainer/VBoxContainer/noclip.grab_focus()
