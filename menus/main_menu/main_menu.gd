extends Control

func new_game() -> void:
	SceneManager.load_map("res://levels/level_1/level_1.tscn")

func open_settings() -> void:
	$Label.visible = false
	$VBoxContainer.visible = false
	
	$ColorRect.visible = true
	$ColorRect/SettingsMenu.focus()

func on_close_settings() -> void:
	$Label.visible = true
	$VBoxContainer.visible = true
	
	$ColorRect.visible = false
	$VBoxContainer/continue.grab_focus()
	

func _ready() -> void:
	
	$VBoxContainer/continue.grab_focus()
	
	
	$VBoxContainer/new_game.pressed.connect(new_game)
	
	$VBoxContainer/settings.pressed.connect(open_settings)
	$ColorRect/SettingsMenu.on_close.connect(on_close_settings)
	
	$VBoxContainer/quit_game.pressed.connect(get_tree().quit)
