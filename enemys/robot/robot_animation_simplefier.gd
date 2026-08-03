@tool

extends AnimationTree
class_name RobotAnimationSimplefier

enum States {IDLE,WALK,SHOT,VUNERABLE,DEATH,STOMP}

const state_strings : Dictionary[States,String] = {
	States.IDLE: "idle",
	States.WALK: "walk",
	States.SHOT: "shot",
	States.VUNERABLE: "vunerable",
	States.DEATH: "death",
	States.STOMP: "stomp",
}

var look_modfyers : float :
	set(value):
		look_modfyers = value
		$"../Armature/Skeleton3D/BodyLookAtModifier3D".influence = value
		$"../Armature/Skeleton3D/CannonLookAtModifier3D".influence = value
		$"../Armature/Skeleton3D/MiniGunLookAtModifier3D".influence = value

@export var state : States :
	set(value):
		state = value
		set("parameters/states/transition_request",state_strings[value])

@export var can_recover : bool:
	set(value):
		can_recover = value
		set("parameters/StateMachine/conditions/can_recover",value)

@export var shot_rocket : bool :
	set(value):
		set("parameters/rocket_launcher/request",AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)
		

@export var minigun : bool :
	set(value):
		minigun = value
		if minigun:
			set("parameters/minigun/request",AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)
		else:
			set("parameters/minigun/request",AnimationNodeOneShot.ONE_SHOT_REQUEST_FADE_OUT)

var time_betwen_steps_sfx : float = 1.0
var time_last_steps_sfx : float = 1.0

func _process(delta: float) -> void:
	if state == States.SHOT:
		look_modfyers = move_toward(look_modfyers,1.0,delta*2.0)
	else:
		look_modfyers = move_toward(look_modfyers,0.0,delta*2.0)
	
	
	if OS.has_feature("editor") and Engine.is_editor_hint():
		return
	
	if state == States.WALK:
		time_last_steps_sfx -= delta
	else:
		time_last_steps_sfx = time_betwen_steps_sfx
	
	if time_last_steps_sfx <= 0.0:
		$"../Node3D/step".play()
		time_last_steps_sfx = time_betwen_steps_sfx
