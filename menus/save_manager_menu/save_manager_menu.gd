extends Control
class_name SaveManagerMenu

signal on_close()

var save_display_scene : PackedScene = load("res://menus/save_manager_menu/save_display/save_display.tscn")
var save_delete_confirmation_scene : PackedScene = load("res://menus/save_manager_menu/save_delete_confirmation/save_delete_confirmation.tscn")

func load_game(save:String) -> void:
	SaveSystem.load_game(save)
	SceneManager.load_map(SaveSystem.game_data["current_level"])

var confirm_save_deletion : bool = false

func reprocess_saves() -> void:
	
	for n:Node in $VBoxContainer/Control/Panel/ScrollContainer/VBoxContainer.get_children():
		n.queue_free()
	
	var i : int = 0
	for save_name:String in SaveSystem.get_save_list():
		
		var save_data : Dictionary = SaveSystem.load_save(save_name)
		
		if not save_data.has("unix_time_last_save"):
			continue
		
		
		var sd : SaveDisplay = create_save_display(save_name,save_data["unix_time_last_save"])
		if i == 0:
			sd.focus()
		i+=1

func delete_game(save:String) -> void:
	
	var sdcs : SaveDeleteConfirmationScreen = save_delete_confirmation_scene.instantiate()
	get_parent().add_child(sdcs)
	visible = false
	
	confirm_save_deletion = false
	sdcs.confirmation.connect(func(v):confirm_save_deletion=v)
	
	await sdcs.confirmation
	
	visible = true
	sdcs.queue_free()
	
	if confirm_save_deletion:
		SaveSystem.erase_game(save)
	
	reprocess_saves()

func create_save_display(save_name:String,unit_last_used_time:float,map_name:String="",image:Texture=load("res://icon.svg")) -> SaveDisplay:
	var sd :SaveDisplay = save_display_scene.instantiate()
	$VBoxContainer/Control/Panel/ScrollContainer/VBoxContainer.add_child(sd)
	sd.set_display(save_name,unit_last_used_time,map_name,image)
	sd.on_load.connect(load_game.bind(save_name))
	sd.on_delete.connect(delete_game.bind(save_name))
	return sd

func _ready() -> void:
	reprocess_saves()
	
	$VBoxContainer/HBoxContainer/back.pressed.connect(on_close.emit)

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("ui_cancel"):
		on_close.emit()
