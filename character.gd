@tool
extends CharacterBody3D

@onready var base_human: MeshInstance3D = $MeshRoot/animated_monkey_man_trimmed/Armature/Skeleton3D/BaseHuman
@onready var animation_player: AnimationPlayer = $MeshRoot/animated_monkey_man_trimmed/AnimationPlayer


@export_enum("Armature_001|mixamo_com|Layer0", 
"Armature|mixamo_com|Layer0", "ClimbLeft", "ClimbRight", 
"ClimbingUpWall", "ClimbingUpWall_001", "Cpr", "Dancing", "Dancing2", "Death", 
"Death2", "Falling", "FemalePose1", "FemalePose2", "FireBall", "Flair", 
"Flying", "GangnamStyle", "HangingIdle", "Idle", "LeftPunch", "Man_Clapping", 
"Man_Death", "Man_Idle", "Man_Jump", "Man_Punch", "Man_Roll", "Man_Run", 
"Man_RunningJump", "Man_Sitting", "Man_Standing", "Man_SwordSlash", "Man_Walk", 
"RightPunch", "Running", "StartFighting", "Swimming", "SwimmingIdle", "Walking") 
var animation: String = "Idle":
	set(value):
		animation = value
		if Engine.is_editor_hint() and animation_player.has_animation(value):
			animation_player.play(animation)


#@export var animation : String:
	#set(value):
		#animation = "Idle" if value == null else value
		#if Engine.is_editor_hint():
			#animation_player.play(animation)

@export var skin_material: Material :
	set(value):
		skin_material = value
		if Engine.is_editor_hint():
			_set_materials([0, 2, 5], value) # Replace with actual indices

@export var skin_detail_material: Material :
	set(value):
		skin_detail_material = value
		if Engine.is_editor_hint():
			_set_materials([1, 3, 7], value)

@export var face_material: Material :
	set(value):
		face_material = value
		if Engine.is_editor_hint():
			_set_materials([6, 8], value)

@export var ears_material: Material :
	set(value):
		ears_material = value
		if Engine.is_editor_hint():
			_set_materials([4], value)

func _set_materials(indices: Array[int], mat: Material) -> void:
	for i in indices:
		base_human.set_surface_override_material(i, mat)
	#base_human.property_list_changed_notify()
	
func update() -> void:
	_set_materials([0, 2, 5], skin_material)
	_set_materials([1, 3, 7], skin_detail_material)
	_set_materials([6, 8], face_material)
	_set_materials([4], ears_material)
	
	animation_player.play("Idle" if animation == null else animation)

func _ready() -> void:
	#if not Engine.is_editor_hint():
		#print_animation_enum()
	update()
	
#func print_animation_enum():
	#if not animation_player:
		#print("No AnimationPlayer found :(")
		#return
#
	#var list = animation_player.get_animation_list()
	#var formatted = '@export_enum("' + '", "'.join(list) + '") var animation: String = "Idle"'
	#print(formatted)
