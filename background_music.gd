extends Node

@onready var music: AudioStreamPlayer = $Music
@export var tracks: Array[AudioStream]  # ensure it's audio streams!

var current_bag: Array = []

func _ready():
	prepare_new_bag()
	play_next_track()
	music.connect("finished", Callable(self, "play_next_track"))

func prepare_new_bag():
	current_bag = tracks.duplicate()
	current_bag.shuffle()

func play_next_track():
	if current_bag.is_empty():
		prepare_new_bag()

	var next_track = current_bag.pop_front()
	music.stream = next_track
	music.play()
