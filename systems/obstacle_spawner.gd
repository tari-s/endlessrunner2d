extends Node2D
class_name ObstacleSpawner

# ============================================================================
# EXPORTS
# ============================================================================

@export var obstacle_scene: PackedScene  # Assign obstacle.tscn in editor
@export var multiplier_scene: PackedScene  # Assign multiplier.tscn
@export var spawn_interval: float = 1.5  # Time between patterns
@export var spawn_x_position: float = 1300  # Where to spawn (off-screen right)
@export var initial_difficulty: int = 1
@export var min_gap: float = 200.0  # Baseline gap
@export var max_gap_shrink: float = 0.5  # Shrink to 50% of baseline

# ============================================================================
# PRIVATE VARIABLES
# ============================================================================

var _pattern_manager: PatternManager
var _spawn_timer: Timer
var _current_difficulty: int = 1

# ============================================================================
# LIFECYCLE METHODS
# ============================================================================

func _ready():
	# Create pattern manager
	_pattern_manager = PatternManager.new()
	add_child(_pattern_manager)
	
	# Setup spawn timer as a one-shot
	_spawn_timer = Timer.new()
	_spawn_timer.one_shot = true
	_spawn_timer.timeout.connect(_on_spawn_timer_timeout)
	add_child(_spawn_timer)
	
	# Start initial spawn
	_on_spawn_timer_timeout()
	
	_current_difficulty = initial_difficulty

# ============================================================================
# PUBLIC API
# ============================================================================

func set_spawn_interval(interval: float):
	spawn_interval = interval
	# Note: In the new one-shot system, this only affects the fallback wait_time

func pause_spawning():
	if _spawn_timer:
		_spawn_timer.stop()

func resume_spawning():
	if _spawn_timer:
		_spawn_timer.start(0.1)  # Shorter wait to resume immediately

# ============================================================================
# PRIVATE HELPERS - Spawning
# ============================================================================

func _on_spawn_timer_timeout():
	var wait_time = spawn_interval  # Fallback
	
	# Only spawn if game is playing
	if has_node("../GameManager"):
		var game_manager = get_node("../GameManager")
		if game_manager and game_manager.is_playing():
			var pattern_width = _spawn_pattern()
			
			var difficulty = game_manager.difficulty_factor
			var speed = game_manager.get_current_speed()
			
			# Scale gap based on difficulty
			var gap = min_gap * lerp(1.0, max_gap_shrink, difficulty)
			
			wait_time = (pattern_width + gap) / speed
			
			# Update complexity difficulty (1-3) based on factor
			if difficulty < 0.1:
				_current_difficulty = 1
			elif difficulty < 0.2:
				_current_difficulty = 2
			else:
				_current_difficulty = 3
	
	_spawn_timer.start(wait_time)

func _spawn_pattern() -> float:
	if obstacle_scene == null:
		push_error("ObstacleSpawner: obstacle_scene not assigned!")
		return 40.0
	
	# Get a random pattern based on current difficulty and powerup bias
	var powerup_bias = 0.0
	if has_node("../GameManager"):
		powerup_bias = get_node("../GameManager").difficulty_factor
		
	var pattern = _pattern_manager.get_random_pattern(_current_difficulty, powerup_bias)
	
	if pattern == null:
		return 40.0
	
	# Spawn each obstacle in the pattern
	for obstacle_data in pattern.obstacles:
		_spawn_obstacle(obstacle_data)
	
	return pattern.get_width()

func _spawn_obstacle(obstacle_data: ObstaclePattern.ObstacleData):
	var scene_to_spawn = obstacle_scene
	if obstacle_data.powerup_type.begins_with("multiplier") and multiplier_scene != null:
		scene_to_spawn = multiplier_scene
		
	var obstacle = scene_to_spawn.instantiate()
	
	# Position the obstacle
	obstacle.position.x = spawn_x_position + obstacle_data.x_offset
	obstacle.position.y = obstacle_data.y_position
	
	# Set obstacle properties
	_configure_obstacle_shape(obstacle, obstacle_data)
	_configure_obstacle_color(obstacle, obstacle_data)
	_configure_obstacle_properties(obstacle, obstacle_data)
	
	# Add to scene
	get_parent().add_child(obstacle)

func _configure_obstacle_shape(obstacle: Node, obstacle_data: ObstaclePattern.ObstacleData):
	if obstacle.has_method("set_shape"):
		obstacle.set_shape(obstacle_data.shape)
		
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
				collision.position.y = 0  # Center it precisely
				
		# Update Line2D Border if present in fallback
		if obstacle.has_node("Border"):
			var border = obstacle.get_node("Border")
			var half_h = obstacle_data.height / 2
			border.points = PackedVector2Array([
				Vector2(-20, -half_h),
				Vector2(20, -half_h),
				Vector2(20, half_h),
				Vector2(-20, half_h),
				Vector2(-20, -half_h)
			])

func _configure_obstacle_color(obstacle: Node, obstacle_data: ObstaclePattern.ObstacleData):
	# Set Color
	if obstacle.has_node("ColorRect"):
		obstacle.get_node("ColorRect").color = obstacle_data.color
	elif obstacle.has_node("Polygon2D"):
		obstacle.get_node("Polygon2D").color = obstacle_data.color
		
	# Set Border Color
	if obstacle.has_node("Border"):
		var border_color = ObstaclePattern.COLOR_DEADLY_BORDER
		if obstacle_data.powerup_type == "multiplier_5x":
			border_color = ObstaclePattern.COLOR_SUPER_MULTIPLIER_BORDER
		elif obstacle_data.powerup_type.begins_with("multiplier"):
			border_color = ObstaclePattern.COLOR_MULTIPLIER_BORDER
		elif obstacle_data.move_type == ObstaclePattern.MOVE_TYPE.OSCILLATING:
			border_color = ObstaclePattern.COLOR_OSCILLATING_BORDER
		elif obstacle_data.move_type != ObstaclePattern.MOVE_TYPE.NONE:
			border_color = ObstaclePattern.COLOR_MOVING_BORDER
		elif not obstacle_data.deadly:
			border_color = ObstaclePattern.COLOR_SAFE_BORDER
		
		obstacle.get_node("Border").default_color = border_color

func _configure_obstacle_properties(obstacle: Node, obstacle_data: ObstaclePattern.ObstacleData):
	# Set Deadly
	if "deadly" in obstacle:
		obstacle.deadly = obstacle_data.deadly
	
	# Set Powerup Type
	if "powerup_type" in obstacle:
		obstacle.powerup_type = obstacle_data.powerup_type
	
	# Enable movement
	if "moving" in obstacle:
		obstacle.moving = true
		
	# Set movement properties
	if "move_type" in obstacle:
		obstacle.move_type = obstacle_data.move_type
	if "move_speed" in obstacle:
		obstacle.move_speed = obstacle_data.move_speed
	if "move_range" in obstacle:
		obstacle.move_range = obstacle_data.move_range
