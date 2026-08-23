extends Control
class_name SettingOption

var setting_target : String
var value : Variant

func change_bool(value:bool,name:String) -> void:
	Settings.change_setting(name,value)

func change_int(value:int,name:String) -> void:
	Settings.change_setting(name,value)

func change_float(value:float,name:String) -> void:
	Settings.change_setting(name,value)


enum OptionTypes {NONE,BUTTON,CHECK_BOX,ENUM,SLIDER}
var option_type : OptionTypes = OptionTypes.NONE
func on_change_setting(name:String,new_value:Variant) -> void:
	if setting_target == name:
		value = new_value
		
		match option_type:
			OptionTypes.CHECK_BOX:
				$Control/CheckBox/CheckBox.button_pressed = value
			OptionTypes.ENUM:
				$Control/OptionButton.selected = value
			OptionTypes.SLIDER:
				$Control/HSlider.value = value



func focus() -> void:
	
	match option_type:
		OptionTypes.BUTTON:
			$Button.grab_focus()
		OptionTypes.CHECK_BOX:
			$Control/CheckBox/CheckBox.grab_focus()
		OptionTypes.ENUM:
			$Control/OptionButton.grab_focus()
		OptionTypes.SLIDER:
			$Control/HSlider.grab_focus()

func update_visual_option() -> void:
	for key:String in Settings.settings:
		if setting_target == key:
			on_change_setting(key,Settings.settings[key])

func _ready() -> void:
	Settings.on_setting_change.connect(on_change_setting)

func disable_visibilitys() -> void:
	$Button.visible = false
	$Label.visible = false
	$slider_info.visible = false
	$Control.visible = false
	$Control/CheckBox.visible = false
	$Control/OptionButton.visible = false
	$Control/HSlider.visible = false

func setup_as_button(name:String,callable:Callable) -> void:
	disable_visibilitys()
	$Button.visible = true
	$Button.text = name
	$Button.pressed.connect(callable)
	
	setting_target = ""
	option_type = OptionTypes.BUTTON
	
	update_visual_option()

func setup_as_check_box(name:String,setting_name:String,base_value:bool) -> void:
	disable_visibilitys()
	$Label.visible = true
	$Label.text = name
	
	$Control.visible = true
	$Control/CheckBox.visible = true
	$Control/CheckBox/CheckBox.button_pressed = base_value
	$Control/CheckBox/CheckBox.toggled.connect(change_bool.bind(setting_name))
	
	setting_target = setting_name
	option_type = OptionTypes.CHECK_BOX
	
	update_visual_option()

func setup_as_enum(name:String,setting_name:String,base_value:int,options:Array[String]) -> void:
	disable_visibilitys()
	$Label.visible = true
	$Label.text = name
	
	$Control.visible = true
	$Control/OptionButton.visible = true
	
	for s:String in options:
		$Control/OptionButton.add_item(s)
	
	$Control/OptionButton.selected = base_value
	
	$Control/OptionButton.item_selected.connect(change_int.bind(setting_name))
	
	setting_target = setting_name
	option_type = OptionTypes.ENUM
	
	update_visual_option()

func setup_as_slider(name:String,setting_name:String,base_value:float,min:float,max:float,step:float) -> void:
	disable_visibilitys()
	$Label.visible = true
	$Label.text = name
	
	$slider_info.visible = true
	$slider_info.text = str(base_value)
	
	$Control.visible = true
	$Control/HSlider.visible = true
	$Control/HSlider.min_value = min
	$Control/HSlider.max_value = max
	$Control/HSlider.step = step
	$Control/HSlider.value = base_value
	
	$Control/HSlider.value_changed.connect(change_float.bind(setting_name))
	
	setting_target = setting_name
	option_type = OptionTypes.SLIDER
	
	update_visual_option()

func _process(delta: float) -> void:
	if $slider_info.visible:
		$slider_info.text = str($Control/HSlider.value)
		
