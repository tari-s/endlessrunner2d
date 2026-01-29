extends CanvasLayer

func _ready():
	var game_manager = get_node("../GameManager")
	if game_manager and game_manager.is_playing():
		hide()
	else:
		show()

func _input(event):
	if visible and event.is_action_pressed("ui_accept"):
		start_game()

func start_game():
	var game_manager = get_node("../GameManager")
	if game_manager:
		game_manager.start_game()
		hide()
