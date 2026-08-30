extends Node

signal on_binds_change() 
signal on_setting_change(String,Variant)

const mouse_sensitivity_correction : float = 600.0

var is_curently_rebinding:bool = false

const base_settings : Dictionary = {
	
	"keyboard_sensitivity_mouse": 3.0,
	
	"controller_sensitivity_controller": 3.0,
	"controller_deadzone_left": 0.2,
	"controller_deadzone_right": 0.2,
	
	"video_fov": 90,
	"video_gun_fov": 90,
	"video_full_screen": false,
	
	"audio_volume": 80,
	"audio_volume_sfx": 100,
	"audio_volume_music": 100,
	"audio_volume_dialogue": 100,
}

var settings : Dictionary

var input_map : Dictionary[String,InputEvent]

func change_setting(name:String,value:Variant) -> void:
	
	settings[name] = value
	on_setting_change.emit(name,value)
	

var original_inputs_keyboard : Dictionary[String,Array]
var original_inputs_controller : Dictionary[String,Array]
func setup_original_inputmap() -> void:
	
	original_inputs_keyboard = {}
	original_inputs_controller = {}
	
	for action_name : String in InputMap.get_actions():
		
		original_inputs_keyboard[action_name] = []
		original_inputs_controller[action_name] = []
		
		if not action_name.begins_with("ui_"):
			for input_action : InputEvent in InputMap.action_get_events(action_name):
				if input_action is InputEventKey or input_action is InputEventMouseButton:
					original_inputs_keyboard[action_name].push_back(input_action)
				elif input_action is InputEventJoypadButton or input_action is InputEventJoypadMotion:
					original_inputs_controller[action_name].push_back(input_action)

func reset_input_binds(type:GlobalEnums.InputDeviceTypes) -> void:
	for action_name : String in InputMap.get_actions():
		if not action_name.begins_with("ui_"):
			for input_action : InputEvent in InputMap.action_get_events(action_name):
				if type == GlobalEnums.InputDeviceTypes.KEYBOARD_MOUSE and (input_action is InputEventKey or input_action is InputEventMouseButton):
					InputMap.action_erase_event(action_name,input_action)
				elif type == GlobalEnums.InputDeviceTypes.CONTROLLER and (input_action is InputEventJoypadButton or input_action is InputEventJoypadMotion):
					InputMap.action_erase_event(action_name,input_action)
	
	match type:
		GlobalEnums.InputDeviceTypes.KEYBOARD_MOUSE:
			for key:String in original_inputs_keyboard:
				for ie : InputEvent in original_inputs_keyboard[key]:
					InputMap.action_add_event(key,ie)
		GlobalEnums.InputDeviceTypes.CONTROLLER:
			for key:String in original_inputs_controller:
				for ie : InputEvent in original_inputs_controller[key]:
					InputMap.action_add_event(key,ie)
	
	on_binds_change.emit()

func reset_settings(type:String="") -> void:
	
	if type == "keyboard_map":
		reset_input_binds(GlobalEnums.InputDeviceTypes.KEYBOARD_MOUSE)
	elif type == "controller_map":
		reset_input_binds(GlobalEnums.InputDeviceTypes.CONTROLLER)
	
	for k:String in base_settings:
		if k.begins_with(type):
			settings[k] = base_settings[k]
	
	for key in settings:
		change_setting(key,settings[key])
	



#~/.local/share/kill_the_tower_boss/settings/
func try_load_settings(name:String) -> Dictionary:
	
	if not FileAccess.file_exists(name):
		printerr("fail load: ",name)
		return {}
	
	var cfg_file : FileAccess = FileAccess.open(name, FileAccess.READ)
	var data : String = cfg_file.get_as_text()
	var json : JSON = JSON.new()
	var error = json.parse(data)
	
	if error == OK:
		return json.data
	
	printerr("fail load: ",name)
	return {}
	
	

func try_load_binds(name:String) -> Variant:
	
	if not FileAccess.file_exists(name):
		printerr("fail load: ",name)
		return {}
	
	var cfg_file : FileAccess = FileAccess.open(name, FileAccess.READ)
	var ret = cfg_file.get_var(true)
	
	if not ret:
		printerr("fail load: ",name)
	return ret

func load_state() -> void:
	
	var new_settings : Dictionary = try_load_settings("user://settings/settings.settings")
	if new_settings.size() == 0:
		new_settings = try_load_settings("user://settings/settings.settings1")
	
	for key in new_settings:
		change_setting(key,new_settings[key])
	
	#binds
	var new_binds : Variant = try_load_binds("user://settings/binds.binds")
	if not new_binds:
		new_binds = try_load_binds("user://settings/binds.binds1")
	if not new_binds:
		return
	
	#remove base binds
	for key : String in InputMap.get_actions():
		if key.begins_with("ui_"):
			continue
		for event : InputEvent in InputMap.action_get_events(key):
			if event is InputEventKey or event is InputEventMouseButton or event is InputEventJoypadButton or event is InputEventJoypadMotion:
				InputMap.action_erase_event(key,event)
	
	#load
	for key : String in new_binds:
		if key.begins_with("ui_"):
			continue
		for event : InputEvent in new_binds[key]:
			InputMap.action_add_event(key,event)
			
	
	
	
	on_binds_change.emit()

func save_state() -> void:
	DirAccess.make_dir_absolute("user://settings")
	
	#settings
	
	var data : String = JSON.stringify(settings,"\t")
	
	var cfg_file : FileAccess = FileAccess.open("user://settings/settings.settings", FileAccess.WRITE)
	cfg_file.store_line(data)
	cfg_file.close()
	
	cfg_file = FileAccess.open("user://settings/settings.settings1", FileAccess.WRITE)
	cfg_file.store_line(data)
	cfg_file.close()
	
	var binds : Dictionary[String,Array]
	for key : String in InputMap.get_actions():
		
		if key.begins_with("ui_"):
			continue
		
		binds[key] = []
		for event : InputEvent in InputMap.action_get_events(key):
			binds[key].push_back(event)
	
	#binds
	
	cfg_file = FileAccess.open("user://settings/binds.binds", FileAccess.WRITE)
	cfg_file.store_var(binds,true)
	cfg_file.close()
	
	cfg_file = FileAccess.open("user://settings/binds.binds1", FileAccess.WRITE)
	cfg_file.store_var(binds,true)
	cfg_file.close()


func _ready() -> void:
	
	setup_original_inputmap()
	reset_settings()
	load_state()
	
	for key in settings:
		on_setting_change.emit(key,settings[key])
