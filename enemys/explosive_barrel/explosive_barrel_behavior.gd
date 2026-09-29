extends Node

@export var explosion_info : ExplosionInfo

func explode() -> void:
	var eb : ExplosionBehavior = ExplosionBehavior.new()
	eb.data = explosion_info
	get_parent().get_parent().add_child(eb)
	eb.global_position = get_parent().global_position
	get_parent().queue_free()

func _ready() -> void:
	$"../Stats".dead.connect(explode)
