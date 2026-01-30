extends Node

const WORLD_WIDTH := 1200
const WORLD_HEIGHT := 600

@onready var spawner = $ObstacleSpawner

# Optional: Control spawning based on game state
func pause_game():
	if spawner:
		spawner.pause_spawning()

func resume_game():
	if spawner:
		spawner.resume_spawning()

func _ready():
	# Connect to GameManager score signal
	if has_node("GameManager"):
		$GameManager.score_updated.connect(_on_score_updated)

func _on_score_updated(new_score: int):
	if has_node("HUD/ScoreLabel"):
		$HUD/ScoreLabel.text = "Score: " + str(new_score)
