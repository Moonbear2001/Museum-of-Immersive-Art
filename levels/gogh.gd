extends Level

"""
Custom level script for the Van Gogh level.
"""

@export var lantern: PointLight2D
@export var fuel_bar: Control
@export var refill_stations: Node2D

@onready var wind_timer = $WindTimer
@onready var camera_anim = $Camera2D/AnimationPlayer
@onready var death = $Death
@onready var protagonist_gogh = preload("res://characters/protagonist_gogh.tscn")
@onready var new_lantern = preload("res://objects/lantern.tscn")
@onready var trees = $"Layers/1/Trees"
@onready var parallax_foreground = $ParallaxBackground2
@onready var fade_timer = $"Sound Fade Timer"

const protag_scale = Vector2(1.2, 1.2)

var windArr: Array[Node2D]
var wind = preload("res://objects/wind.tscn")
var smallwind = preload("res://objects/small_wind/breeze.tscn")

var curr_layer = 1

func _ready():
	# Call the base level script's _ready()
	super._ready()
	protagonist.glow = true
	death.respawn.connect(Callable(self, "respawn"))
	
	# Hook up the refill station's signals here because its a pain to do it
	# one by one in the Godot editor (also not good design)
	for refill_station in refill_stations.get_children():
		refill_station.refuel_light.increment_fuel_level.connect(lantern.increment_fuel)
		refill_station.refuel_area_entered.connect(on_refuel_station_entered)
		refill_station.refuel_area_exited.connect(on_refuel_station_exited)

# Call the base level script's _process()
func _process(delta):
	super._process(delta)
	
	change_glow()
	
	if protagonist.global_position.x > 500 and wind_timer.is_stopped():
		wind_timer.start()
	elif protagonist.global_position.x <= 500:
		wind_timer.stop()

# When exiting refill station, put protag back on top of station
func on_refuel_station_exited():
	lantern.station_exited()
	protagonist.glow = true

func on_refuel_station_entered():
	lantern.station_entered()
	protagonist.glow = false

# Reload the level when fuel is exhausted
func _on_lantern_fuel_exhausted():
	respawn()

func change_glow():
	var glow_num = floori(lantern.fuel_level / lantern.MAX_FUEL_LEVEL * 10)
	protagonist.glow_level = str(glow_num)

func respawn():
	var greatest_x_below_target = -INF
	var checkpoint
	for node in get_tree().get_nodes_in_group("checkpoint"):
		if node is RefuelStation and node.visited and node.global_position.x < protagonist.global_position.x and node.global_position.x > greatest_x_below_target:
			greatest_x_below_target = node.global_position.x
			checkpoint = node
	for p in get_tree().get_nodes_in_group("protagonist"):
		p.queue_free()
		
	# Check if a valid x value was found
	if greatest_x_below_target != -INF:	
		var duplicatedNode = protagonist_gogh.instantiate()
		duplicatedNode.set_scale(protag_scale)
		var duplicateLantern = new_lantern.instantiate()
		duplicatedNode.add_child(duplicateLantern)
		duplicatedNode.glow = true
		duplicatedNode.global_position.x = checkpoint.checkpoint_pos.global_position.x
		duplicatedNode.global_position.y = checkpoint.checkpoint_pos.global_position.y
		get_tree().current_scene.add_child(duplicatedNode)
		protagonist = duplicatedNode
		lantern = duplicateLantern
		lantern.fuel_exhausted.connect(Callable(self, "respawn"))
		for refill_station in refill_stations.get_children():
			refill_station.refuel_light.increment_fuel_level.connect(lantern.increment_fuel)
			refill_station.refuel_area_entered.connect(on_refuel_station_entered)
			refill_station.refuel_area_exited.connect(on_refuel_station_exited)
		Global.protagonist = protagonist
	else:
		get_tree().reload_current_scene()

#func cont() -> void:
	#$AnimationPlayer.play("scene_out")
	#await $AnimationPlayer.animation_finished
	#get_tree().change_scene_to_file("res://levels/gogh2.tscn")
	#$AnimationPlayer.play("scene_in")


func _on_wind_timer_timeout():
	spawn_smallwind()

func spawn_wind():
	var screen_size = get_viewport_rect().size
	var x_pos = camera.global_position.x + floori(screen_size.x / 2)

	var newWind = wind.instantiate()
	newWind.global_position = Vector2(x_pos, 260)
	add_child(newWind)
	sway_trees()
	
	
func spawn_smallwind():
	$Gust.play(2)
	var screen_size = get_viewport_rect().size
	var x_pos = camera.global_position.x + floori(screen_size.x / 2)

	var newWind = smallwind.instantiate()
	newWind.breeze_finished.connect(Callable(self, "spawn_wind"))
	newWind.global_position = Vector2(x_pos, 260)
	add_child(newWind)
	sway_trees()

func sway_trees():
	var tree_arr = trees.get_children()
	for tree in tree_arr:
		tree.sway()


func _on_area_2d_body_entered(body):
	if body.is_in_group("protagonist"):
		SceneManager.load_new_scene("res://levels/gogh2.tscn")

# When character gets close to bell tower, ring the bell
func _on_bell_sound_area_body_entered(_body):
	$Bells.play()
	fade_timer.start()
	
# Track collected stars
func collect_star() -> void:
	collected_stars += 1
	
# Custom level end behavior for Van Gogh 1
func level_end(body) -> void:
	print("in gogh: ", level_name)
	if not body.is_in_group("protagonist"):
		return
	
	# Get player's scores for this run
	stopwatch.stop_stopwatch()
	var time: float = stopwatch.get_best_time()
	
	# Get best scores
	var level_high_score: LevelHighScore = Global.high_scores.get_level_high_score(level_name)
	var best_time: float = level_high_score.get_best_time()
	
	# Update saved data
	Global.high_scores.new_last_time(level_name, time)
	if time < best_time:
		Global.high_scores.new_low_time(level_name, time)


func _on_sound_fade_timer_timeout():
	$AccordionBarAmbience.volume_db -= 1
