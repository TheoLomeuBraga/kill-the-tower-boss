extends Node
class_name GunControl

@export var body : CharacterBody3D
@export var player_movement : PlayerMovement
@export var player_model : PlayerModel
@export var camera : Camera3D

@export var inventory : Array[GunInfo]
@export var current_wepon : int = 0

@export var target_raycast : RayCast3D

var rng : RandomNumberGenerator = RandomNumberGenerator.new()

var time_last_shot : float = 0.0

func set_gun(no : int) -> void:
	if current_wepon == min(no,inventory.size() -1):
		return
	current_wepon = min(no,inventory.size() -1)
	player_model.set_gun(inventory[current_wepon].name)
	time_last_shot = 0.0

func shot() -> void:
	for i : int in inventory[current_wepon].bullets_per_shot:
		player_model.gun.shot = true
		if inventory[current_wepon].special_type == "grapple":
			player_movement.launch_grapple()
		else:
			var projectile : ProjectBehavior = ProjectBehavior.new()
			add_child(projectile)
			#projectile.global_position = player_model.gun.muzle.global_position
			projectile.global_position = camera.global_position
			projectile.muzle_position = player_model.gun.muzle.global_position
			if target_raycast.is_colliding():
				projectile.look_at(target_raycast.get_collision_point())
			else:
				projectile.global_basis = player_model.gun.muzle.global_basis
			
			var spread : float = inventory[current_wepon].spread
			var vec_spread : Vector3 = Vector3(rng.randf_range(-1.0,1.0),rng.randf_range(-1.0,1.0),0.0)
			if abs(vec_spread.x) + abs(vec_spread.y) > 1.0:
				vec_spread = vec_spread.normalized()
			vec_spread /= 1.0
			
			projectile.rotation += vec_spread * spread
			
			projectile.data = inventory[current_wepon].projectile_info
			projectile.start()

var camera_rots_last_frame : Vector3

func sway_gun(delta:float)->void:
	var rot_change : Vector3 = Vector3(camera.rotation.x,body.rotation.y,0.0) - camera_rots_last_frame
	rot_change *= 2.0
	rot_change.clamp(Vector3.ONE,-Vector3.ONE)
	
	player_model.gun_animator_rotation.x = rotate_toward(player_model.gun_animator_rotation.x,-rot_change.x,delta)
	player_model.gun_animator_rotation.y = rotate_toward(player_model.gun_animator_rotation.y,rot_change.y,delta)
	
	camera_rots_last_frame = Vector3(camera.rotation.x,body.rotation.y,0.0)



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
	
	var try_shot : bool = false
	if inventory[current_wepon].is_automatic:
		try_shot = Input.is_action_pressed("shot")
	else:
		try_shot = Input.is_action_just_pressed("shot")
	
	time_last_shot -= delta
	if try_shot and player_model.gun != null and time_last_shot < 0.0:
		time_last_shot = inventory[current_wepon].fire_rate
		shot()
	
	sway_gun(delta)
	
