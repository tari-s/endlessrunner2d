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
	var game_manager = get_node("../GameManager")
	if game_manager:
		var current_score = int(game_manager.score)
		var high_score = game_manager.high_score
		
		# Update Labels
		var score_label = $CenterContainer/VBoxContainer/ScoreLabel
		var high_score_label = $CenterContainer/VBoxContainer/HighScoreLabel
		
		score_label.text = "Score: " + str(current_score)
		high_score_label.text = "High Score: " + str(high_score)
		
		# Check if new high score (approximate check since we already updated logic in manager)
		# Actually manager updates first, so high_score IS the max. 
		# If high_score == current_score and current_score > 0, we can assume it's a new high score?
		# Or better, just check if we beat the OLD high score? 
		# For this iteration, let's just color it Gold if it matches current score AND > 0
		if current_score > 0 and current_score >= high_score:
			high_score_label.add_theme_color_override("font_color", Color(0.9, 0.8, 0.2))
		else:
			high_score_label.add_theme_color_override("font_color", Color(0.8, 0.8, 0.8))

	show()

func restart_game():
	var game_manager = get_node("../GameManager")
	if game_manager:
		game_manager.restart_game()
		hide()
