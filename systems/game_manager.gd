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
@export var multiplier_sound: AudioStream
@export var jet_engine_sound: AudioStream
var audio_player: AudioStreamPlayer
var engine_player: AudioStreamPlayer

# Signals for UI to listen to
signal game_started
signal game_over
signal game_restarted
signal multiplier_status_changed(active: bool, value: float)

# Multiplier System
var current_multiplier: float = 1.0
var multiplier_time_left: float = 0.0

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
	load_high_score()
	current_multiplier = 1.0
	multiplier_time_left = 0.0
	
	# Setup Audio Player
	audio_player = AudioStreamPlayer.new()
	add_child(audio_player)
	
	# Setup Jet Engine Player
	engine_player = AudioStreamPlayer.new()
	add_child(engine_player)
	if jet_engine_sound:
		engine_player.stream = jet_engine_sound
		if engine_player.stream is AudioStreamMP3:
			engine_player.stream.loop = true
	
	if is_restarting:
		start_game()
		is_restarting = false

func start_game():
	current_state = GameState.PLAYING
	get_tree().paused = false
	game_started.emit()
	score = 0.0
	current_multiplier = 1.0
	multiplier_time_left = 0.0
	difficulty_factor = 0.0
	elapsed_play_time = 0.0
	score_updated.emit(0)
	print("Game started!")
	
	if engine_player and jet_engine_sound:
		if not engine_player.playing:
			engine_player.play()

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
	
	if engine_player:
		engine_player.stop()

func restart_game():
	is_restarting = true
	current_state = GameState.PLAYING
	score = 0.0
	current_multiplier = 1.0
	multiplier_time_left = 0.0
	difficulty_factor = 0.0
	elapsed_play_time = 0.0
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
		# Update Difficulty
		elapsed_play_time += delta
		difficulty_factor = clamp(elapsed_play_time / difficulty_ramp_seconds, 0.0, 1.0)
		
		# Handle Multiplier Timer
		if multiplier_time_left > 0:
			multiplier_time_left -= delta
			if multiplier_time_left <= 0:
				current_multiplier = 1.0
				multiplier_status_changed.emit(false, 1.0)
				print("Multiplier expired")
		
		# Update Score
		score += score_speed * delta * current_multiplier
		score_updated.emit(int(score))

func activate_multiplier(duration: float = 5.0, value: float = 2.0):
	current_multiplier = value
	multiplier_time_left = duration
	multiplier_status_changed.emit(true, value)
	
	if multiplier_sound:
		audio_player.stream = multiplier_sound
		audio_player.play()
		
	print("Multiplier activated: ", value, "x for ", duration, "s")

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
