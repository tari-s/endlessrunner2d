extends Node

# Game states
enum GameState {
	MENU,
	PLAYING,
	GAME_OVER
}

var current_state: GameState = GameState.MENU
static var is_restarting: bool = false

# Manager References
var score_manager: ScoreManager
var audio_manager: AudioManager

# Signals for UI to listen to
signal game_started
signal game_over
signal game_restarted

# Difficulty System
@export var base_speed: float = 250.0
@export var max_speed: float = 850.0
@export var difficulty_ramp_seconds: float = 45.0

var difficulty_factor: float = 0.0 # 0.0 (start) to 1.0 (max)
var elapsed_play_time: float = 0.0

func get_current_speed() -> float:
	return lerp(base_speed, max_speed, difficulty_factor)

func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS  # Always process, even when paused
	
	# Get manager references (they are siblings in the scene tree)
	if has_node("../ScoreManager"):
		score_manager = get_node("../ScoreManager")
	if has_node("../AudioManager"):
		audio_manager = get_node("../AudioManager")
	
	if is_restarting:
		call_deferred("start_game")
		is_restarting = false

func start_game():
	current_state = GameState.PLAYING
	get_tree().paused = false
	game_started.emit()
	
	# Reset managers
	if score_manager:
		score_manager.reset()
	difficulty_factor = 0.0
	elapsed_play_time = 0.0
	
	print("Game started!")
	
	# Start engine sound (deferred to ensure AudioManager is ready)
	if audio_manager:
		audio_manager.call_deferred("start_engine")

func end_game():
	current_state = GameState.GAME_OVER
	get_tree().paused = true
	
	# Finalize score
	if score_manager:
		score_manager.finalize_score()
	
	# Play game over sound and stop engine
	if audio_manager:
		audio_manager.play_game_over()
		audio_manager.stop_engine()
		
	game_over.emit()
	print("Game over!")

func restart_game():
	is_restarting = true
	current_state = GameState.PLAYING
	difficulty_factor = 0.0
	elapsed_play_time = 0.0
	game_restarted.emit()
	get_tree().paused = false
	get_tree().reload_current_scene()
	print("Game restarted!")

func show_menu():
	current_state = GameState.MENU
	get_tree().paused = true
	print("Showing menu")

func is_playing() -> bool:
	return current_state == GameState.PLAYING

func _process(delta: float):
	if current_state == GameState.PLAYING:
		# Update Difficulty
		elapsed_play_time += delta
		difficulty_factor = clamp(elapsed_play_time / difficulty_ramp_seconds, 0.0, 1.0)
