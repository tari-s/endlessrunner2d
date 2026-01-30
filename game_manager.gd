extends Node

# Game states
enum GameState {
	MENU,
	PLAYING,
	GAME_OVER
}

var current_state: GameState = GameState.MENU
static var is_restarting: bool = false

# Audio
@export var game_over_sound: AudioStream
var audio_player: AudioStreamPlayer

# Signals for UI to listen to
signal game_started
signal game_over
signal game_restarted

func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS  # Always process, even when paused
	load_high_score()
	
	# Setup Audio Player
	audio_player = AudioStreamPlayer.new()
	add_child(audio_player)
	
	if is_restarting:
		start_game()
		is_restarting = false

func start_game():
	current_state = GameState.PLAYING
	get_tree().paused = false
	game_started.emit()
	score = 0.0
	score_updated.emit(0)
	print("Game started!")

	score = 0.0
	score_updated.emit(0)
	print("Game started!")

func end_game():
	current_state = GameState.GAME_OVER
	get_tree().paused = true
	
	# Update High Score
	var final_score = int(score)
	if final_score > high_score:
		high_score = final_score
		save_high_score()
	
	if game_over_sound:
		audio_player.stream = game_over_sound
		audio_player.play()
		
	game_over.emit()
	print("Game over!")

func restart_game():
	is_restarting = true
	current_state = GameState.PLAYING
	score = 0.0
	score_updated.emit(0)
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

# Score System
var score: float = 0.0
@export var score_speed: float = 10.0  # Points per second
signal score_updated(new_score: int)

func _process(delta: float):
	if current_state == GameState.PLAYING:
		score += score_speed * delta
		score_updated.emit(int(score))

# High Score Persistence
var high_score: int = 0
const SAVE_PATH = "user://high_score.save"

func save_high_score():
	var config = ConfigFile.new()
	config.set_value("Game", "high_score", high_score)
	config.save(SAVE_PATH)

func load_high_score():
	var config = ConfigFile.new()
	var err = config.load(SAVE_PATH)
	if err == OK:
		high_score = config.get_value("Game", "high_score", 0)
