extends Node2D

"""
Top level script for the tutorial level.
"""

@onready var moving_platform_animation_player = $MovingPlatform/Platform/AnimationPlayer

# Ready
func _ready():
	
	# Stop the moving platform
	moving_platform_animation_player.stop()

# Called when the lever is pulled, toggles moving platform animation
func _on_lever_toggle_moving_platform():
	if moving_platform_animation_player.is_playing():
		moving_platform_animation_player.pause()
	else:
		moving_platform_animation_player.play()
