@tool
extends Node3D
class_name Consumable



@export var health : int = 10 : 
	set(value):
		health = value
		update_model()

@export var ammon : int = 0

@export var type : GlobalEnums.AmmonType :
	set(value):
		type = value
		
		match type:
			GlobalEnums.AmmonType.PISTOL:
				ammon = 10
			GlobalEnums.AmmonType.RIFLE:
				ammon = 5
			GlobalEnums.AmmonType.SHOTGUN:
				ammon = 8
			GlobalEnums.AmmonType.ENERGY:
				ammon = 20
			GlobalEnums.AmmonType.EXPLOSIVE:
				ammon = 3
		
		update_model()



@onready var models : Array[Node3D] = [
	$pistol,
	$rifle,
	$shotgun,
	$energy,
	$explosive,
	$health,
]
func update_model() -> void:
	for n : Node3D in models:
		n.visible = false
	
	if health > 0 and type == GlobalEnums.AmmonType.NONE:
		$health.visible = true
		return
	
	match type:
		GlobalEnums.AmmonType.PISTOL:
			$pistol.visible = true
		GlobalEnums.AmmonType.RIFLE:
			$rifle.visible = true
		GlobalEnums.AmmonType.SHOTGUN:
			$shotgun.visible = true
		GlobalEnums.AmmonType.ENERGY:
			$energy.visible = true
		GlobalEnums.AmmonType.EXPLOSIVE:
			$explosive.visible = true

@onready var triger : Area3D = $Area3D

static var heal_audio : AudioStream = load("res://sfx/heal.wav")
static var ammon_audio : AudioStream = load("res://sfx/ammon.wav")

func self_destruct() -> void:
	
	sync_data["existence"] = false
	
	var audio : AudioStreamPlayer = AudioStreamPlayer.new()
	get_parent().add_child(audio)
	audio.finished.connect(audio.queue_free)
	
	
	if health > 0 and type == GlobalEnums.AmmonType.NONE:
		audio.volume_db = -10
		audio.stream = heal_audio
	else:
		audio.volume_db = 0
		audio.stream = ammon_audio
	
	audio.play()
	
	queue_free()

func interract_body(n:Node3D) -> void:
	if n is Player:
		var player : Player = n
		if health > 0 and type == GlobalEnums.AmmonType.NONE:
			
			if player.stats.health < player.stats.max_health:
				player.stats.heal(health)
				player.vignette.vignette_color = Color.GREEN
				self_destruct()
			
			return
		
		if player.gun_control.can_add_ammon(type):
			
			player.gun_control.add_ammon(type,ammon)
			player.vignette.vignette_color = Color.YELLOW
			
			self_destruct()
			

var sync_data : Dictionary
func _ready() -> void:
	update_model()
	triger.body_entered.connect(interract_body)
	
	await get_tree().process_frame
	
	sync_data["existence"] = true
	
	if not PersistenceManager.has(self):
		PersistenceManager.register(self,sync_data)
	else:
		sync_data = PersistenceManager.get_ref(self)
	
	if not sync_data["existence"]:
		queue_free()

func _process(delta: float) -> void:
	rotation.y += delta * 2.0
