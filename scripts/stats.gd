extends Node
class_name Stats

signal healed(int)
signal damaged(int)
signal dead()

@export var faction : GlobalEnums.Faction = GlobalEnums.Faction.ENEMY

@export var max_health : int = 100
@export var health : int = 100 : 
	set(value):
		
		if value == health:
			return
		
		var new_health : int = clamp(value,0,max_health)
		
		if value < health:
			damaged.emit(abs(value - health))
		elif value > health:
			healed.emit(abs(value - health))
		if value == 0:
			dead.emit()
		
		health = new_health
		
		

@export var multplyer_areas : Dictionary[CollisionShape3D,float]

func calculate_damage_on(damage:int,area:CollisionShape3D) -> float:
	
	if multplyer_areas.has(area):
		return int(float(damage) * multplyer_areas[area])
	
	return damage
