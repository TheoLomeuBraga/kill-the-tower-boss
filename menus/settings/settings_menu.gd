extends Control
class_name SettingsMenu

@export var title : String

@onready var options_container : Node = $VBoxContainer/Control/PanelContainer/VBoxContainer

func create_option() -> SettingOption:
	var ret : SettingOption = load("res://menus/settings/option/option.tscn").instantiate()
	options_container.add_child(ret)
	return ret

func _ready() -> void:
	
	$VBoxContainer/Label.text = title
	
	var option : SettingOption
	
	option = create_option()
	option.setup_as_button("a",print.bind("a"))
	
	option = create_option()
	option.setup_as_check_box("box","a",false)
	
	option = create_option()
	option.setup_as_check_box("box","b",true)
	
	option = create_option()
	option.setup_as_option("option","c",0,["a","b","c"])
	
	option = create_option()
	option.setup_as_option("option","d",1,["a","b","c"])
	
	option = create_option()
	option.setup_as_slider("slide","e",50,0,100,0.1,4)
	
	option = create_option()
	option.setup_as_slider("slide","f",100,0,100,1,3)
