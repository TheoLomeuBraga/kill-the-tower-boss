extends Node

signal on_save()
signal on_load()

var save_name : String = "save_1"

var data : Dictionary[String,Dictionary] = {}

func try_load_data(path:String) -> Variant:
	if not FileAccess.file_exists(name):
		printerr("fail load: ",name)
		return {}
	
	var save_file : FileAccess = FileAccess.open(name, FileAccess.READ)
	var ret = save_file.get_var(true)
	if not ret:
		printerr("fail load: ",name)
	
	return ret

func load_data() -> void:
	var new_data = try_load_data("user://saves/"+save_name+".save")
	if not new_data:
		new_data = try_load_data("user://saves/"+save_name+".save1")
	
	if new_data:
		data = new_data
	
	on_load.emit()

func save_data() -> void:
	on_save.emit()
	
	DirAccess.make_dir_absolute("user://saves")
	var save_file : FileAccess
	
	save_file = FileAccess.open("user://saves/"+save_name+".save", FileAccess.WRITE)
	save_file.store_var(data,true)
	save_file.close()
	
	save_file = FileAccess.open("user://saves/"+save_name+".save1", FileAccess.WRITE)
	save_file.store_var(data,true)
	save_file.close()

func delete_save() -> void:
	DirAccess.remove_absolute("user://saves/"+save_name+".save")
	DirAccess.remove_absolute("user://saves/"+save_name+".save1")

func set_save_data(name:String,dictionary:Dictionary) -> void:
	data[name] = dictionary.duplicate()

func has(name:String) -> bool:
	return data.has(name)

func get_ref(name:String) -> Dictionary:
	if data.has(name):
		return data[name].duplicate()
	return {}
