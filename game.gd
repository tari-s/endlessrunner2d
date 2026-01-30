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
	# Initially hide HUD
	if has_node("HUD"):
		$HUD.hide()
		
	# Connect to GameManager signals
	if has_node("GameManager"):
		var mgr = $GameManager
		mgr.score_updated.connect(_on_score_updated)
		mgr.game_started.connect(_on_game_started)
		mgr.game_over.connect(_on_game_over)
		mgr.multiplier_status_changed.connect(_on_multiplier_status_changed)
		
		# Ensure HUD is always visible for effects, we only hide individual elements
		if has_node("HUD"): $HUD.show()
		
		if mgr.is_playing():
			_on_game_started()

func _on_game_started():
	if has_node("HUD/ScoreLabel"):
		$HUD/ScoreLabel.show()
		$HUD/ScoreLabel.add_theme_color_override("font_color", Color(1, 1, 1))
	if has_node("StartScreen"):
		$StartScreen.hide()

func _on_game_over():
	if has_node("HUD/ScoreLabel"):
		$HUD/ScoreLabel.hide()
	if has_node("GameOverScreen"):
		# The instruction snippet was incomplete here, assuming it's just adding the check.
		pass # Placeholder for potential future code

func _on_score_updated(new_score: int):
	if has_node("HUD/ScoreLabel"):
		$HUD/ScoreLabel.text = "Score: " + str(new_score)

func _on_multiplier_status_changed(active: bool):
	if has_node("HUD/ScoreLabel"):
		var color = ObstaclePattern.COLOR_MULTIPLIER if active else Color(1, 1, 1)
		$HUD/ScoreLabel.add_theme_color_override("font_color", color)
