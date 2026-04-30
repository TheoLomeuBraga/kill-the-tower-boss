extends Node
class_name GunControl

@export var body : CharacterBody3D
@export var player_movement : PlayerMovement
@export var player_model : PlayerModel

@export var inventory : Array[GunInfo]
@export var current_wepon : int = 0

@export var target_raycast : RayCast3D

func set_gun(no : int) -> void:
	if current_wepon == min(no,inventory.size() -1):
		return
	current_wepon = min(no,inventory.size() -1)
	player_model.set_gun(inventory[current_wepon].name)

func shot() -> void:
	player_model.gun.shot = true
	if inventory[current_wepon].special_type == "grapple":
		player_movement.launch_grapple()
	else:
		var projectile : ProjectBehavior = ProjectBehavior.new()
		add_child(projectile)
		projectile.global_position = player_model.gun.muzle.global_position
		if target_raycast.is_colliding():
			projectile.look_at(target_raycast.get_collision_point())
		else:
			projectile.global_basis = player_model.gun.muzle.global_basis
		
		projectile.data = inventory[current_wepon].projectile_info
		projectile.start()

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("wepon_1"):
		set_gun(0)
	elif Input.is_action_just_pressed("wepon_2"):
		set_gun(1)
	elif Input.is_action_just_pressed("wepon_3"):
		set_gun(2)
	elif Input.is_action_just_pressed("wepon_4"):
		set_gun(3)
	elif Input.is_action_just_pressed("wepon_5"):
		set_gun(4)
	
	if Input.is_action_just_pressed("shot") and player_model.gun != null:
		shot()
