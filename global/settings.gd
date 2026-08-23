extends Node

signal on_setting_change(String,Variant)

const mouse_sensitivity_correction : float = 600.0

const base_settings : Dictionary = {
	
	"keyboard_sensitivity_mouse": 6.0,
	
	"controller_sensitivity_controller": 6.0,
	
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

func load_state() -> void:
	pass

func save_state() -> void:
	pass

func _ready() -> void:
	
	reset_settings()
	
	load_state()
	
	for key in settings:
		on_setting_change.emit(key,settings[key])
	
	
