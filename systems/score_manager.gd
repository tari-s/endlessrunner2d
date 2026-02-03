extends Node
class_name ScoreManager

# ============================================================================
# CONSTANTS
# ============================================================================

const SAVE_PATH = "user://high_score.save"

# ============================================================================
# EXPORTS
# ============================================================================

@export var score_speed: float = 10.0  # Points per second

# ============================================================================
# PUBLIC VARIABLES
# ============================================================================

var score: float = 0.0
var current_multiplier: float = 1.0
var multiplier_time_left: float = 0.0
var high_score: int = 0

# Manager References
var audio_manager: AudioManager

# ============================================================================
# SIGNALS
# ============================================================================

signal score_updated(new_score: int)
signal multiplier_status_changed(active: bool, value: float)

# ============================================================================
# LIFECYCLE METHODS
# ============================================================================

func _ready():
	load_high_score()
	current_multiplier = 1.0
	multiplier_time_left = 0.0
	
	# Get AudioManager reference
	if has_node("../AudioManager"):
		audio_manager = get_node("../AudioManager")

func _process(delta: float):
	# Handle Multiplier Timer
	if multiplier_time_left > 0:
		multiplier_time_left -= delta
		if multiplier_time_left <= 0:
			current_multiplier = 1.0
			multiplier_status_changed.emit(false, 1.0)
			print("Multiplier expired")
	
	# Update Score (only when game is playing)
	if has_node("/root/Game/GameManager"):
		var gm = get_node("/root/Game/GameManager")
		if gm.is_playing():
			score += score_speed * delta * current_multiplier
			score_updated.emit(int(score))

# ============================================================================
# PUBLIC API
# ============================================================================

func reset():
	score = 0.0
	current_multiplier = 1.0
	multiplier_time_left = 0.0
	score_updated.emit(0)

func activate_multiplier(duration: float = 5.0, value: float = 2.0):
	current_multiplier = value
	multiplier_time_left = duration
	multiplier_status_changed.emit(true, value)
	
	# Play multiplier sound
	if audio_manager:
		audio_manager.play_multiplier()
	
	print("Multiplier activated: ", value, "x for ", duration, "s")

func finalize_score() -> int:
	var final_score = int(score)
	if final_score > high_score:
		high_score = final_score
		save_high_score()
	return final_score

# ============================================================================
# PRIVATE HELPERS - Persistence
# ============================================================================

func save_high_score():
	var config = ConfigFile.new()
	config.set_value("Game", "high_score", high_score)
	config.save(SAVE_PATH)

func load_high_score():
	var config = ConfigFile.new()
	var err = config.load(SAVE_PATH)
	if err == OK:
		high_score = config.get_value("Game", "high_score", 0)
