extends Node

const WORLD_WIDTH := 1200
const WORLD_HEIGHT := 600

@onready var spawner = $ObstacleSpawner

func _ready():
	pass

func pause_game():
	if spawner:
		spawner.pause_spawning()

func resume_game():
	if spawner:
		spawner.resume_spawning()
