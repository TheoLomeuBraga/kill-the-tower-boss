extends Control
class_name PlayerHud

@onready var stats : Stats = $"../Stats"
@onready var gun_control : GunControl = $"../Camera3D/GunControl"

@onready var health_display : Label = $health_display
@onready var ammon_display : Label = $ammon_display

func _process(delta: float) -> void:
	ammon_display.visible = gun_control.current_gun.ammon_type != GlobalEnums.AmmonType.NONE
	if gun_control.current_gun.ammon_capacity > 0:
		ammon_display.text = str(gun_control.ammon_inventory[gun_control.current_gun.ammon_type]) + "/" + str(gun_control.get_ammon_on_mag(gun_control.current_gun))
	else:
		ammon_display.text = str(gun_control.ammon_inventory[gun_control.current_gun.ammon_type])
	
	health_display.text = str(stats.health)
