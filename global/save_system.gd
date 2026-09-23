extends Node

signal on_save_game()
signal on_load_game()

var save_name : String = "save1"

var game_data : Dictionary = {
	"current_level": "",
	"inventory": {},
	"ammon": {},
	"unlocked_levels": [],
	"unix_time_creation": null,
	"unix_time_last_save": null,
}

func get_save_name(file_name:String,id:int) -> String:
	return "user://saves/" + file_name + ".save" + str(id)

func save_game() -> void:
	
	if not game_data["unix_time_creation"]:
		game_data["unix_time_creation"] = Time.get_unix_time_from_system()
	game_data["unix_time_last_save"] = Time.get_unix_time_from_system()
	
	
	on_save_game.emit()
	
	DirAccess.make_dir_absolute("user://saves")
	
	var save : FileAccess = FileAccess.open(get_save_name(save_name,0), FileAccess.WRITE)
	save.store_var(game_data,true)
	save.close()
	
	save = FileAccess.open(get_save_name(save_name,1), FileAccess.WRITE)
	save.store_var(game_data,true)
	save.close()

func try_load_game(file_name:String,id:int) -> Variant:
	
	if not FileAccess.file_exists(get_save_name(file_name,id)):
		printerr("fail to load "+get_save_name(file_name,id))
		return null
	
	var save : FileAccess = FileAccess.open(get_save_name(file_name,id), FileAccess.READ)
	var data : Variant = save.get_var(true)
	save.close()
	
	if not data:
		printerr("fail to load "+get_save_name(file_name,id) + " corrupt data")
	return data


func load_save(file_name:String) -> Variant:
	var save : Variant = try_load_game(file_name,0)
	if not save:
		save = try_load_game(file_name,1)
	if not save:
		save = {}
	
	
	if save:
		return save
	
	return null

func load_game() -> void:
	var save : Variant = load_save(save_name)
	
	if save:
		game_data = save
	
	on_load_game.emit()

func erase_game() -> void:
	DirAccess.remove_absolute(get_save_name(save_name,0))
	DirAccess.remove_absolute(get_save_name(save_name,1))

func clean():
	game_data = {}

func register(name:String,dictionary:Dictionary) -> void:
	game_data[name] = dictionary

func has(node:Node) -> bool:
	return game_data.has(node.get_path())

func get_ref(d_name:String) -> Dictionary:
	if game_data.has(d_name):
		return game_data[d_name]
	return {}

var saves_last_unix_times : Dictionary[String,float] = {}
func custom_sort(a:String,b:String) -> bool:
	return saves_last_unix_times[a] < saves_last_unix_times[b]

func get_save_list() -> Array[String]:
	
	if DirAccess.make_dir_absolute("user://saves"):
		
		saves_last_unix_times = {}
		
		var saves_names : Array[String] = []
		
		var files : PackedStringArray = DirAccess.get_files_at("user://saves")
		for f:String in files:
			
			if not f.split(".")[1].begins_with("save"):
				continue
			
			var file_name : String = f.split(".")[0]
			
			if not saves_names.has(file_name):
				saves_names.push_back(file_name)
			
		
		for f:String in saves_names:
			var v :Variant = load_save(f)
			if not v or not v.has("unix_time_last_save"):
				continue
			saves_last_unix_times[f] = v["unix_time_last_save"]
		
		saves_names.sort_custom(custom_sort)
		
		return saves_names
	
	
	return []
