extends Node

# Game states
enum GameState {
	MENU,
	PLAYING,
	GAME_OVER
}

var current_state: GameState = GameState.MENU
static var is_restarting: bool = false

# Signals for UI to listen to
signal game_started
signal game_over
signal game_restarted

func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS  # Always process, even when paused
	if is_restarting:
		start_game()
		is_restarting = false

func start_game():
	current_state = GameState.PLAYING
	get_tree().paused = false
	game_started.emit()
	print("Game started!")

func end_game():
	current_state = GameState.GAME_OVER
	get_tree().paused = true
	game_over.emit()
	print("Game over!")

func restart_game():
	is_restarting = true
	current_state = GameState.PLAYING
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
