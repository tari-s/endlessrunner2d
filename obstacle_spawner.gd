extends Node2D
class_name ObstacleSpawner

@export var obstacle_scene: PackedScene  # Assign obstacle.tscn in editor
@export var multiplier_scene: PackedScene # Assign multiplier.tscn
@export var spawn_interval: float = 2.5  # Time between patterns
@export var spawn_x_position: float = 1300  # Where to spawn (off-screen right)
@export var initial_difficulty: int = 1
@export var difficulty_increase_interval: float = 15.0  # Seconds until difficulty increases

var pattern_manager: PatternManager
var spawn_timer: Timer
var difficulty_timer: Timer
var current_difficulty: int = 1

func _ready():
	# Create pattern manager
	pattern_manager = PatternManager.new()
	add_child(pattern_manager)
	
	# Setup spawn timer
	spawn_timer = Timer.new()
	spawn_timer.wait_time = spawn_interval
	spawn_timer.timeout.connect(_on_spawn_timer_timeout)
	add_child(spawn_timer)
	spawn_timer.start()
	
	# Setup difficulty timer
	difficulty_timer = Timer.new()
	difficulty_timer.wait_time = difficulty_increase_interval
	difficulty_timer.timeout.connect(_on_difficulty_timer_timeout)
	add_child(difficulty_timer)
	difficulty_timer.start()
	
	current_difficulty = initial_difficulty

func _on_spawn_timer_timeout():
	# Only spawn if game is playing (check if GameManager exists)
	if has_node("../GameManager"):
		var game_manager = get_node("../GameManager")
		if game_manager and game_manager.is_playing():
			spawn_pattern()
	else:
		# If no GameManager, always spawn (old behavior)
		spawn_pattern()

func _on_difficulty_timer_timeout():
	if current_difficulty < 3:
		current_difficulty += 1
		print("Difficulty increased to: ", current_difficulty)

func spawn_pattern():
	if obstacle_scene == null:
		push_error("ObstacleSpawner: obstacle_scene not assigned!")
		return
	
	# Get a random pattern based on current difficulty
	var pattern = pattern_manager.get_random_pattern(current_difficulty)
	
	if pattern == null:
		return
	
	# Spawn each obstacle in the pattern
	for obstacle_data in pattern.obstacles:
		var scene_to_spawn = obstacle_scene
		if obstacle_data.powerup_type == "multiplier" and multiplier_scene != null:
			scene_to_spawn = multiplier_scene
			
		var obstacle = scene_to_spawn.instantiate()
		
		# Position the obstacle
		obstacle.position.x = spawn_x_position + obstacle_data.x_offset
		obstacle.position.y = obstacle_data.y_position
		
		# Set obstacle properties if it has them
		if obstacle.has_method("set_height"):
			obstacle.set_height(obstacle_data.height)
		elif obstacle.has_node("ColorRect"):
			var color_rect = obstacle.get_node("ColorRect")
			color_rect.size.y = obstacle_data.height
			color_rect.offset_bottom = obstacle_data.height
			# Update collision shape if present
			if obstacle.has_node("CollisionShape2D"):
				var collision = obstacle.get_node("CollisionShape2D")
				if collision.shape is RectangleShape2D:
					collision.shape.size.y = obstacle_data.height
					collision.position.y = obstacle_data.height / 2
					
		# Set Color
		if obstacle.has_node("ColorRect"):
			obstacle.get_node("ColorRect").color = obstacle_data.color
		elif obstacle.has_node("Polygon2D"):
			obstacle.get_node("Polygon2D").color = obstacle_data.color
			
		# Set Deadly
		if "deadly" in obstacle:
			obstacle.deadly = obstacle_data.deadly
		
		# Enable movement (check if property exists)
		if "moving" in obstacle:
			obstacle.moving = true
		
		# Add to scene
		get_parent().add_child(obstacle)

func set_spawn_interval(interval: float):
	spawn_interval = interval
	if spawn_timer:
		spawn_timer.wait_time = interval

func pause_spawning():
	if spawn_timer:
		spawn_timer.stop()

func resume_spawning():
	if spawn_timer:
		spawn_timer.start()
