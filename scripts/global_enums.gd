extends Node
class_name GlobalEnums

enum InputDeviceTypes {KEYBOARD_MOUSE,CONTROLLER}

enum AmmonType {NONE,PISTOL,RIFLE,SHOTGUN,ENERGY,EXPLOSIVE}
const wepons_icons : Dictionary[GlobalEnums.AmmonType,String] = {
	GlobalEnums.AmmonType.NONE: "res://icons/consumables/none.png",
	GlobalEnums.AmmonType.PISTOL: "res://icons/consumables/bullet.png",
	GlobalEnums.AmmonType.RIFLE: "res://icons/consumables/rifle.png",
	GlobalEnums.AmmonType.SHOTGUN: "res://icons/consumables/shell.png",
	GlobalEnums.AmmonType.ENERGY: "res://icons/consumables/energy.png",
	GlobalEnums.AmmonType.EXPLOSIVE: "res://icons/consumables/explosive.png",
}

enum Faction {FRIENDLY,ENEMY,NONE}
enum DamageTypes {NORMAL,EXPLOSIVE}
enum KeyCards {RED,YELLOW,BLUE}
