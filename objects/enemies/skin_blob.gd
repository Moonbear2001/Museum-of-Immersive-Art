extends Node2D

@onready var enemy = $Enemy
@onready var timer = $Timer

var move_speed = 100

# Called when the node enters the scene tree for the first time.
func _ready():
	timer.stop()
	enemy.attack = Callable(self, "attack")
	enemy.move = Callable(self, "move")
	if enemy.weak_area:
		enemy.weak_area.connect("body_entered", Callable(self, "death"))
	
func attack(protagonist, direction):
	protagonist.throw(direction.x)
	protagonist.take_damage(1)

func death(body):
	if body.is_in_group("protagonist"):
		timer.start()
		body.throw(0)
		enemy.add_gravity()

func move(delta):
	enemy.velocity.x = enemy.direction.x * move_speed
	if enemy.use_gravity:
		enemy.velocity.y += enemy.gravity * delta

func increase_speed():
	move_speed += 50

func decrease_speed():
	move_speed -= 50
	
func _on_timer_timeout():
	queue_free()
