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
				ammon = 4
			GlobalEnums.AmmonType.ENERGY:
				ammon = 25
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

func self_destruct() -> void:
	queue_free()

func interract_body(n:Node3D) -> void:
	if n is Player:
		var player : Player = n
		if health > 0 and type == GlobalEnums.AmmonType.NONE:
			
			if player.stats.health < player.stats.max_health:
				player.stats.health += health
				self_destruct()
			
			return
		
		if player.gun_control.can_add_ammon(type):
			
			player.gun_control.add_ammon(type,ammon)
			
			self_destruct()
			return
		
			match type:
				GlobalEnums.AmmonType.PISTOL:
					pass
				GlobalEnums.AmmonType.RIFLE:
					pass
				GlobalEnums.AmmonType.SHOTGUN:
					pass
				GlobalEnums.AmmonType.ENERGY:
					pass
				GlobalEnums.AmmonType.EXPLOSIVE:
					pass

func _ready() -> void:
	update_model()
	triger.body_entered.connect(interract_body)

func _process(delta: float) -> void:
	rotation.y += delta * 2.0
