extends Node
class_name GunControl

@export var body : CharacterBody3D
@export var player_movement : PlayerMovement
@export var player_model : PlayerModel
@export var camera : Camera3D

@export var inventory : Array[GunInfo]
var current_wepon_id : int = -1
var current_wepon : GunInfo

@export var target_raycast : RayCast3D

@export var ammon_display : Label

const max_ammon : Dictionary[GlobalEnums.AmmonType,int] = {
	GlobalEnums.AmmonType.PISTOL: 100,
	GlobalEnums.AmmonType.RIFLE: 20,
	GlobalEnums.AmmonType.SHOTGUN: 50,
	GlobalEnums.AmmonType.ENERGY: 200,
	GlobalEnums.AmmonType.EXPLOSIVE: 5,
}

var ammon_inventory : Dictionary[GlobalEnums.AmmonType,int] = {
	GlobalEnums.AmmonType.ANY: 0,
	GlobalEnums.AmmonType.PISTOL: 100,
	GlobalEnums.AmmonType.RIFLE: 20,
	GlobalEnums.AmmonType.SHOTGUN: 50,
	GlobalEnums.AmmonType.ENERGY: 200,
	GlobalEnums.AmmonType.EXPLOSIVE: 5,
}

var ammon_on_mag : Dictionary[GunInfo,int]
func set_ammon_on_mag(gun_info : GunInfo,amount:int) -> void:
	ammon_on_mag[gun_info] = amount

func get_ammon_on_mag(gun_info : GunInfo) -> int:
	if not ammon_on_mag.has(gun_info):
		set_ammon_on_mag(gun_info,gun_info.ammon_capacity)
	return ammon_on_mag[gun_info]

var rng : RandomNumberGenerator = RandomNumberGenerator.new()

var time_last_shot : float = 0.0

var is_reloading : bool = false
var is_reloading_timer : Timer
func set_gun(no : int) -> void:
	
	if not no >= 0 or not no < inventory.size() or no == current_wepon_id:
		return
	
	is_reloading = false
	is_reloading_timer.stop()
	
	current_wepon_id = min(no,inventory.size() -1)
	current_wepon = inventory[current_wepon_id]
	
	player_model.visible = false
	
	await get_tree().process_frame
	
	player_model.visible = true
	
	player_model.set_gun(current_wepon.name)
	
	time_last_shot = 0.0
	
	

func _ready() -> void:
	
	is_reloading_timer = Timer.new()
	add_child(is_reloading_timer)
	is_reloading_timer.timeout.connect(reload_ammon)
	is_reloading_timer.one_shot = true
	
	set_gun(0)

func shot() -> void:
	
	if inventory[current_wepon_id].spawn_effect != null:
		var particle : Node = inventory[current_wepon_id].spawn_effect.instantiate()
		player_model.gun.muzle.add_child(particle)
	
	for i : int in inventory[current_wepon_id].bullets_per_shot:
		player_model.gun.shot = true
		if inventory[current_wepon_id].special_type == "grapple":
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
			
			var spread : float = inventory[current_wepon_id].spread
			var vec_spread : Vector3 = Vector3(rng.randf_range(-1.0,1.0),rng.randf_range(-1.0,1.0),0.0)
			if abs(vec_spread.x) + abs(vec_spread.y) > 1.0:
				vec_spread = vec_spread.normalized()
			vec_spread /= 1.0
			
			projectile.rotation += vec_spread * spread
			
			projectile.data = inventory[current_wepon_id].projectile_info
			projectile.start()

var camera_rots_last_frame : Vector3

func sway_gun(delta:float)->void:
	var rot_change : Vector3 = Vector3(camera.rotation.x,body.rotation.y,0.0) - camera_rots_last_frame
	rot_change *= 2.0
	rot_change.clamp(Vector3.ONE,-Vector3.ONE)
	
	player_model.gun_animator_rotation.x = rotate_toward(player_model.gun_animator_rotation.x,-rot_change.x,delta)
	player_model.gun_animator_rotation.y = rotate_toward(player_model.gun_animator_rotation.y,rot_change.y,delta)
	
	camera_rots_last_frame = Vector3(camera.rotation.x,body.rotation.y,0.0)


func reload_ammon() -> void:
	var ammon_missing : int = current_wepon.ammon_capacity - get_ammon_on_mag(current_wepon)
	
	is_reloading = false
	
	if ammon_inventory[current_wepon.ammon_type] >= current_wepon.ammon_capacity:
		ammon_inventory[current_wepon.ammon_type] -= current_wepon.ammon_capacity - get_ammon_on_mag(current_wepon)
		set_ammon_on_mag(current_wepon,current_wepon.ammon_capacity)
	else:
		set_ammon_on_mag(current_wepon,get_ammon_on_mag(current_wepon) + ammon_inventory[current_wepon.ammon_type])
		ammon_inventory[current_wepon.ammon_type] = 0
	
	

func reload() -> void:
	
	var can_reload : bool = not is_reloading
	can_reload = can_reload and get_ammon_on_mag(current_wepon) < current_wepon.ammon_capacity
	can_reload = can_reload and ammon_inventory[current_wepon.ammon_type] > 0
	
	if not can_reload:
		return
	
	player_model.reload()
	is_reloading = true
	is_reloading_timer.start(current_wepon.reload_time)

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
	
	if current_wepon == null:
		return
	
	var input_shot : bool = false
	if current_wepon.is_automatic:
		input_shot = Input.is_action_pressed("shot")
	else:
		input_shot = Input.is_action_just_pressed("shot")
	
	time_last_shot -= delta
	
	var can_shot : bool = player_model.gun != null and time_last_shot < 0.0 and not is_reloading
	var has_ammon : bool = get_ammon_on_mag(current_wepon) >= current_wepon.ammon_consumption
	
	if input_shot and can_shot and has_ammon:
		time_last_shot = current_wepon.fire_rate
		if current_wepon.ammon_type != GlobalEnums.AmmonType.ANY:
			set_ammon_on_mag(current_wepon,get_ammon_on_mag(current_wepon)-current_wepon.ammon_consumption)
		shot()
	elif input_shot and can_shot and not has_ammon:
		reload()
	
	sway_gun(delta)
	
	
	
	
	if Input.is_action_just_pressed("reload"):
		reload()
		
	
	ammon_display.visible = current_wepon.ammon_type != GlobalEnums.AmmonType.ANY
	
	ammon_display.text = str(ammon_inventory[current_wepon.ammon_type]) + "/" + str(get_ammon_on_mag(current_wepon))
