extends Node
class_name PlayerSettingsSync

@onready var camera : Camera3D = $"../Camera3D"
@onready var gun_camera : Camera3D = $"../HUD/SubViewportContainer/SubViewport/Camera3D"
@onready var player_movement : PlayerMovement = $"../PlayerMovement"

func on_settings_change(name:String,value:Variant) -> void:
	if name == "video_fov":
		camera.fov = value
	elif name == "video_gun_fov":
		gun_camera.fov = value
	elif name == "keyboard_sensitivity_mouse":
		player_movement.mouse_sensitivity = value / Settings.mouse_sensitivity_correction
	elif name == "controller_sensitivity_controller":
		player_movement.joystick_sensitivity = value

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	Settings.on_setting_change.connect(on_settings_change)
	
	for key in Settings.settings:
		on_settings_change(key,Settings.settings[key])
