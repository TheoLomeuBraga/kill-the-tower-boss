@tool
extends CharacterBody3D
class_name GenericEnemyModel

enum GunType {PISTOL,SMG,SHOTGUN,SNIPER}

@onready var pistol_nodes : Array[Node3D] = [$metarig/GeneralSkeleton/upper_arm_R/Cube_007,$metarig/GeneralSkeleton/hand_R/Cube_004]
@onready var smg_nodes : Array[Node3D] = [$metarig/GeneralSkeleton/upper_arm_R/Cube_008,$metarig/GeneralSkeleton/hand_R/Cube_003]
@onready var shotgun_nodes : Array[Node3D] = [$metarig/GeneralSkeleton/upper_arm_R/Cube_009,$metarig/GeneralSkeleton/hand_R/Cube_002]
@onready var sniper_nodes : Array[Node3D] = [$metarig/GeneralSkeleton/upper_arm_R/Cube_010,$metarig/GeneralSkeleton/hand_R/Cube_005]

@onready var guns_nodes : Dictionary[GunType,Array] = {
	GunType.PISTOL: pistol_nodes,
	GunType.SMG: smg_nodes,
	GunType.SHOTGUN: shotgun_nodes,
	GunType.SNIPER: sniper_nodes,
}

func set_handgun(on:bool)->void:
	if on:
		$ik_targets/hand_r.position = Vector3(0.1,-0.132,0.472)
		$ik_targets/pole_r.position = Vector3(0.0,-1.632,0.1)
		$metarig/GeneralSkeleton/arm_l.influence = 0.0
		$metarig/GeneralSkeleton/hand_l.influence = 0.0
	else:
		$ik_targets/hand_r.position = Vector3(0.1,-0.132,0.18)
		$ik_targets/pole_r.position = Vector3(0.0,-1.632,0.1)
		$metarig/GeneralSkeleton/arm_l.influence = 1.0
		$metarig/GeneralSkeleton/hand_l.influence = 1.0

@export var current_gun_type : GunType = GunType.PISTOL :
	set(value):
		
		current_gun_type = value
		
		if guns_nodes.size() == 0 :
			return
		
		for a : GunType in guns_nodes:
			for n : Node3D in guns_nodes[a]:
				n.visible = false
		
		for n : Node3D in guns_nodes[current_gun_type]:
			n.visible = true
		
		set_handgun(current_gun_type == GunType.PISTOL)

func _ready() -> void:
	current_gun_type = current_gun_type
