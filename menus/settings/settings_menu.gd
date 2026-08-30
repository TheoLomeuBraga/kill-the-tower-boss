extends Control
class_name SettingsMenu

@onready var title : Label = $VBoxContainer/Label

@onready var options_container : Node = $VBoxContainer/Control/Panel/ScrollContainer/VBoxContainer
@onready var close_button : Button = $VBoxContainer/HBoxContainer/close
@onready var reset_button : Button = $VBoxContainer/HBoxContainer/reset

var options : Array[SettingOption]
func create_option() -> SettingOption:
	var ret : SettingOption = load("res://menus/settings/option/option.tscn").instantiate()
	options_container.add_child(ret)
	options.push_back(ret)
	return ret

func focus() -> void:
	if options.size() > 0:
		options[0].focus()

enum SettingsTypes {MENU,KEYBOARD,CONTROLLER,VIDEO,AUDIO,KEYBOARD_BINDS,CONTROLLER_BINDS}
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
	if SettingsManager.is_curently_rebinding:
		return
	type = new_type
	for o:SettingOption in options:
		o.queue_free()
	options = []
	
	$VBoxContainer/HBoxContainer/reset.visible = type != SettingsTypes.MENU
	
	var option : SettingOption
	match type:
		SettingsTypes.MENU:
			
			title.text = "settings"
			
			option = create_option()
			option.setup_as_button("mouse & keyboard",change_type.bind(SettingsTypes.KEYBOARD))
			option.focus()
			
			option = create_option()
			option.setup_as_button("conreoller",change_type.bind(SettingsTypes.CONTROLLER))
			
			option = create_option()
			option.setup_as_button("video",change_type.bind(SettingsTypes.VIDEO))
			
			option = create_option()
			option.setup_as_button("audio",change_type.bind(SettingsTypes.AUDIO))
			
			set_close_func(on_close.emit)
			
		SettingsTypes.KEYBOARD:
			
			title.text = "mouse & keyboard"
			
			option = create_option()
			option.setup_as_slider("sensitivity mouse","keyboard_sensitivity_mouse",6,0,18,0.1)
			option.focus()
			
			option = create_option()
			option.setup_as_button("input map",change_type.bind(SettingsTypes.KEYBOARD_BINDS))
			
			set_close_func(change_type.bind(SettingsTypes.MENU))
			set_reset_func(SettingsManager.reset_settings.bind("keyboard"))
			
		SettingsTypes.CONTROLLER:
			
			title.text = "controller"
			
			option = create_option()
			option.setup_as_slider("sensitivity controller","controller_sensitivity_controller",6,0,18,0.1)
			option.focus()
			
			option = create_option()
			option.setup_as_slider("deadzone left","controller_deadzone_left",6,0,1,0.1)
			
			option = create_option()
			option.setup_as_slider("deadzone right","controller_deadzone_right",6,0,1,0.1)
			
			
			
			option = create_option()
			option.setup_as_button("input map",change_type.bind(SettingsTypes.CONTROLLER_BINDS))
			
			set_close_func(change_type.bind(SettingsTypes.MENU))
			set_reset_func(SettingsManager.reset_settings.bind("controller"))
			
		SettingsTypes.VIDEO:
			
			title.text = "video"
			
			option = create_option()
			option.setup_as_slider("fov","video_fov",90,1,160,1)
			option.focus()
			
			option = create_option()
			option.setup_as_check_box("full screen","video_full_screen",false)
			
			set_close_func(change_type.bind(SettingsTypes.MENU))
			set_reset_func(SettingsManager.reset_settings.bind("video"))
			
			
		SettingsTypes.AUDIO:
			
			title.text = "audio"
			
			option = create_option()
			option.setup_as_slider("Volume","audio_volume",80,0,100,1)
			option.focus()
			
			option = create_option()
			option.setup_as_slider("SFX","audio_volume_sfx",100,0,100,1)
			
			option = create_option()
			option.setup_as_slider("Music","audio_volume_music",100,0,100,1)
			
			#option = create_option()
			#option.setup_as_slider("Dialogue","audio_volume_dialogue",100,0,100,1,3)
			
			set_close_func(change_type.bind(SettingsTypes.MENU))
			set_reset_func(SettingsManager.reset_settings.bind("audio"))
		
		SettingsTypes.KEYBOARD_BINDS:
			
			
			
			var is_first : bool = true
			for key:String in InputMap.get_actions():
				
				if key.begins_with("ui_"):
					continue
				
				option = create_option()
				option.setup_as_key_rebind(key,key,GlobalEnums.InputDeviceTypes.KEYBOARD_MOUSE)
				
				if is_first:
					option.focus()
					is_first = false
			
			
			set_close_func(change_type.bind(SettingsTypes.KEYBOARD))
			set_reset_func(SettingsManager.reset_settings.bind("keyboard_map"))
			
		SettingsTypes.CONTROLLER_BINDS:
			
			var is_first : bool = true
			for key:String in InputMap.get_actions():
				
				if key.begins_with("ui_"):
					continue
				
				option = create_option()
				option.setup_as_key_rebind(key,key,GlobalEnums.InputDeviceTypes.CONTROLLER)
				
				if is_first:
					option.focus()
					is_first = false
			
			
			set_close_func(change_type.bind(SettingsTypes.CONTROLLER))
			set_reset_func(SettingsManager.reset_settings.bind("controller_map"))
			

func _ready() -> void:
	
	change_type(SettingsTypes.MENU)
	
	on_close.connect(SettingsManager.save_state)

func _process(delta: float) -> void:
	
	if visible and Input.is_action_just_pressed("ui_cancel"):
		close_button.pressed.emit()
