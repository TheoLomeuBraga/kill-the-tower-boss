extends Node
class_name GunControl

@export var body : CharacterBody3D
@export var player_movement : PlayerMovement
@export var player_model : PlayerModel
@export var camera : Camera3D

@export var inventory : Array[GunInfo]
var current_gun_id : int = -1
var current_gun : GunInfo

@export var target_raycast : RayCast3D
@export var ammon_display : Label

const max_ammon : Dictionary[GlobalEnums.AmmonType,int] = {
	GlobalEnums.AmmonType.PISTOL: 100,
	GlobalEnums.AmmonType.RIFLE: 20,
	GlobalEnums.AmmonType.SHOTGUN: 24,
	GlobalEnums.AmmonType.ENERGY: 200,
	GlobalEnums.AmmonType.EXPLOSIVE: 20,
}

var ammon_inventory : Dictionary[GlobalEnums.AmmonType,int] = {
	GlobalEnums.AmmonType.NONE: 0,
	GlobalEnums.AmmonType.PISTOL: 100,
	GlobalEnums.AmmonType.RIFLE: 20,
	GlobalEnums.AmmonType.SHOTGUN: 24,
	GlobalEnums.AmmonType.ENERGY: 200,
	GlobalEnums.AmmonType.EXPLOSIVE: 20,
}

func can_add_ammon(type:GlobalEnums.AmmonType) -> bool:
	return ammon_inventory[type] < max_ammon[type]

func add_ammon(type:GlobalEnums.AmmonType , amount:int) -> void:
	ammon_inventory[type] = min(ammon_inventory[type]+amount,max_ammon[type])

var ammon_on_mag : Dictionary[GunInfo,int]
func set_ammon_on_mag(gun_info : GunInfo,amount:int) -> void:
	ammon_on_mag[gun_info] = amount

func get_ammon_on_mag(gun_info : GunInfo) -> int:
	if not ammon_on_mag.has(gun_info):
		set_ammon_on_mag(gun_info,gun_info.ammon_capacity)
	return ammon_on_mag[gun_info]

var rng : RandomNumberGenerator = RandomNumberGenerator.new()

var time_last_shot : float = 0.0

var inventory_reload_time : Dictionary[GunInfo,float]
func process_inventory_reload_time(delta:float) -> void:
	for gi : GunInfo in inventory:
		if not inventory_reload_time.has(gi):
			inventory_reload_time[gi] = 0.0
		
		if current_gun != gi:
			inventory_reload_time[gi] += delta
		else:
			inventory_reload_time[gi] = 0.0
		

func get_inventory_reload_time(gun:GunInfo) -> float:
	if not inventory_reload_time.has(gun):
		inventory_reload_time[gun] = 0.0
	return inventory_reload_time[gun]

func set_inventory_reload_time(gun:GunInfo,value:float) -> void:
	if not inventory_reload_time.has(gun):
		inventory_reload_time[gun] = 0.0
	inventory_reload_time[gun] = value

func reload_ammon() -> void:
	
	is_reloading = false
	
	player_model.gun.abort_shot()
	
	if ammon_inventory[current_gun.ammon_type] >= current_gun.ammon_capacity:
		ammon_inventory[current_gun.ammon_type] -= current_gun.ammon_capacity - get_ammon_on_mag(current_gun)
		set_ammon_on_mag(current_gun,current_gun.ammon_capacity)
	else:
		set_ammon_on_mag(current_gun,get_ammon_on_mag(current_gun) + ammon_inventory[current_gun.ammon_type])
		ammon_inventory[current_gun.ammon_type] = 0

var is_reloading : bool = false
var is_reloading_timer : Timer
func set_gun(no : int) -> void:
	
	if not no >= 0 or not no < inventory.size() or no == current_gun_id:
		return
	
	is_reloading = false
	is_reloading_timer.stop()
	
	current_gun_id = min(no,inventory.size() -1)
	current_gun = inventory[current_gun_id]
	
	reload_audio_player.stop()
	reload_audio_player.stream = current_gun.reload_audio
	
	player_model.visible = false
	
	if get_inventory_reload_time(current_gun) >= current_gun.inventory_reload_time:
		reload_ammon()
	
	await get_tree().process_frame
	
	player_model.visible = true
	
	player_model.set_gun(current_gun.model)
	
	time_last_shot = 0.0
	
	
	

var reload_audio_player : AudioStreamPlayer

func _ready() -> void:
	
	reload_audio_player = AudioStreamPlayer.new()
	add_child(reload_audio_player)
	
	is_reloading_timer = Timer.new()
	add_child(is_reloading_timer)
	is_reloading_timer.timeout.connect(reload_ammon)
	is_reloading_timer.one_shot = true
	
	set_gun(0)

func shot() -> void:
	
	body.velocity += camera.global_basis.z * current_gun.knock_back
	
	if inventory[current_gun_id].spawn_effect != null:
		var particle : Node = inventory[current_gun_id].spawn_effect.instantiate()
		player_model.gun.get_muzle().add_child(particle)
	
	for i : int in inventory[current_gun_id].bullets_per_shot:
		
		if inventory[current_gun_id].special_type == GlobalEnums.WeponTime.GRAPPLE:
			player_movement.launch_grapple()
		else:
			var projectile : ProjectBehavior = ProjectBehavior.new()
			add_child(projectile)
			projectile.global_position = camera.global_position
			projectile.muzle_position = player_model.gun.get_muzle().global_position
			
			projectile.target_position = target_raycast.global_basis.z * -100.0
			
			if target_raycast.is_colliding():
				projectile.look_at(target_raycast.get_collision_point())
			else:
				projectile.global_basis = player_model.gun.get_muzle().global_basis
				projectile.look_at(camera.global_basis.z * -100.0)
			
			var spread : float = inventory[current_gun_id].spread
			var vec_spread : Vector3 = Vector3(rng.randf_range(-1.0,1.0),rng.randf_range(-1.0,1.0),0.0)
			if abs(vec_spread.x) + abs(vec_spread.y) > 1.0:
				vec_spread = vec_spread.normalized()
			vec_spread /= 1.0
			
			projectile.rotation += vec_spread * spread
			
			projectile.data = inventory[current_gun_id].projectile_info
			projectile.start()
		
	player_model.gun.shot = true


var camera_rots_last_frame : Vector3

func sway_gun(delta:float)->void:
	
	var rot_change : Vector3 = Vector3(camera.rotation.x,body.rotation.y,0.0) - camera_rots_last_frame
	rot_change *= 1.5
	
	player_model.rotation.z = rotate_toward(player_model.rotation.z,-rot_change.y,delta)
	player_model.rotation.x = rotate_toward(player_model.rotation.x,-rot_change.x,delta)
	
	
	camera_rots_last_frame = Vector3(camera.rotation.x,body.rotation.y,0.0)
	
	

func reload() -> void:
	
	if current_gun.ammon_capacity < 0:
		return
	
	var can_reload : bool = not is_reloading
	can_reload = can_reload and get_ammon_on_mag(current_gun) < current_gun.ammon_capacity
	can_reload = can_reload and ammon_inventory[current_gun.ammon_type] > 0
	
	
	
	if not can_reload:
		return
	
	
	reload_audio_player.play()
	player_model.reload()
	is_reloading = true
	is_reloading_timer.start(current_gun.reload_time)

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
	
	if Input.is_action_just_released("next_wepon"):
		set_gun(wrap(current_gun_id+1,0,inventory.size()))
	elif Input.is_action_just_released("previous_wepon"):
		set_gun(wrap(current_gun_id-1,0,inventory.size()))
	
	process_inventory_reload_time(delta)
	
	if current_gun == null or player_model == null or player_model.gun == null:
		return
	
	var input_shot : bool = false
	if current_gun.is_automatic:
		input_shot = Input.is_action_pressed("shot")
	else:
		input_shot = Input.is_action_just_pressed("shot")
	
	time_last_shot -= delta
	
	var can_shot : bool = player_model.gun != null and time_last_shot < 0.0 and not is_reloading
	var has_ammon : bool = false
	if current_gun.ammon_capacity > 0:
		has_ammon = get_ammon_on_mag(current_gun) >= current_gun.ammon_consumption
	else:
		has_ammon = ammon_inventory[current_gun.ammon_type] >= current_gun.ammon_consumption
	
	#if  not has_ammon or current_gun.is_automatic and Input.is_action_just_released("shot") or is_reloading:
	#	player_model.gun.shot = false
	
	if (current_gun.is_automatic and (not input_shot or not has_ammon)):
		player_model.gun.shot = false
	
	if input_shot and can_shot and has_ammon:
		time_last_shot = current_gun.fire_rate
		if current_gun.ammon_type != GlobalEnums.AmmonType.NONE:
			if current_gun.ammon_capacity > 0:
				set_ammon_on_mag(current_gun,get_ammon_on_mag(current_gun)-current_gun.ammon_consumption)
			else:
				ammon_inventory[current_gun.ammon_type] -= current_gun.ammon_consumption
			
		shot()
	
	
	
	
	
	
	if input_shot and can_shot and not has_ammon:
		reload()
	
	sway_gun(delta)
	
	if Input.is_action_just_pressed("reload") or Input.is_action_just_released("shot") and not has_ammon:
		reload()
		
	
	ammon_display.visible = current_gun.ammon_type != GlobalEnums.AmmonType.NONE
	if current_gun.ammon_capacity > 0:
		ammon_display.text = str(ammon_inventory[current_gun.ammon_type]) + "/" + str(get_ammon_on_mag(current_gun))
	else:
		ammon_display.text = str(ammon_inventory[current_gun.ammon_type])
	
	
	var input_dir : Vector3 = body.basis * Vector3(Input.get_axis("left","right"),0.0,Input.get_axis("foward","back")).normalized()
	player_model.gun_animations.walk = move_toward(player_model.gun_animations.walk , input_dir.length() , delta * 4.0)
	
	if get_ammon_on_mag(current_gun) > -1:
		player_model.gun.display_text = str(get_ammon_on_mag(current_gun))
	else:
		player_model.gun.display_text = str(ammon_inventory[current_gun.ammon_type])
	
