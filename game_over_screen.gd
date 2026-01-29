extends CanvasLayer

@onready var game_over_label = $CenterContainer/VBoxContainer/GameOverLabel
@onready var restart_button = $CenterContainer/VBoxContainer/RestartButton

func _ready():
	hide()  # Hidden by default
	restart_button.pressed.connect(_on_restart_button_pressed)
	
	# Listen to GameManager signals
	var game_manager = get_node("../GameManager")
	if game_manager:
		game_manager.game_over.connect(_on_game_over)

func _on_game_over():
	show()

func _on_restart_button_pressed():
	var game_manager = get_node("../GameManager")
	if game_manager:
		game_manager.restart_game()
		hide()
