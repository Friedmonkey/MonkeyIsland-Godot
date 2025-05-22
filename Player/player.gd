extends CharacterBody3D

signal punch()
signal changed_aiming(is_aiming : bool)
signal pressed_jump(jump_state : JumpState)
signal changed_movement_state(_movement_state: MovementState)
signal changed_movement_direction(_movement_direction: Vector3)

@export var movement_states: Dictionary
@export var max_air_jump : int = 1
@export var jump_states : Dictionary

var air_jump_counter : int = 0
var current_movement_state_name : String
var movement_direction : Vector3
var is_aiming : bool = false 

func _ready() -> void:
	set_movement_state("stand")
	set_aiming(false)

func _input(event):
	if Input.is_action_just_pressed("aim"):
		set_aiming(true)
	elif Input.is_action_just_released("aim"):
		set_aiming(false)
	if (is_aiming && event.is_action_pressed("punch")):
		punch.emit()
	elif event.is_action("movement"):
		movement_direction.x = Input.get_action_strength("left") - Input.get_action_strength("right")
		movement_direction.z = Input.get_action_strength("forward") - Input.get_action_strength("back")
		
		if is_movement_ongoing():
			if Input.is_action_pressed("sprint"):
				set_movement_state("sprint")
				#if current_stance_name == "stealth":
				#	set_stance("upright")
			else:
				if Input.is_action_pressed("walk"):
					set_movement_state("walk")
				else:
					set_movement_state("run")
		else:
			set_movement_state("stand")
	
	
func set_aiming(aiming : bool):
	is_aiming = aiming
	changed_aiming.emit(is_aiming)
	
func set_movement_state(state : String):
	current_movement_state_name = state
	changed_movement_state.emit(movement_states[state])
	
func is_movement_ongoing() -> bool:
	return abs(movement_direction.x) > 0 or abs(movement_direction.z) > 0
	
func _physics_process(_delta: float) -> void:
	if is_movement_ongoing():
		changed_movement_direction.emit(movement_direction)
		
	if is_on_floor():
		air_jump_counter = 0
	#elif air_jump_counter:
		#air_jump_counter = 1
			
	if air_jump_counter <= max_air_jump:
		if Input.is_action_just_pressed("jump"):
			var jump_name = "ground_jump"
			
			if air_jump_counter > 0:
				jump_name = "air_jump"
			
			pressed_jump.emit(jump_states[jump_name])
			air_jump_counter += 1
						#
		#if is_stance_blocked("upright"):
			#return
		#
		#if current_stance_name != "upright" and current_stance_name != "stealth":
			#set_stance("upright")
			#return
		

	
