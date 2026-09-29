extends Node

@export var explosion_info : ExplosionInfo
@onready var body : CharacterBody3D = $".."

func explode() -> void:
	var eb : ExplosionBehavior = ExplosionBehavior.new()
	eb.data = explosion_info
	get_parent().get_parent().add_child(eb)
	eb.global_position = get_parent().global_position
	get_parent().queue_free()

func _ready() -> void:
	$"../Stats".dead.connect(explode)

func _physics_process(delta: float) -> void:
	if not body.is_on_floor():
		body.velocity.y -= delta*9.8
	body.move_and_slide()
