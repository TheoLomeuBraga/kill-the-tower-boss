extends Control
class_name Hint


var time_left : float = -1.0

var text:String : 
	set(value):
		text = value
		if not $Panel/RichTextLabel:
			return
		$Panel/RichTextLabel.text = value
		

var hiden : bool = true

func notfy(_text:String,time_to_hide:float=604800.0,color:Color=Color.WHITE) -> void:
	text = _text
	hiden=false
	time_left = time_to_hide
	$Panel.get("theme_override_styles/panel").border_color = color

func hide_notification() -> void:
	time_left = 0.0
	

func _ready() -> void:
	$Panel.offset_transform_position_ratio.y = -2

func _process(delta: float) -> void:
	
	time_left -= delta
	if time_left > 0.0:
		$Panel.offset_transform_position_ratio.y = move_toward($Panel.offset_transform_position_ratio.y,0.0,delta*5)
	else:
		$Panel.offset_transform_position_ratio.y = move_toward($Panel.offset_transform_position_ratio.y,-2.0,delta*5)
	
