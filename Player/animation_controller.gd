extends Node

@export var animation_tree : AnimationTree
@export var player : CharacterBody3D

var on_floor_blend : float = 1
var on_floor_blend_target : float = 1

var on_aim_blend : float = 1
var on_aim_blend_target : float = 1

var has_punched : bool = false
var punch_buffer_id = 0
var punch_buffer : AnimationNodeBlendTree
var punch_animation_node : AnimationNodeAnimation
var punch_transition_node : AnimationNodeTransition

var tween : Tween

func _ready() -> void:
	punch_transition_node = animation_tree.tree_root.get("nodes/punch_transition/node")
	#switch_punch_buffer("end_punch")
	set_punch_transition("guarding")
	
	animation_tree["parameters/punch_buffer_0/TimeScale/scale"] = 2
	animation_tree["parameters/punch_buffer_1/TimeScale/scale"] = 2
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

func switch_punch_buffer(punch_anim_name: StringName):
	punch_buffer_id = 1 - punch_buffer_id
	punch_buffer = animation_tree.tree_root.get("nodes/punch_buffer_"+str(punch_buffer_id)+"/node")
	punch_animation_node = punch_buffer.get_node("Animation")
	punch_animation_node.animation = punch_anim_name
	 
func set_punch_transition(value:String):
	animation_tree["parameters/punch_transition/transition_request"] = value
func set_punch_buffer_timescale(value: float):
	animation_tree["parameters/punch_buffer_"+str(punch_buffer_id)+"/TimeScale/scale"] = value
func _punch():
	var punchName =  "PunchLeft" if has_punched else "PunchRight"
	has_punched = !has_punched
	punch_buffer_id = 1 if has_punched else 0
	#switch_punch_buffer(punchName)
	#punch_transition_node.xfade_time = 0.5
	set_punch_transition("punch_buffer_"+str(punch_buffer_id))
	#set_punch_buffer_timescale(0)
	#set_punch_buffer_timescale(1)
	
	#animation_tree["parameters/" + punchName + "/request"] = AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE

func _jump(jump_state : JumpState):
	animation_tree["parameters/" + jump_state.animation_name + "/request"] = AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE
#

func _on_set_movement_state(_movement_state : MovementState):
	if tween:
		tween.kill()
		
	animation_tree["parameters/punch_buffer_0/TimeScale/scale"] = _movement_state.punch_speed
	animation_tree["parameters/punch_buffer_1/TimeScale/scale"] = _movement_state.punch_speed
	
	tween = create_tween()
	tween.tween_property(animation_tree, "parameters/blend_movement/blend_position", _movement_state.id, 0.25)
	tween.parallel().tween_property(animation_tree, "parameters/TimeScale1/scale", _movement_state.animation_speed, 0.7)
	pass

#func _on_set_stance(_stance : Stance):
	#animation_tree["parameters/stance_transition/transition_request"] = _stance.name
	#current_stance_name = _stance.name
