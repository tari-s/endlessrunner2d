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
	check_bounds()

func check_bounds():
	# Check if player is off-screen (left or right)
	# Assuming screen width 1200, allowing a small buffer of 50px
	if global_position.x < -50 or global_position.x > 1250:
		game_over()

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

const DEATH_EXPLOSION = preload("res://death_explosion.tscn")

func game_over():
	# Spawn explosion
	var explosion = DEATH_EXPLOSION.instantiate()
	explosion.global_position = global_position + Vector2(20, 20)
	# Add to main scene (Game) so it's not removed if player is removed, 
	# and to ensure it displays on top.
	get_tree().current_scene.add_child(explosion)

	# If GameManager exists, use it; otherwise reload scene directly
	if has_node("../GameManager"):
		var game_manager = get_node("../GameManager")
		if game_manager:
			game_manager.end_game()
	else:
		# Fallback: reload scene directly (old behavior)
		get_tree().reload_current_scene()
