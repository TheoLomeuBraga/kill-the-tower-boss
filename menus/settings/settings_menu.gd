extends Control
class_name SettingsMenu

@export var title : String

@onready var options_container : Node = $VBoxContainer/Control/PanelContainer/ScrollContainer/VBoxContainer
@onready var close_button : Button = $VBoxContainer/HBoxContainer/close
@onready var reset_button : Button = $VBoxContainer/HBoxContainer/reset

var options : Array[SettingOption]
func create_option() -> SettingOption:
	var ret : SettingOption = load("res://menus/settings/option/option.tscn").instantiate()
	options_container.add_child(ret)
	options.push_back(ret)
	return ret

enum SettingsTypes {MENU,KEYBOARD,CONTROLLER,VIDEO}
@export var type : SettingsTypes

func set_close_func(f:Callable)->void:
	focus_exited.get_connections()
	
	for c:Dictionary in close_button.pressed.get_connections():
		close_button.pressed.disconnect(c["callable"])
	
	close_button.pressed.connect(f)

func set_reset_func(f:Callable)->void:
	focus_exited.get_connections()
	
	for c:Dictionary in reset_button.pressed.get_connections():
		reset_button.pressed.disconnect(c["callable"])
	
	reset_button.pressed.connect(f)

signal on_close()

func change_type(new_type : SettingsTypes) -> void:
	type = new_type
	for o:SettingOption in options:
		o.queue_free()
	options = []
	
	$VBoxContainer/HBoxContainer/reset.visible = type != SettingsTypes.MENU
	
	var option : SettingOption
	match type:
		SettingsTypes.MENU:
			
			option = create_option()
			option.setup_as_button("keyboard",change_type.bind(SettingsTypes.KEYBOARD))
			
			option = create_option()
			option.setup_as_button("conreoller",change_type.bind(SettingsTypes.CONTROLLER))
			
			option = create_option()
			option.setup_as_button("video",change_type.bind(SettingsTypes.VIDEO))
			
			set_close_func(on_close.emit)
			
		SettingsTypes.KEYBOARD:
			
			option = create_option()
			option.setup_as_slider("sensitivity mouse","keyboard_sensitivity_mouse",6,0,18,0.1,3)
			
			set_close_func(change_type.bind(SettingsTypes.MENU))
			set_reset_func(Settings.reset_settings.bind("keyboard"))
			
		SettingsTypes.CONTROLLER:
			
			option = create_option()
			option.setup_as_slider("sensitivity controller","controller_sensitivity_controller",6,0,18,0.1,3)
			
			set_close_func(change_type.bind(SettingsTypes.MENU))
			set_reset_func(Settings.reset_settings.bind("controller"))
			
		SettingsTypes.VIDEO:
			
			option = create_option()
			option.setup_as_slider("fov","video_fov",90,1,160,1,3)
			
			set_close_func(change_type.bind(SettingsTypes.MENU))
			set_reset_func(Settings.reset_settings.bind("video"))

func _ready() -> void:
	
	$VBoxContainer/Label.text = title
	
	
	change_type(SettingsTypes.MENU)
	
	
