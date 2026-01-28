extends Node2D

@export var obstacle_scene: PackedScene
@export var spawn_interval := 1.5
@export var spawn_y_min := 70
@export var spawn_y_max := 538

var timer := 0.0

func _physics_process(delta):
	timer += delta

	if timer >= spawn_interval:
		timer = 0
		spawn_obstacle()

func spawn_obstacle():
	var obstacle = obstacle_scene.instantiate()
	add_child(obstacle)

	var screen_size = get_viewport_rect().size
	var margin = 40
	var obstacle_height = 80

	obstacle.position.x = screen_size.x + 50
	obstacle.position.y = randf_range(
		margin,
		screen_size.y - margin - obstacle_height
	)
