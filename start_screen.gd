extends CanvasLayer

@onready var title_label = $CenterContainer/VBoxContainer/TitleLabel
@onready var play_button = $CenterContainer/VBoxContainer/PlayButton

func _ready():
	play_button.pressed.connect(_on_play_button_pressed)
	
	var game_manager = get_node("../GameManager")
	if game_manager and game_manager.is_playing():
		hide()
	else:
		show()

func _on_play_button_pressed():
	var game_manager = get_node("../GameManager")
	if game_manager:
		game_manager.start_game()
		hide()  # Hide the start screen
