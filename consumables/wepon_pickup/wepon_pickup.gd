@tool

extends ShapeCast3D
class_name WeponPickup

var model_display : Node3D
var model : Node3D

@export var upgrade_of : GunInfo

@export var weapon : GunInfo :
	set(value):
		weapon = value
		if model:
			model_display.remove_child(model)
			model.queue_free()
			model = null
		if weapon and weapon.model and model_display:
			model = weapon.model.instantiate()
			model_display.add_child(model)
			

@export var offset : Vector3 :
	set(value):
		offset = value
		if model:
			model.position = offset

func _ready() -> void:
	target_position = Vector3.ZERO
	model_display = Node3D.new()
	add_child(model_display) 
	weapon = weapon
	offset = offset
	model_display.scale *= 2.0

var time : float = 0.0
func _process(delta: float) -> void:
	time += delta
	model_display.position.y = sin(time * 2) / 4.0
	model_display.rotation.y += delta * 2.0

static var ammon_audio : AudioStream = load("res://sfx/ammon.wav")

func _physics_process(delta: float) -> void:
	if not Engine.is_editor_hint():
		for i : int in get_collision_count():
			if get_collider(i) is Player:
				
				var p : Player = get_collider(i)
				
				if upgrade_of:
					p.gun_control.upgrade_gun(upgrade_of,weapon)
				else:
					p.gun_control.add_gun(weapon)
				
				p.gun_control.ammon_inventory[weapon.ammon_type] += weapon.ammon_capacity
				
				var audio : AudioStreamPlayer = AudioStreamPlayer.new()
				get_parent().add_child(audio)
				audio.finished.connect(audio.queue_free)
				audio.stream = ammon_audio
				audio.pitch_scale = 0.5
				audio.play()
				
				queue_free()
				break
