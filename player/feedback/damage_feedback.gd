extends CenterContainer
class_name DamageFeedback

@export var stats : Stats
var body : CharacterBody3D

@onready var marker : Node2D = $SubViewportContainer/SubViewport/marker
@onready var svp : SubViewport = $SubViewportContainer/SubViewport

@export var markers_life_time :  float = 1.0

var markers : Dictionary[Node2D,float]
var markers_pos : Dictionary[Node2D,Vector3]

func on_damage(damage:int) -> void:
	var mark : Node2D = marker.duplicate()
	svp.add_child(mark)
	markers[mark] = markers_life_time
	markers_pos[mark] = stats.last_damage_origen
	
	
	

func _ready() -> void:
	body = stats.get_parent()
	stats.damaged.connect(on_damage)
	marker.get_parent().remove_child(marker)

func _process(delta: float) -> void:
	for m : Node2D in markers:
		markers[m] -= delta
		if markers[m] <= 0.0:
			markers.erase(m)
			markers_pos.erase(m)
			m.queue_free()
			continue
			
		
		var target_world : Vector3 = body.global_position.direction_to(markers_pos[m])
		var target_pos : Vector2 = Vector2.ZERO
		target_pos.x = -body.basis.z.dot(target_world) * 100
		target_pos.y = body.basis.x.dot(target_world) * 100
		target_pos+=Vector2(150.0,150.0)
		m.look_at(target_pos)
		
