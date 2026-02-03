extends Node

# ============================================================================
# CONSTANTS
# ============================================================================

const WORLD_WIDTH := 1200
const WORLD_HEIGHT := 600

# ============================================================================
# PRIVATE VARIABLES
# ============================================================================

@onready var _spawner = $ObstacleSpawner

# ============================================================================
# LIFECYCLE METHODS
# ============================================================================

func _ready():
	# Initially hide HUD
	if has_node("HUD"):
		$HUD.hide()
		
	# Connect to managers
	if has_node("GameManager"):
		var mgr = $GameManager
		mgr.game_started.connect(_on_game_started)
		mgr.game_over.connect(_on_game_over)
		
		if mgr.is_playing():
			_on_game_started()
	
	if has_node("ScoreManager"):
		var score_mgr = $ScoreManager
		score_mgr.score_updated.connect(_on_score_updated)
		score_mgr.multiplier_status_changed.connect(_on_multiplier_status_changed)
		
		# Ensure HUD is always visible for effects, we only hide individual elements
		if has_node("HUD"): $HUD.show()
		
		# Hide individual elements initially
		if has_node("HUD/ScoreLabel"): $HUD/ScoreLabel.hide()

# ============================================================================
# PUBLIC API
# ============================================================================

func pause_game():
	if _spawner:
		_spawner.pause_spawning()

func resume_game():
	if _spawner:
		_spawner.resume_spawning()

# ============================================================================
# SIGNAL HANDLERS
# ============================================================================

func _on_game_started():
	if has_node("HUD/ScoreLabel"):
		$HUD/ScoreLabel.show()
		$HUD/ScoreLabel.text = "Score: 0"
		$HUD/ScoreLabel.add_theme_color_override("font_color", Color(1, 1, 1))
	if has_node("StartScreen"):
		$StartScreen.hide()

func _on_game_over():
	if has_node("HUD/ScoreLabel"):
		$HUD/ScoreLabel.hide()
	if has_node("GameOverScreen"):
		$GameOverScreen.show()

func _on_score_updated(new_score: int):
	if has_node("HUD/ScoreLabel"):
		$HUD/ScoreLabel.text = "Score: " + str(new_score)

func _on_multiplier_status_changed(active: bool, value: float):
	if has_node("HUD/ScoreLabel"):
		var label = get_node("HUD/ScoreLabel")
		var target_color = Color(1, 1, 1)  # White (Normal)
		
		if active:
			if value >= 4.9:  # Buffer for float precision
				target_color = ObstaclePattern.COLOR_SUPER_MULTIPLIER
			elif value >= 1.9:
				target_color = ObstaclePattern.COLOR_MULTIPLIER
		
		label.add_theme_color_override("font_color", target_color)
		print("Score Label Color Updated: ", target_color, " for multiplier ", value)
