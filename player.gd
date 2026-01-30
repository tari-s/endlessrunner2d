extends CharacterBody2D

@export var move_speed := 350

func _physics_process(delta):
	# Only move if game is playing (if GameManager exists)
	if has_node("../GameManager"):
		var game_manager = get_node("../GameManager")
		if game_manager and not game_manager.is_playing():
			return
	
	# Reset visuals if they were hidden in game_over
	if has_node("ShipVisual"): $ShipVisual.show()
	if has_node("ShipOutline"): $ShipOutline.show()
	set_physics_process(true)
	
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

const DEATH_EXPLOSION = preload("res://death_explosion.tscn")
const COLLECTION_SPARK = preload("res://collection_spark.tscn")

func check_collisions():
	for i in range(get_slide_collision_count()):
		var collision = get_slide_collision(i)
		var collider = collision.get_collider()
		
		# Check for power-ups
		if "is_powerup" in collider and collider.is_powerup:
			if collider.powerup_type == "multiplier":
				if has_node("../GameManager"):
					get_node("../GameManager").activate_multiplier(5.0)
				
				# Spawn spark at star position
				var spark = COLLECTION_SPARK.instantiate()
				spark.global_position = collider.global_position
				if has_node("../HUD"):
					get_node("../HUD").add_child(spark)
				else:
					get_tree().current_scene.add_child(spark)
					
				collider.queue_free()
			continue # Power-ups don't stop movement or kill
		
		# Check if the collider is deadly
		if "deadly" in collider:
			if collider.deadly:
				game_over()
		else:
			# If it doesn't have "deadly" property, assume it's deadly (like floor/ceiling)
			game_over()


func game_over():
	# Stop movement
	velocity = Vector2.ZERO
	set_physics_process(false)
	
	# Hide ship
	if has_node("ShipVisual"): $ShipVisual.hide()
	if has_node("ShipOutline"): $ShipOutline.hide()
	
	# Spawn explosion on HUD (top-most layer)
	var explosion = DEATH_EXPLOSION.instantiate()
	
	if has_node("../HUD"):
		# In a CanvasLayer, we need screen coordinates
		var screen_pos = get_global_transform_with_canvas().origin
		explosion.position = screen_pos + Vector2(20, 20)
		get_node("../HUD").add_child(explosion)
	else:
		explosion.global_position = global_position + Vector2(20, 20)
		get_tree().current_scene.add_child(explosion)

	# If GameManager exists, use it; otherwise reload scene directly
	if has_node("../GameManager"):
		var game_manager = get_node("../GameManager")
		if game_manager:
			game_manager.end_game()
	else:
		# Fallback: reload scene directly (old behavior)
		get_tree().reload_current_scene()
