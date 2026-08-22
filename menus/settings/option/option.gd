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

func setup_as_check_box(name:String,setting_name:String,base_value:bool) -> void:
	disable_visibilitys()
	$Label.visible = true
	$Label.text = name
	
	$Control.visible = true
	$Control/CheckBox.visible = true
	$Control/CheckBox/CheckBox.button_pressed = base_value
	$Control/CheckBox/CheckBox.toggled.connect(change_bool.bind(setting_name))

func setup_as_option(name:String,setting_name:String,base_value:int,options:Array[String]) -> void:
	disable_visibilitys()
	$Label.visible = true
	$Label.text = name
	
	$Control.visible = true
	$Control/OptionButton.visible = true
	
	for s:String in options:
		$Control/OptionButton.add_item(s)
	
	$Control/OptionButton.selected = base_value
	
	$Control/OptionButton.item_selected.connect(change_int.bind(setting_name))

var minimun_slider_chars : int = 0
func setup_as_slider(name:String,setting_name:String,base_value:float,min:float,max:float,step:float,minimun_chars:int) -> void:
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
	
	minimun_slider_chars = minimun_chars
	
	$Control/HSlider.value_changed.connect(change_float.bind(setting_name))

func _process(delta: float) -> void:
	if $slider_info.visible:
		$slider_info.text = str($Control/HSlider.value)
		
		while $slider_info.text.length() < minimun_slider_chars:
			$slider_info.text = "0"+$slider_info.text
		
		if $Control/HSlider.step == floor($Control/HSlider.step):
			$slider_info.text = $slider_info.text.split(".")[0]
