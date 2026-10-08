extends Label

var time:float = 0.0
func _process(delta: float) -> void:
	time += delta
	var time_string : String = str(time)
	var str : PackedStringArray = time_string.split(".")
	text = str[0] + "." + str[1][0]
