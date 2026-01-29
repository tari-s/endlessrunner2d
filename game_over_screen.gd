extends CanvasLayer

func _ready():
	hide()  # Hidden by default
	
	# Listen to GameManager signals
	var game_manager = get_node("../GameManager")
	if game_manager:
		game_manager.game_over.connect(_on_game_over)

func _input(event):
	if visible and event.is_action_pressed("ui_accept"):
		restart_game()

func _on_game_over():
	show()

func restart_game():
	var game_manager = get_node("../GameManager")
	if game_manager:
		game_manager.restart_game()
		hide()
