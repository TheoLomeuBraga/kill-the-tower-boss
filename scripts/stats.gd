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
		
		if new_health > health:
			damaged.emit(abs(new_health - health))
		elif new_health < health:
			healed.emit(abs(new_health - health))
		if new_health == 0:
			dead.emit()
		
		
		health = new_health
		
		
