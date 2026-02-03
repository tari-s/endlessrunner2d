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
	
	# Get score from ScoreManager
	var score_manager = get_node("../ScoreManager")
	if score_manager:
		var current_score = int(score_manager.score)
		var high_score = score_manager.high_score
		
		# Update Labels
		var score_label = $CenterContainer/VBoxContainer/ScoreLabel
		var high_score_label = $CenterContainer/VBoxContainer/HighScoreLabel
		
		score_label.text = "Score: " + str(current_score)
		high_score_label.text = "High Score: " + str(high_score)
		
		# Highlight if new high score
		if current_score > 0 and current_score >= high_score:
			high_score_label.add_theme_color_override("font_color", Color(0.9, 0.8, 0.2))
		else:
			high_score_label.add_theme_color_override("font_color", Color(0.8, 0.8, 0.8))

func restart_game():
	var game_manager = get_node("../GameManager")
	if game_manager:
		game_manager.restart_game()
	hide()
