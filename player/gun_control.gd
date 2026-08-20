extends Node
class_name GunControl

@export var body : CharacterBody3D
@export var player_movement : PlayerMovement
@export var player_model : PlayerModel
@export var camera : Camera3D

@export var inventory_order : Array[GunInfo]
@export var inventory : Dictionary[GunInfo,bool]
var current_gun : GunInfo = null

@export var target_raycast : RayCast3D

@export var start_gun : int

const max_ammon : Dictionary[GlobalEnums.AmmonType,int] = {
	GlobalEnums.AmmonType.PISTOL: 100,
	GlobalEnums.AmmonType.RIFLE: 20,
	GlobalEnums.AmmonType.SHOTGUN: 24,
	GlobalEnums.AmmonType.ENERGY: 100,
	GlobalEnums.AmmonType.EXPLOSIVE: 12,
}

var ammon_inventory : Dictionary[GlobalEnums.AmmonType,int] = {
	GlobalEnums.AmmonType.NONE: 0,
	GlobalEnums.AmmonType.PISTOL: 0,
	GlobalEnums.AmmonType.RIFLE: 0,
	GlobalEnums.AmmonType.SHOTGUN: 0,
	GlobalEnums.AmmonType.ENERGY: 0,
	GlobalEnums.AmmonType.EXPLOSIVE: 0,
}

var ammon_on_mag : Dictionary[String,int]
func set_ammon_on_mag(gun_info : GunInfo,amount:int) -> void:
	ammon_on_mag[gun_info.name] = amount

func get_ammon_on_mag(gun_info : GunInfo) -> int:
	if not ammon_on_mag.has(gun_info.name):
		set_ammon_on_mag(gun_info,gun_info.ammon_capacity)
	return ammon_on_mag[gun_info.name]

var sync_data:Dictionary = {}

func sync_inventory() -> void:
	
	sync_data["ammon_inventory"] = ammon_inventory
	sync_data["inventory"] = inventory
	sync_data["ammon_on_mag"] = ammon_on_mag
	
	if not PersistenceManager.has(self):
		PersistenceManager.register(self,sync_data)
	else:
		sync_data = PersistenceManager.get_ref(self)
	
	ammon_inventory = sync_data["ammon_inventory"]
	inventory = sync_data["inventory"]
	ammon_on_mag = sync_data["ammon_on_mag"]

func can_add_ammon(type:GlobalEnums.AmmonType) -> bool:
	return ammon_inventory[type] < max_ammon[type]

func add_ammon(type:GlobalEnums.AmmonType , amount:int) -> void:
	ammon_inventory[type] = min(ammon_inventory[type]+amount,max_ammon[type])

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
		
		if gi != current_gun and inventory_reload_time[gi] >= gi.inventory_reload_time:
			reload_ammon(gi)
			inventory_reload_time[gi] = 0.0

func get_inventory_reload_time(gun:GunInfo) -> float:
	if not inventory_reload_time.has(gun):
		inventory_reload_time[gun] = 0.0
	return inventory_reload_time[gun]

func set_inventory_reload_time(gun:GunInfo,value:float) -> void:
	if not inventory_reload_time.has(gun):
		inventory_reload_time[gun] = 0.0
	inventory_reload_time[gun] = value

func reload_ammon(gun:GunInfo=current_gun) -> void:
	
	if gun == current_gun:
		is_reloading = false
		player_model.gun.abort_shot()
	
	if gun.ammon_type == GlobalEnums.AmmonType.NONE:
		set_ammon_on_mag(gun,gun.ammon_capacity)
		return
	
	if ammon_inventory[gun.ammon_type] >= gun.ammon_capacity - get_ammon_on_mag(gun):
		ammon_inventory[gun.ammon_type] -= gun.ammon_capacity - get_ammon_on_mag(gun)
		set_ammon_on_mag(gun,gun.ammon_capacity)
	else:
		set_ammon_on_mag(gun,get_ammon_on_mag(gun) + ammon_inventory[gun.ammon_type])
		ammon_inventory[gun.ammon_type] = 0

var is_reloading : bool = false
var is_reloading_timer : Timer
func set_gun(gun:GunInfo) -> void:
	
	if  not (gun and inventory.has(gun) and inventory[gun] and gun != current_gun):
		return
	
	is_reloading = false
	is_reloading_timer.stop()
	
	current_gun = gun
	
	
	reload_audio_player.stop()
	reload_audio_player.stream = current_gun.reload_audio
	
	player_model.visible = false
	
	await get_tree().process_frame
	
	player_model.visible = true
	
	player_model.set_gun(current_gun.model)
	
	time_last_shot = 0.0
	
	if player_model.gun.cross:
		player_model.gun.cross.visible = true
	

func add_gun(gun:GunInfo) -> void:
	if inventory.has(gun) and inventory[gun]:
		return
	inventory[gun] = true
	set_gun(gun)

func upgrade_gun(upgrade_of:GunInfo,gun:GunInfo) -> void:
	if inventory.has(upgrade_of):
		inventory.erase(upgrade_of)
		inventory[gun] = true
		
		for i:int in inventory_order.size():
			if inventory_order[i] == upgrade_of:
				inventory_order[i] = gun 
			
	else:
		add_gun(gun) 

var reload_audio_player : AudioStreamPlayer

var charge_shot_time : float = 0.0
var charge_audio_player : AudioStreamPlayer

func _ready() -> void:
	
	sync_inventory()
	
	for g:GunInfo in inventory_order:
		if not inventory.has(g):
			inventory[g] = false
	
	reload_audio_player = AudioStreamPlayer.new()
	add_child(reload_audio_player)
	reload_audio_player.bus = "SFX"
	
	charge_audio_player = AudioStreamPlayer.new()
	add_child(charge_audio_player)
	charge_audio_player.volume_db = -10.0
	charge_audio_player.bus = "SFX"
	
	is_reloading_timer = Timer.new()
	add_child(is_reloading_timer)
	is_reloading_timer.timeout.connect(reload_ammon)
	is_reloading_timer.one_shot = true
	
	set_gun(inventory_order[wrapf(start_gun,0,inventory_order.size()-1)])



func shot() -> void:
	
	var audio : AudioStreamPlayer = AudioStreamPlayer.new()
	audio.stream = current_gun.projectile_info.sound
	audio.bus = "SFX"
	audio.finished.connect(audio.queue_free)
	add_child(audio)
	audio.play()
	
	body.velocity += camera.global_basis.z * current_gun.projectile_info.knock_back
	
	var muzle : Node3D = player_model.gun.get_muzle()
	
	if current_gun.projectile_info.spawn_effect:
		var particle : Node = current_gun.projectile_info.spawn_effect.instantiate()
		muzle.add_child(particle)
	
	player_model.gun.shot = true
	
	for i : int in current_gun.bullets_per_shot:
		
		
		var projectile : ProjectBehavior = ProjectBehavior.new()
		add_child(projectile)
		projectile.global_position = camera.global_position
		projectile.muzle_position = muzle.global_position
		
		projectile.target_position = target_raycast.global_basis.z * -100.0
		
		if target_raycast.is_colliding():
			projectile.look_at(target_raycast.get_collision_point())
		else:
			projectile.look_at(camera.global_position - (camera.global_basis.z * 100.0))
		
		var spread : float = current_gun.spread
		var vec_spread : Vector3 = Vector3(rng.randf_range(-1.0,1.0),rng.randf_range(-1.0,1.0),rng.randf_range(-1.0,1.0))
		if vec_spread.length() > 1.0:
			vec_spread = vec_spread.normalized()
		vec_spread /= 1.0
		var aditional_rot : Vector3 = vec_spread * spread
		projectile.rotate_x(aditional_rot.x)
		projectile.rotate_y(aditional_rot.y)
		projectile.rotate_z(aditional_rot.z)
		
		projectile.data = current_gun.projectile_info
		projectile.start()
		

func alt_shot() -> void:
	
	var audio : AudioStreamPlayer = AudioStreamPlayer.new()
	audio.stream = current_gun.charge_shot_info.projectile_info.sound
	audio.bus = "SFX"
	audio.finished.connect(audio.queue_free)
	add_child(audio)
	audio.play()
	
	body.velocity += camera.global_basis.z * current_gun.charge_shot_info.projectile_info.knock_back
	
	if current_gun.charge_shot_info.projectile_info.spawn_effect:
		var particle : Node = current_gun.charge_shot_info.projectile_info.spawn_effect.instantiate()
		player_model.gun.get_muzle().add_child(particle)
	
	for i : int in current_gun.charge_shot_info.bullets_per_shot:
		var projectile : ProjectBehavior = ProjectBehavior.new()
		add_child(projectile)
		projectile.global_position = camera.global_position
		projectile.muzle_position = player_model.gun.get_muzle().global_position
		
		projectile.target_position = target_raycast.global_basis.z * -100.0
		
		if target_raycast.is_colliding():
			projectile.look_at(target_raycast.get_collision_point())
		else:
			projectile.look_at(camera.global_position - (camera.global_basis.z * 100.0))
		
		var spread : float = current_gun.charge_shot_info.spread
		var vec_spread : Vector3 = Vector3(rng.randf_range(-1.0,1.0),rng.randf_range(-1.0,1.0),rng.randf_range(-1.0,1.0))
		if vec_spread.length() > 1.0:
			vec_spread = vec_spread.normalized()
		vec_spread /= 1.0
		var aditional_rot : Vector3 = vec_spread * spread
		projectile.rotate_x(aditional_rot.x)
		projectile.rotate_y(aditional_rot.y)
		projectile.rotate_z(aditional_rot.z)
		
		projectile.data = current_gun.charge_shot_info.projectile_info
		projectile.start()
		
	player_model.gun.alt_shot = true

var camera_rots_last_frame : Vector3

func sway_gun(delta:float) -> void:
	
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
	
	if current_gun.ammon_type == GlobalEnums.AmmonType.NONE:
		can_reload = true
	
	if not can_reload:
		return
	
	player_model.gun.shot = false
	reload_audio_player.play()
	player_model.reload()
	is_reloading = true
	is_reloading_timer.start(current_gun.reload_time)

func get_next_gun_id() -> int:
	var ret : int = inventory_order.find(current_gun)
	
	while true:
		ret = wrap(ret+1,0,inventory_order.size()-1)
		if inventory[inventory_order[ret]]:
			break
	
	return ret

func get_previous_gun_id() -> int:
	var ret : int = inventory_order.find(current_gun)
	
	while true:
		ret = wrap(ret-1,0,inventory_order.size()-1)
		if inventory[inventory_order[ret]]:
			break
	
	return ret

func manage_wepon_change() -> void:
	var can_continue : bool = false
	for w : GunInfo in inventory:
		if inventory[w]:
			can_continue = true
			break
	if not can_continue:
		return
	
	if Input.is_action_just_pressed("wepon_1") and inventory_order.size() > 0:
		set_gun(inventory_order[0])
	elif Input.is_action_just_pressed("wepon_2") and inventory_order.size() > 1:
		set_gun(inventory_order[1])
	elif Input.is_action_just_pressed("wepon_3") and inventory_order.size() > 2: 
		set_gun(inventory_order[2])
	elif Input.is_action_just_pressed("wepon_4") and inventory_order.size() > 3:
		set_gun(inventory_order[3])
	elif Input.is_action_just_pressed("wepon_5") and inventory_order.size() > 4:
		set_gun(inventory_order[4])
	elif Input.is_action_just_pressed("wepon_6") and inventory_order.size() > 5:
		set_gun(inventory_order[5])
	elif Input.is_action_just_pressed("wepon_7") and inventory_order.size() > 6:
		set_gun(inventory_order[6])
	elif Input.is_action_just_pressed("wepon_8") and inventory_order.size() > 7:
		set_gun(inventory_order[7])
	elif Input.is_action_just_pressed("wepon_9") and inventory_order.size() > 8:
		set_gun(inventory_order[8])
	
	if Input.is_action_just_released("next_wepon"):
		set_gun(inventory_order[get_next_gun_id()])
	elif Input.is_action_just_released("previous_wepon"):
		set_gun(inventory_order[get_previous_gun_id()])
	

func process_aim() -> void:
	
	if not current_gun.aim_info:
		return
	
	if is_reloading:
		camera.fov = 90.0
		player_model.visible = true
		player_model.gun.is_scoping = false
		player_movement.sensitivity_multplyer = 1.0
		return
	
	if Input.is_action_pressed("alt_shot"):
		camera.fov = current_gun.aim_info.zoom
		player_model.visible = not current_gun.aim_info.hide_gun_on_zoom
		player_model.gun.is_scoping = true
		player_movement.sensitivity_multplyer = current_gun.aim_info.sensitivity_multplyer
	else:
		camera.fov = 90.0
		player_model.visible = true
		player_model.gun.is_scoping = false
		player_movement.sensitivity_multplyer = 1.0

func process_shot(delta: float) -> void:
	
	process_aim()
	
	if is_reloading or not current_gun or not player_model or not player_model.gun:
		return
	
	
	
	#input
	var input_shot : bool = false
	if current_gun.is_automatic:
		input_shot = Input.is_action_pressed("shot")
	elif not current_gun.is_automatic and current_gun.charge_shot_info:
		input_shot = Input.is_action_just_released("shot")
	else:
		input_shot = Input.is_action_just_pressed("shot")
	
	time_last_shot -= delta
	
	
	#get normal ammon info
	var has_ammon_normal : bool = false
	if current_gun.ammon_capacity > 0:
		has_ammon_normal = get_ammon_on_mag(current_gun) >= current_gun.ammon_consumption
	else:
		has_ammon_normal = ammon_inventory[current_gun.ammon_type] >= current_gun.ammon_consumption
	
	#get alt ammon info
	var has_ammon_alt : bool = false
	if current_gun.charge_shot_info:
		if current_gun.ammon_capacity > 0:
			has_ammon_alt = get_ammon_on_mag(current_gun) >= current_gun.charge_shot_info.ammon_consumption
		else:
			has_ammon_alt = ammon_inventory[current_gun.charge_shot_info.ammon_type] >= current_gun.charge_shot_info.ammon_consumption
		
		if ammon_inventory[current_gun.charge_shot_info.ammon_type] <= 0:
			ammon_inventory[current_gun.charge_shot_info.ammon_type] = 0
	
	
	#end automatc animation
	if (current_gun.is_automatic and (not input_shot or not has_ammon_normal)):
		player_model.gun.shot = false
	
	#reload
	if (Input.is_action_just_pressed("reload") or not has_ammon_normal) and current_gun.ammon_capacity > 0 and get_ammon_on_mag(current_gun) < current_gun.ammon_capacity:
		reload()
		return
	
	#charge shot
	
	if current_gun.charge_shot_info:
		var input_charge_shot : bool = Input.is_action_pressed("shot")
		
		if charge_shot_time <= 0.2:
			player_model.gun.charge_estate = 0
		elif charge_shot_time > 0.2 and charge_shot_time < current_gun.charge_shot_info.charge_time :
			player_model.gun.charge_estate = 1
		else:
			player_model.gun.charge_estate = 2
		if not has_ammon_alt:
			player_model.gun.charge_estate = 0
		
		
		if has_ammon_alt and time_last_shot <= 0 and input_shot and charge_shot_time >= current_gun.charge_shot_info.charge_time:
			
			alt_shot()
			
			
			if current_gun.ammon_capacity > 0:
				set_ammon_on_mag(current_gun,get_ammon_on_mag(current_gun)-current_gun.charge_shot_info.ammon_consumption)
			elif current_gun.ammon_type != GlobalEnums.AmmonType.NONE:
				ammon_inventory[current_gun.charge_shot_info.ammon_type] -= current_gun.charge_shot_info.ammon_consumption
			
			if ammon_inventory[current_gun.charge_shot_info.ammon_type] <= 0:
				ammon_inventory[current_gun.charge_shot_info.ammon_type] = 0
			
			time_last_shot = current_gun.charge_shot_info.fire_rate
			
			if not current_gun.is_automatic:
				charge_shot_time = 0.0
				return
		
		if not input_charge_shot:
			charge_shot_time = 0
		else:
			charge_shot_time += delta
	
	#charge shot sfx
	
	match player_model.gun.charge_estate:
		0:
			charge_audio_player.stop()
		1:
			if charge_audio_player.stream != current_gun.charge_shot_info.charge_sound:
				charge_audio_player.stream = current_gun.charge_shot_info.charge_sound
			if not charge_audio_player.playing:
				charge_audio_player.play()
		2:
			if charge_audio_player.stream != current_gun.charge_shot_info.charged_sound:
				charge_audio_player.stream = current_gun.charge_shot_info.charged_sound
			if not charge_audio_player.playing:
				charge_audio_player.play()
	
	
	#normal shot
	if input_shot and has_ammon_normal and time_last_shot <= 0:
		shot()
		
		time_last_shot = current_gun.fire_rate
		
		
		if current_gun.ammon_capacity > 0:
			set_ammon_on_mag(current_gun,get_ammon_on_mag(current_gun)-current_gun.ammon_consumption)
		elif current_gun.ammon_type != GlobalEnums.AmmonType.NONE:
			ammon_inventory[current_gun.ammon_type] -= current_gun.ammon_consumption
		
		return



func _process(delta: float) -> void:
	
	manage_wepon_change()
	
	process_inventory_reload_time(delta)
	
	process_shot(delta)
	
	sway_gun(delta)
	
	var input_dir : Vector3 = body.basis * Vector3(Input.get_axis("left","right"),0.0,Input.get_axis("foward","back")).normalized()
	player_model.gun_animations.walk = move_toward(player_model.gun_animations.walk , input_dir.length() , delta * 4.0)
	
	
