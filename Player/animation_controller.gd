extends Node

@export var animation_tree : AnimationTree
@export var player : CharacterBody3D

var on_floor_blend : float = 1
var on_floor_blend_target : float = 1

var on_aim_blend : float = 1
var on_aim_blend_target : float = 1

var has_punched : bool = false

var tween : Tween

#var current_stance_name = "upright"
#
func _aiming(aiming: bool):
	on_aim_blend_target = 1 if aiming else 0

func _physics_process(delta):
	on_floor_blend_target = 1 if player.is_on_floor() else 0
	on_floor_blend = lerp(on_floor_blend, on_floor_blend_target, 10 * delta)
	animation_tree["parameters/on_floor_blend/blend_amount"] = on_floor_blend
	
	#on_aim_blend_target = 1 if player.is_on_floor() else 0
	on_aim_blend = lerp(on_aim_blend, on_aim_blend_target, 10 * delta)
	animation_tree["parameters/aiming_blend/blend_amount"] = on_aim_blend

func _punch():
	var punchName =  "PunchLeft" if has_punched else "PunchRight"
	has_punched = !has_punched
	animation_tree["parameters/" + punchName + "/request"] = AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE

func _jump(jump_state : JumpState):
	animation_tree["parameters/" + jump_state.animation_name + "/request"] = AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE
#

func _on_set_movement_state(_movement_state : MovementState):
	if tween:
		tween.kill()
		
	#var idk = _movement_state.id
	#var idk2 = _movement_state.animation_speed
	#
	##var idk:string = "fefef"
	##
	##if idk.
	#
	#var props = animation_tree.get_property_list()
	#var list_idk = []
	#
	#for condition in animation_tree.get_property_list():
		#if condition.name.contains("parameters/movement_anim_speed"):
			##if condition.type == TYPE_BOOL:
				#list_idk.append(condition)
				##set(condition.name, false)
				#pass
	
	tween = create_tween()
	tween.tween_property(animation_tree, "parameters/blend_movement/blend_position", _movement_state.id, 0.25)
	#tween.parallel().tween_property(animation_tree, "parameters/movement_anim_speed/scale", _movement_state.animation_speed, 0.7)
	tween.parallel().tween_property(animation_tree, "parameters/TimeScale1/scale", _movement_state.animation_speed, 0.7)
	pass

#func _on_set_stance(_stance : Stance):
	#animation_tree["parameters/stance_transition/transition_request"] = _stance.name
	#current_stance_name = _stance.name
