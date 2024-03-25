class_name SoundAmbience
extends Node2D

"""
Kind of like a sound pool, it holds multiple Audio Stream Players and then plays 
sounds at random intervals to give an ambience. Used in the 2nd Gogh section.
"""

# Low and high bound of seconds between playing sounds
@export var low : float = 1
@export var high : float = 2

@onready var timer: Timer = $Timer

var sounds: Array[AudioStreamPlayer]
var rng = RandomNumberGenerator.new()
var last_index = -1

# Put AudioStreamPlayers into an array and setup/start the timer
func _ready() -> void:
	for child in get_children():
		if child is AudioStreamPlayer:
			sounds.append(child)
			child.finished.connect(sound_finished)

	timer.set_wait_time(low)
	timer.set_paused(false)
	timer.start()

func sound_finished() -> void:
	timer.set_paused(false)
	timer.start(rng.randi_range(low, high))
			
# Gets a random item from the pool
func get_random() -> int:
	var index = rng.randi_range(0, len(sounds) - 1)
	while index == last_index:
		index = rng.randi_range(0, len(sounds) - 1)
	last_index = index
	return index

# Play a random sound that is different from the previous sound
func play_random_sound() -> void:
	sounds[get_random()].play()

# When the timer times out, play a sound, and don't restart the timer until the 
# sound is done
func _on_timer_timeout():
	timer.set_paused(true)
	play_random_sound()

# Stop ambience sounds
func stop_ambience() -> void:
	timer.set_paused(true)

# Restart ambience sounds
func start_ambience() -> void:
	timer.set_paused(false)
	