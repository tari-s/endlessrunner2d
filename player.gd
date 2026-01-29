extends CharacterBody2D

@export var move_speed := 350

func _physics_process(delta):
	# Only move if game is playing (if GameManager exists)
	if has_node("../GameManager"):
		var game_manager = get_node("../GameManager")
		if game_manager and not game_manager.is_playing():
			return
	
	velocity.x = 0
	velocity.y = 0

	if Input.is_action_pressed("ui_up"):
		velocity.y = -move_speed
	elif Input.is_action_pressed("ui_down"):
		velocity.y = move_speed

	move_and_slide()
	check_collisions()

func check_collisions():
	for i in range(get_slide_collision_count()):
		var collision = get_slide_collision(i)
		var collider = collision.get_collider()
		
		# Check if the collider is deadly
		if "deadly" in collider:
			if collider.deadly:
				game_over()
		else:
			game_over()

func game_over():
	# If GameManager exists, use it; otherwise reload scene directly
	if has_node("../GameManager"):
		var game_manager = get_node("../GameManager")
		if game_manager:
			game_manager.end_game()
	else:
		# Fallback: reload scene directly (old behavior)
		get_tree().reload_current_scene()
