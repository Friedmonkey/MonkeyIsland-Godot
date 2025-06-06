extends "res://Character/CharacterBase.gd"  # inherits from base!

signal punch()
signal changed_aiming(is_aiming : bool)
signal pressed_jump(jump_state : JumpState)
signal changed_movement_state(_movement_state: MovementState)
signal changed_movement_direction(_movement_direction: Vector3)

@export var jump_sounds : Array
@export var punch_sounds : Array
@export var footstep_sounds : Dictionary
@export var movement_states: Dictionary
@export var max_air_jump : int = 1
@export var jump_states : Dictionary
@export var sea_level : Node3D
#@export var Terrain: Node

var punch_timer := 0.0
var punch_cooldown := 0.3  # seconds between punches (adjust to taste)

var step_timer := 0.0
var step_interval := 0.2  # seconds between steps (adjust to taste)

var air_jump_counter : int = 0
var current_movement_state_name : String
var movement_direction : Vector3
var is_aiming : bool = false 

func _ready() -> void:
	#if !Terrain or Terrain.name != "TerraTerrain": #terrible validation but idc
		#push_error("Terrain node not assigned (correctly)!")
	set_movement_state("stand")
	set_aiming(false)

func _input(event):
	if Input.is_action_just_pressed("aim"):
		set_aiming(true)
	elif Input.is_action_just_released("aim"):
		set_aiming(false)
	if (is_aiming && event.is_action_pressed("punch")):
		do_punch()
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
	
	
func do_punch() -> void:
	if punch_timer >= 0.0:
		return
		
	punch_timer = punch_cooldown
	if !is_on_floor(): #if player jumps their itmer also kind of resets
		return
		
	punch.emit()
	var sound = punch_sounds[randi() % punch_sounds.size()]
	$PunchSound.stream = sound
	$PunchSound.play()
	
func set_aiming(aiming : bool):
	is_aiming = aiming
	changed_aiming.emit(is_aiming)
	
func set_movement_state(state : String):
	current_movement_state_name = state
	changed_movement_state.emit(movement_states[state])
	step_interval = movement_states[state].step_duration
	punch_cooldown = movement_states[state].punch_cooldown
	
func is_movement_ongoing() -> bool:
	return abs(movement_direction.x) > 0 or abs(movement_direction.z) > 0

func get_current_floor(info) -> String:
	if (info.get("WaterFactor") > 0.1):
		return "Water"
		
	if (info.get("SnowFactor") > 0.2):
		return "Snow"
	
	var textures = info.get("Textures")
	#var max_factor = -INF
	var max_item = null
	max_item = textures[0]
	#
	#for item in textures:
		#var factor = item.get("Factor")
		#if factor > max_factor:
			#max_factor = factor	
			#max_item = item
		#pass
	#pass
	#
	if max_item != null:
		return max_item.get("Name")
	return ""

func handle_floor(collision: KinematicCollision3D):
	var material_name : String = "Grass"
	var collider1 := collision.get_collider()
	var collider2 = %TerraTerrain.get("Terrain").get("TerrainCollider")
	if collider1 == collider2:
		var pos = self.global_position
		var info = %TerraTerrain.GetPositionInformation(pos.x, pos.z)
		%TerraTerrain.AddInteractionPoint(pos.x, pos.z)
		material_name = get_current_floor(info)
	
	play_footstep_sound(material_name)
	

func play_footstep_sound(material_name: String) -> void:
	if material_name in footstep_sounds:
		var sounds = footstep_sounds[material_name]
		var sound = sounds[randi() % sounds.size()]
		$FootstepSound.stream = sound
		$FootstepSound.play()
	else:
		print("No footstep sound mapped for material:", material_name)
		
func jump(jump_state : JumpState) -> void:
	pressed_jump.emit(jump_state)
	var sound = punch_sounds[randi() % punch_sounds.size()]
	$JumpSound.stream = sound
	$JumpSound.play()
	
#func _process(delta: float) -> void:
	#
	#pass

func _physics_process(delta: float) -> void:
	if position.y+1 < sea_level.position.y:
		position = Vector3(10,10,-15) #respawn the player
	if (punch_timer >= 0):
		punch_timer -= delta
	if is_movement_ongoing():
		changed_movement_direction.emit(movement_direction)
		#$"../TerraTerrain".()
		#if (movement_direction != Vector3.ZERO):
			##var idk = $"../TerraBrush".GetPositionInformation(movement_direction.x, movement_direction.y)
			#var idk2 = $"../TerraBrush".AddInteractionPoint(movement_direction.x, movement_direction.y)
			#pass
	var collision := get_last_slide_collision()
	if is_on_floor() && collision != null:
		air_jump_counter = 0
		if (step_interval != 404):
			step_timer -= delta
			if step_timer <= 0.0:
				handle_floor(collision)
				step_timer = step_interval
	else:
		step_timer = 0.0  # reset if airborne
		#var pos = self.global_position
		#%TerraTerrain.AddInteractionPoint(pos.x, pos.z)
		#DebugDraw3D.draw_line(pos, pos+Vector3.DOWN, Color.RED)
	#elif air_jump_counter:
		#air_jump_counter = 1
			
	if air_jump_counter <= max_air_jump:
		if Input.is_action_just_pressed("jump"):
			var jump_name = "ground_jump"
			
			if air_jump_counter > 0:
				jump_name = "air_jump"
			
			jump(jump_states[jump_name])
			air_jump_counter += 1
						#
		#if is_stance_blocked("upright"):
			#return
		#
		#if current_stance_name != "upright" and current_stance_name != "stealth":
			#set_stance("upright")
			#return
		

	
