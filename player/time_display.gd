extends Label


var time : float = 0.0

func _process(delta: float) -> void:
	time+= delta
	text = str(int(time))
