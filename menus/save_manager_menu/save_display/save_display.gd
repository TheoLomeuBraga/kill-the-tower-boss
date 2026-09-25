extends HBoxContainer
class_name SaveDisplay

signal on_load()
signal on_delete()

func _ready() -> void:
	$HBoxContainer/load.pressed.connect(on_load.emit)
	$HBoxContainer/delete.pressed.connect(on_delete.emit)

func set_display(save_name:String,unit_last_used_time:float,map_name:String="",image:Texture=load("res://icon.svg")) -> void:
	$VBoxContainer/name.text = save_name
	var dictionary : Dictionary = Time.get_datetime_dict_from_system(unit_last_used_time)
	$VBoxContainer/time.text = "%s-%s-%s-%s:%s" % [dictionary["day"],dictionary["month"],dictionary["year"],dictionary["hour"],dictionary["minute"]]
	$VBoxContainer/map_name.text = map_name

func focus() -> void:
	$HBoxContainer/load.grab_focus()
