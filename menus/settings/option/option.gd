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

func disable_visibilitys() -> void:
	$HBoxContainer/Button.visible = false
	$HBoxContainer/Label.visible = false
	$HBoxContainer/slider_info.visible = false
	$HBoxContainer/Control.visible = false
	$HBoxContainer/Control/CheckBox.visible = false
	$HBoxContainer/Control/OptionButton.visible = false
	$HBoxContainer/Control/HSlider.visible = false

func setup_as_button(name:String,callable:Callable) -> void:
	disable_visibilitys()
	$HBoxContainer/Button.visible = true
	$HBoxContainer/Button.text = name
	$HBoxContainer/Button.pressed.connect(callable)

func setup_as_check_box(name:String,setting_name:String,base_value:bool) -> void:
	disable_visibilitys()
	$HBoxContainer/Label.visible = true
	$HBoxContainer/Label.text = name
	
	$HBoxContainer/Control.visible = true
	$HBoxContainer/Control/CheckBox.visible = true
	$HBoxContainer/Control/CheckBox/CheckBox.button_pressed = base_value
	$HBoxContainer/Control/CheckBox/CheckBox.toggled.connect(change_bool.bind(setting_name))

func setup_as_option(name:String,setting_name:String,base_value:int,options:Array[String]) -> void:
	disable_visibilitys()
	$HBoxContainer/Label.visible = true
	$HBoxContainer/Label.text = name
	
	$HBoxContainer/Control.visible = true
	$HBoxContainer/Control/OptionButton.visible = true
	
	for s:String in options:
		$HBoxContainer/Control/OptionButton.add_item(s)
	
	$HBoxContainer/Control/OptionButton.selected = base_value
	
	$HBoxContainer/Control/OptionButton.item_selected.connect(change_int.bind(setting_name))

var minimun_slider_chars : int = 0
func setup_as_slider(name:String,setting_name:String,base_value:float,min:float,max:float,step:float,minimun_chars:int) -> void:
	disable_visibilitys()
	$HBoxContainer/Label.visible = true
	$HBoxContainer/Label.text = name
	
	$HBoxContainer/slider_info.visible = true
	$HBoxContainer/slider_info.text = str(base_value)
	
	$HBoxContainer/Control.visible = true
	$HBoxContainer/Control/HSlider.visible = true
	$HBoxContainer/Control/HSlider.min_value = min
	$HBoxContainer/Control/HSlider.max_value = max
	$HBoxContainer/Control/HSlider.step = step
	$HBoxContainer/Control/HSlider.value = base_value
	
	minimun_slider_chars = minimun_chars
	
	$HBoxContainer/Control/HSlider.value_changed.connect(change_float.bind(setting_name))

func _process(delta: float) -> void:
	if $HBoxContainer/slider_info.visible:
		$HBoxContainer/slider_info.text = str($HBoxContainer/Control/HSlider.value)
		
		while $HBoxContainer/slider_info.text.length() < minimun_slider_chars:
			$HBoxContainer/slider_info.text = "0"+$HBoxContainer/slider_info.text
		
		if $HBoxContainer/Control/HSlider.step == floor($HBoxContainer/Control/HSlider.step):
			$HBoxContainer/slider_info.text = $HBoxContainer/slider_info.text.split(".")[0]
