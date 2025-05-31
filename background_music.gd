extends Node

@onready var music: AudioStreamPlayer = $Music
@onready var waves: AudioStreamPlayer = $Waves
@onready var grass: AudioStreamPlayer = $Grass

@export var tracks: Array[AudioStream]  # ensure it's audio streams!
@export var player: Node3D

var current_bag: Array = []

var waves_target_volume_db := -80.0  # Target dB we want to fade to
var waves_current_volume_db := -80.0  # Current interpolated dB

var grass_target_volume_db := -80.0  # Target dB we want to fade to
var grass_current_volume_db := -80.0  # Current interpolated dB

func _ready():
	prepare_new_bag()
	play_next_track()
	music.connect("finished", Callable(self, "play_next_track"))
	
func _process(delta: float) -> void:
	handle_terrain_meta(delta)

func prepare_new_bag():
	current_bag = tracks.duplicate()
	current_bag.shuffle()

func play_next_track():
	if current_bag.is_empty():
		prepare_new_bag()

	var next_track = current_bag.pop_front()
	music.stream = next_track
	music.play()
	
func volume_from_factor(factor):
	var min_db = -10
	var max_db = 24
	return lerp(min_db, max_db, factor)

#func handle_terrain_meta():
	#var factor = get_terrain_meta("Water")
	#var volume_db = volume_from_factor(factor)
	#waves.volume_db = volume_db
	#
	#pass 
	

func handle_terrain_meta(delta: float) -> void:
	var water_factor = get_terrain_meta("Water")
	waves_target_volume_db = volume_from_factor(water_factor)
	waves_current_volume_db = lerp(waves_current_volume_db, waves_target_volume_db, delta * 5.0)
	waves.volume_db = min(waves_current_volume_db, 10)
	
	var grass_factor = get_terrain_meta("Grass")
	grass_target_volume_db = volume_from_factor(grass_factor)
	grass_current_volume_db = lerp(grass_current_volume_db, grass_target_volume_db, delta * 5.0)
	grass.volume_db = min(grass_current_volume_db, 15)
	if (grass_factor < 0.00001):
		grass.volume_db = -80
	
	# Smooth interpolation (tweak 5.0 to change speed)
func get_terrain_meta(meta : String) -> float:
	var pos = player.global_position
	var info = %TerrainMeta.GetPositionInformation(pos.x, pos.z)
	for obj in info.get("Textures"):
		if obj.get("Name") == meta:
			return obj.get("Factor")
	return 0  # not found
