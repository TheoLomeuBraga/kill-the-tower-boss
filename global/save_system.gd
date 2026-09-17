extends Node

signal on_save_game()
signal on_load_game()

var save_name : String = "save1"

var game_data : Dictionary = {}

func get_save_name(id:int) -> String:
	return "user://saves/" + save_name + ".save" + str(id)

func save_game() -> void:
	
	on_save_game.emit()
	
	DirAccess.make_dir_absolute("user://saves")
	
	var save : FileAccess = FileAccess.open(get_save_name(0), FileAccess.WRITE)
	save.store_var(game_data,true)
	save.close()
	
	save = FileAccess.open(get_save_name(1), FileAccess.WRITE)
	save.store_var(game_data,true)
	save.close()

func try_load_game(id:int) -> Variant:
	
	if not FileAccess.file_exists(get_save_name(id)):
		printerr("fail to load "+get_save_name(id))
		return null
	
	var save : FileAccess = FileAccess.open(get_save_name(id), FileAccess.READ)
	var data : Variant = save.get_var(true)
	save.close()
	
	if not data:
		printerr("fail to load "+get_save_name(id) + " corrupt data")
	return data



func load_game() -> void:
	var save : Variant = try_load_game(0)
	if not save:
		save = try_load_game(1)
	if not save:
		save = {}
	
	
	if save:
		game_data = save
	else:
		game_data = {}
	
	on_load_game.emit()

func erase_game() -> void:
	DirAccess.remove_absolute(get_save_name(0))
	DirAccess.remove_absolute(get_save_name(1))

func clean():
	game_data = {}

func register(name:String,dictionary:Dictionary) -> void:
	game_data[name] = dictionary

func has(node:Node) -> bool:
	return game_data.has(node.get_path())

func get_ref(name:String) -> Dictionary:
	if game_data.has(name):
		return game_data[name]
	return {}
