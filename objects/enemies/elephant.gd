extends Enemy

"""
Elephant enemy.
"""

@export var audio_dist = 700

@onready var move_sound = $walk
@onready var walk_timer = $WalkTimer
@onready var animation = $AnimationPlayer

var move_speed = 100

func _ready():
	super._ready()

func _on_walk_timer_timeout():
	if abs(Global.protagonist.global_position.x - global_position.x) < audio_dist:
		move_sound.play()
