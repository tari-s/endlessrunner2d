extends CharacterBody2D

# ============================================================================
# CONSTANTS
# ============================================================================

const COLOR_NORMAL = Color(0.6, 0.7, 1.0)
const COLOR_GOLD = Color(0.9, 0.8, 0.2)
const COLOR_PURPLE = Color(0.7, 0.2, 0.9)

const DEATH_EXPLOSION = preload("res://vfx/death_explosion.tscn")
const COLLECTION_SPARK = preload("res://vfx/collection_spark.tscn")

# ============================================================================
# EXPORTS
# ============================================================================

@export var move_speed := 350

# ============================================================================
# LIFECYCLE METHODS
# ============================================================================

func _ready():
	if has_node("../GameManager"):
		var gm = get_node("../GameManager")
		gm.game_started.connect(_on_game_started)
	
	if has_node("../ScoreManager"):
		var sm = get_node("../ScoreManager")
		sm.multiplier_status_changed.connect(_on_multiplier_changed)
	
	# Reset trail color and ship visibility
	_on_multiplier_changed(false, 1.0)
	
	if has_node("ShipVisual"): $ShipVisual.show()
	if has_node("ShipOutline"): $ShipOutline.show()
	if has_node("TrailParticles"):
		$TrailParticles.emitting = true
	
	set_physics_process(true)

func _physics_process(_delta):
	# Only move if game is playing
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
	_check_collisions()
	_check_bounds()

# ============================================================================
# PRIVATE HELPERS - Collision Detection
# ============================================================================

func _check_bounds():
	# Check if player is off-screen (left or right)
	# Assuming screen width 1200, allowing a small buffer of 50px
	if global_position.x < -50 or global_position.x > 1250:
		_game_over()

func _check_collisions():
	for i in range(get_slide_collision_count()):
		var collision = get_slide_collision(i)
		var collider = collision.get_collider()
		
		# Check for power-ups
		if "is_powerup" in collider and collider.is_powerup:
			_handle_powerup_collection(collider)
			continue  # Power-ups don't stop movement or kill
		
		# Check if the collider is deadly
		if "deadly" in collider:
			if collider.deadly:
				_game_over()
		else:
			# If it doesn't have "deadly" property, assume it's deadly (like floor/ceiling)
			_game_over()

func _handle_powerup_collection(collider):
	if collider.powerup_type.begins_with("multiplier"):
		var mult_value = 2.0
		if collider.powerup_type == "multiplier_5x":
			mult_value = 5.0
		
		if has_node("../ScoreManager"):
			get_node("../ScoreManager").activate_multiplier(5.0, mult_value)
		
		print("Collected Multiplier: ", mult_value, "x (Type: ", collider.powerup_type, ")")
		
		# Spawn spark at star position
		var spark = COLLECTION_SPARK.instantiate()
		spark.global_position = collider.global_position
		
		# Customize spark color
		var spark_color = COLOR_GOLD
		if mult_value >= 4.9:
			spark_color = COLOR_PURPLE
		
		if spark.has_method("set_color"):
			spark.set_color(spark_color)
		
		if has_node("../HUD"):
			get_node("../HUD").add_child(spark)
		else:
			get_tree().current_scene.add_child(spark)
			
		collider.queue_free()

# ============================================================================
# PRIVATE HELPERS - Game Over
# ============================================================================

func _game_over():
	# Stop movement
	velocity = Vector2.ZERO
	set_physics_process(false)
	
	# Hide ship
	if has_node("ShipVisual"): $ShipVisual.hide()
	if has_node("ShipOutline"): $ShipOutline.hide()
	if has_node("TrailParticles"): $TrailParticles.emitting = false
	
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

	if has_node("../GameManager"):
		var game_manager = get_node("../GameManager")
		if game_manager:
			game_manager.end_game()
	else:
		# Fallback: reload scene directly (old behavior)
		get_tree().reload_current_scene()

# ============================================================================
# SIGNAL HANDLERS
# ============================================================================

func _on_game_started():
	if has_node("ShipVisual"): $ShipVisual.show()
	if has_node("ShipOutline"): $ShipOutline.show()
	set_physics_process(true)
	
	if has_node("TrailParticles"):
		$TrailParticles.emitting = true
		_on_multiplier_changed(false, 1.0)  # Reset color

func _on_multiplier_changed(active: bool, value: float):
	if not has_node("TrailParticles"): return
	
	var target_color = COLOR_NORMAL
	if active:
		if value >= 4.9:
			target_color = COLOR_PURPLE
		elif value >= 1.9:
			target_color = COLOR_GOLD
	
	# Update color ramp to fade from target color to transparent
	var gradient = $TrailParticles.color_ramp
	if gradient:
		gradient.set_color(0, target_color)
		gradient.set_color(1, Color(target_color.r, target_color.g, target_color.b, 0))
