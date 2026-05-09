extends Timer
class_name DeathTimer

func _ready() -> void:
	timeout.connect(get_parent().queue_free)
