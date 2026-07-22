@tool

extends AnimationTree
class_name RobotAnimationSimplefier

enum States {IDLE,WALK,SHOT,VUNERABLE,DEATH}

const state_strings : Dictionary[States,String] = {
	States.IDLE: "idle",
	States.WALK: "walk",
	States.SHOT: "shot",
	States.VUNERABLE: "vunerable",
	States.DEATH: "death",
}

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
