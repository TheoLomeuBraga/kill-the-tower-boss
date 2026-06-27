extends Node
class_name Stats

const enemy_hit_particle : PackedScene = preload("res://particles/hit_particle/hit_particle.tscn")

signal healed(int)
signal damaged(int)
signal dead()

@export var faction : GlobalEnums.Faction = GlobalEnums.Faction.ENEMY

@export var max_health : int = 100
@export var health : int = 100

@export var multplyer_areas : Dictionary[CollisionShape3D,float]
@export var damage_type_multplyer : Dictionary[GlobalEnums.DamageTypes,float]

func calculate_damage(damage:int,area:CollisionShape3D=null,damage_type:GlobalEnums.DamageTypes=GlobalEnums.DamageTypes.NORMAL) -> int:
	
	var ret : int = damage
	
	if multplyer_areas.has(area):
		ret = int(float(ret) * multplyer_areas[area])
	
	if damage_type_multplyer.has(damage_type):
		ret = int(float(ret) * damage_type_multplyer[damage_type])
	
	return ret

static func get_stats_from_node(node : Node) -> Stats:
	
	for n : Node in node.get_children():
		if n is Stats:
			return n
	
	return null

func damage(amount:int,area:CollisionShape3D=null,damage_type:GlobalEnums.DamageTypes=GlobalEnums.DamageTypes.NORMAL) -> void:
	var damage : int = calculate_damage(amount,area,damage_type)
	if (health - damage) <= 0:
		health = 0
		dead.emit()
		return
	
	health -= damage
	damaged.emit(damage)
	

func heal(amount:int) -> void:
	health += amount
	healed.emit(amount)
