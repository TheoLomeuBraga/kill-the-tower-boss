extends Node

signal on_setting_change(String,Variant)

const mouse_sensitivity_correction : float = 600.0

const base_settings : Dictionary = {
	
	"keyboard_sensitivity_mouse": 6.0,
	
	"controller_sensitivity_controller": 6.0,
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
	

func reset_settings(type:String="") -> void:
	if type == "":
		settings = base_settings.duplicate()
	else:
		for k:String in base_settings:
			if k.begins_with(type):
				settings[k] = base_settings[k]
	
	for key in settings:
		change_setting(key,settings[key])

var original_inputs_keyboard : Dictionary[String,Array]
var original_inputs_controller : Dictionary[String,Array]
func setup_original_inputmap() -> void:
	
	original_inputs_keyboard = {}
	original_inputs_controller = {}
	
	for action_name : String in InputMap.get_actions():
		if not action_name.begins_with("ui_"):
			for input_action : InputEvent in InputMap.action_get_events(action_name):
				pass

func reset_input_binds(type:GlobalEnums.InputDeviceTypes) -> void:
	
	match type:
		GlobalEnums.InputDeviceTypes.KEYBOARD_MOUSE:
			pass
		GlobalEnums.InputDeviceTypes.CONTROLLER:
			pass


#~/.local/share/kill_the_tower_boss/settings/
func try_settings_load(name:String) -> Dictionary:
	
	if FileAccess.file_exists(name):
		var cfg_file : FileAccess = FileAccess.open(name, FileAccess.READ)
		var data : String = cfg_file.get_as_text()
		var json = JSON.new()
		var error = json.parse(data)
		if error == OK:
			return json.data
	
	
	return {}

func load_state() -> void:
	var new_settings : Dictionary = try_settings_load("user://settings/settings.settings")
	if new_settings.size() == 0:
		new_settings = try_settings_load("user://settings/settings.settings1")
	
	for key in new_settings:
		change_setting(key,new_settings[key])

func save_state() -> void:
	DirAccess.make_dir_absolute("user://settings")
	
	var data : String = JSON.stringify(settings,"\t")
	
	var cfg_file : FileAccess = FileAccess.open("user://settings/settings.settings", FileAccess.WRITE)
	cfg_file.store_line(data)
	cfg_file.close()
	
	cfg_file = FileAccess.open("user://settings/settings.settings1", FileAccess.WRITE)
	cfg_file.store_line(data)
	cfg_file.close()


func _ready() -> void:
	
	setup_original_inputmap()
	reset_settings()
	load_state()
	
	for key in settings:
		on_setting_change.emit(key,settings[key])
	
	
