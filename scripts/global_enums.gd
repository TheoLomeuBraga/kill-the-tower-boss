extends Node
class_name GlobalEnums

enum Faction {FRIENDLY,ENEMY,NONE}

enum AmmonType {NONE,PISTOL,RIFLE,SHOTGUN,ENERGY,EXPLOSIVE}
const wepons_icons : Dictionary[GlobalEnums.AmmonType,String] = {
	GlobalEnums.AmmonType.NONE: "res://icons/none.png",
	GlobalEnums.AmmonType.PISTOL: "res://icons/bullet.png",
	GlobalEnums.AmmonType.RIFLE: "res://icons/rifle.png",
	GlobalEnums.AmmonType.SHOTGUN: "res://icons/shell.png",
	GlobalEnums.AmmonType.ENERGY: "res://icons/energy.png",
	GlobalEnums.AmmonType.EXPLOSIVE: "res://icons/explosive.png",
}

enum DamageTypes {NORMAL,EXPLOSIVE}
