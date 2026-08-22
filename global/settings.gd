extends Node

signal on_setting_change(String,Variant)

const mouse_sensitivity_correction : float = 600.0

var settings : Dictionary = {
	"volume": 80,
	"volume_sfx": 100,
	"volume_music": 100,
	"volume_dialogue": 100,
	
	"sensitivity_mouse": 6.0,
	"sensitivity_joystick": 6.0,
	"fov": 90,
}

var input_map : Dictionary[String,InputEvent]



func load_state() -> void:
	pass

func _ready() -> void:
	
	load_state()
	for key in settings:
		on_setting_change.emit(key,settings[key])
	
	

func save_state() -> void:
	pass

func change_setting(name:String,value:Variant) -> void:
	
	settings[name] = value
	on_setting_change.emit(name,value)
	
	
