extends Control

func new_game() -> void:
	
	#TODO: update to suport multiple saves
	PersistenceManager.clean()
	SaveSystem.clean()
	
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

var save_list : Array[String]

func continue_game() -> void:
	SaveSystem.save_name = save_list[0]
	SaveSystem.load_game()
	
	
	
	if SaveSystem.game_data.has("current_level") and SaveSystem.game_data["current_level"] != "":
		SceneManager.load_map(SaveSystem.game_data["current_level"])
	

func load_game() -> void:
	$ColorRect2.visible = true
	
	$ColorRect2/SaveManagerMenu.reprocess_saves()
	
	await $ColorRect2/SaveManagerMenu.on_close
	
	$ColorRect2.visible = false
	
	if save_list.size() > 0:
		$VBoxContainer/continue.grab_focus()
	else:
		$VBoxContainer/continue.disabled = true
		$VBoxContainer/load_game.disabled = true
		$VBoxContainer/new_game.grab_focus()

func _ready() -> void:
	
	save_list = SaveSystem.get_save_list()
	
	$VBoxContainer/continue.pressed.connect(continue_game)
	
	if save_list.size() > 0:
		$VBoxContainer/continue.grab_focus()
	else:
		$VBoxContainer/continue.disabled = true
		$VBoxContainer/load_game.disabled = true
		$VBoxContainer/new_game.grab_focus()
	
	$VBoxContainer/new_game.pressed.connect(new_game)
	
	$VBoxContainer/load_game.pressed.connect(load_game)
	
	$VBoxContainer/settings.pressed.connect(open_settings)
	$ColorRect/SettingsMenu.on_close.connect(on_close_settings)
	
	$VBoxContainer/quit_game.pressed.connect(get_tree().quit)
	
	
