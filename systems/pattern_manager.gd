extends Node
class_name PatternManager

# ============================================================================
# PRIVATE VARIABLES
# ============================================================================

var _patterns: Array[ObstaclePattern] = []

# ============================================================================
# LIFECYCLE METHODS
# ============================================================================

func _ready():
	_create_patterns()

# ============================================================================
# PUBLIC API
# ============================================================================

func get_random_pattern(max_difficulty: int = 3, powerup_bias: float = 0.0) -> ObstaclePattern:
	# Filter patterns by difficulty
	var available = _patterns.filter(func(p): return p.difficulty <= max_difficulty)
	
	if available.is_empty():
		return _patterns[0]
	
	# Calculate weights
	var weights = []
	var total_weight = 0.0
	
	for pattern in available:
		var weight = 1.0
		# Increase weight if it's a power-up pattern and bias is high
		var has_powerup = false
		for obs in pattern.obstacles:
			if obs.powerup_type != "":
				has_powerup = true
				break
		
		if has_powerup:
			# Power-ups become much more likely as bias increases (0.0 to 1.0)
			# At bias=1.0, power-ups are 5x more likely
			weight += powerup_bias * 4.0
		
		weights.append(weight)
		total_weight += weight
	
	# Random selection based on weights
	var roll = randf() * total_weight
	var current_sum = 0.0
	for i in range(available.size()):
		current_sum += weights[i]
		if roll <= current_sum:
			return available[i]
	
	return available[randi() % available.size()]

func get_pattern_by_name(p_name: String) -> ObstaclePattern:
	for pattern in _patterns:
		if pattern.pattern_name == p_name:
			return pattern
	return null

func get_patterns_by_difficulty(difficulty: int) -> Array[ObstaclePattern]:
	var result: Array[ObstaclePattern] = []
	for pattern in _patterns:
		if pattern.difficulty == difficulty:
			result.append(pattern)
	return result

# ============================================================================
# PRIVATE HELPERS - Pattern Creation
# ============================================================================

func _create_patterns():
	_create_difficulty_1_patterns()
	_create_difficulty_2_patterns()
	_create_difficulty_3_patterns()

func _create_difficulty_1_patterns():
	# Pattern 1: Single Low Obstacle
	var pattern1 = ObstaclePattern.new()
	pattern1.pattern_name = "Low Single"
	pattern1.difficulty = 1
	_add_obs(pattern1, 500, 0.0, 80.0, true, ObstaclePattern.COLOR_DEADLY)
	_patterns.append(pattern1)
	
	# Pattern 2: Single High Obstacle
	var pattern2 = ObstaclePattern.new()
	pattern2.pattern_name = "High Single"
	pattern2.difficulty = 1
	_add_obs(pattern2, 100, 0.0, 80.0, true, ObstaclePattern.COLOR_DEADLY)
	_patterns.append(pattern2)
	
	# Pattern 3: Single Middle Obstacle
	var pattern3 = ObstaclePattern.new()
	pattern3.pattern_name = "Middle Single"
	pattern3.difficulty = 1
	_add_obs(pattern3, 300, 0.0, 80.0, true, ObstaclePattern.COLOR_DEADLY)
	_patterns.append(pattern3)
	
	# Pattern 9: Safe Single
	var pattern9 = ObstaclePattern.new()
	pattern9.pattern_name = "Safe Single"
	pattern9.difficulty = 1
	_add_obs(pattern9, 300, 0.0, 80.0, false, ObstaclePattern.COLOR_SAFE)
	_patterns.append(pattern9)

func _create_difficulty_2_patterns():
	# Pattern 4: Two Obstacles - Top and Bottom Gap
	var pattern4 = ObstaclePattern.new()
	pattern4.pattern_name = "Top-Bottom Gap"
	pattern4.difficulty = 2
	_add_obs(pattern4, 100, 0.0, 80.0, true, ObstaclePattern.COLOR_DEADLY)
	_add_obs(pattern4, 500, 0.0, 80.0, true, ObstaclePattern.COLOR_DEADLY)
	_patterns.append(pattern4)
	
	# Pattern 5: Staircase Up
	var pattern5 = ObstaclePattern.new()
	pattern5.pattern_name = "Staircase Up"
	pattern5.difficulty = 2
	_add_obs(pattern5, 450, 0.0, 80.0, true, ObstaclePattern.COLOR_DEADLY)
	_add_obs(pattern5, 350, 150.0, 80.0, true, ObstaclePattern.COLOR_DEADLY)
	_add_obs(pattern5, 250, 300.0, 80.0, true, ObstaclePattern.COLOR_DEADLY)
	_patterns.append(pattern5)
	
	# Pattern 6: Staircase Down
	var pattern6 = ObstaclePattern.new()
	pattern6.pattern_name = "Staircase Down"
	pattern6.difficulty = 2
	_add_obs(pattern6, 150, 0.0, 80.0, true, ObstaclePattern.COLOR_DEADLY)
	_add_obs(pattern6, 250, 150.0, 80.0, true, ObstaclePattern.COLOR_DEADLY)
	_add_obs(pattern6, 350, 300.0, 80.0, true, ObstaclePattern.COLOR_DEADLY)
	_patterns.append(pattern6)
	
	# Pattern 10: Safe Tunnel
	var pattern10 = ObstaclePattern.new()
	pattern10.pattern_name = "Safe Tunnel"
	pattern10.difficulty = 2
	_add_obs(pattern10, 150, 0.0, 120.0, false, ObstaclePattern.COLOR_SAFE)
	_add_obs(pattern10, 450, 0.0, 120.0, false, ObstaclePattern.COLOR_SAFE)
	_patterns.append(pattern10)

func _create_difficulty_3_patterns():
	# Pattern 7: Zigzag
	var pattern7 = ObstaclePattern.new()
	pattern7.pattern_name = "Zigzag"
	pattern7.difficulty = 3
	_add_obs(pattern7, 150, 0.0, 80.0, true, ObstaclePattern.COLOR_DEADLY)
	_add_obs(pattern7, 450, 120.0, 80.0, true, ObstaclePattern.COLOR_DEADLY)
	_add_obs(pattern7, 250, 240.0, 80.0, true, ObstaclePattern.COLOR_DEADLY)
	_patterns.append(pattern7)
	
	# Pattern 8: Narrow Corridor
	var pattern8 = ObstaclePattern.new()
	pattern8.pattern_name = "Narrow Corridor"
	pattern8.difficulty = 3
	_add_obs(pattern8, 100, 0.0, 120.0, true, ObstaclePattern.COLOR_DEADLY)
	_add_obs(pattern8, 450, 0.0, 120.0, true, ObstaclePattern.COLOR_DEADLY)
	_patterns.append(pattern8)

	# Pattern 11: Multiplier Intro
	var pattern11 = ObstaclePattern.new()
	pattern11.pattern_name = "Multiplier Intro"
	pattern11.difficulty = 3
	_add_obs(pattern11, 300, 0.0, 40.0, false, ObstaclePattern.COLOR_MULTIPLIER, "multiplier")
	_patterns.append(pattern11)
	
	# Pattern 12: Multiplier Challenge
	var pattern12 = ObstaclePattern.new()
	pattern12.pattern_name = "Multiplier Challenge"
	pattern12.difficulty = 3
	_add_obs(pattern12, 150, 0.0, 80.0, true, ObstaclePattern.COLOR_DEADLY)
	_add_obs(pattern12, 450, 0.0, 80.0, true, ObstaclePattern.COLOR_DEADLY)
	_add_obs(pattern12, 300, 150.0, 40.0, false, ObstaclePattern.COLOR_MULTIPLIER, "multiplier")
	_patterns.append(pattern12)

	# Pattern 13: Super Multiplier
	var pattern13 = ObstaclePattern.new()
	pattern13.pattern_name = "Super Multiplier"
	pattern13.difficulty = 3
	_add_obs(pattern13, 300, 0.0, 40.0, false, ObstaclePattern.COLOR_SUPER_MULTIPLIER, "multiplier_5x")
	_patterns.append(pattern13)
	
	# Pattern 14: Vertical Sentinel
	var pattern14 = ObstaclePattern.new()
	pattern14.pattern_name = "Vertical Sentinel"
	pattern14.difficulty = 3
	_add_moving_obs(pattern14, 300, 0.0, 60.0, ObstaclePattern.MOVE_TYPE.OSCILLATING, 150.0, 100.0)
	_patterns.append(pattern14)
	
	# Pattern 15: Crusher Row
	var pattern15 = ObstaclePattern.new()
	pattern15.pattern_name = "Crusher Row"
	pattern15.difficulty = 3
	_add_moving_obs(pattern15, 100, 0.0, 60.0, ObstaclePattern.MOVE_TYPE.TOP_TO_BOTTOM, 120.0, 150.0)
	_add_moving_obs(pattern15, 500, 0.0, 60.0, ObstaclePattern.MOVE_TYPE.BOTTOM_TO_TOP, 120.0, 150.0)
	_add_moving_obs(pattern15, 100, 300.0, 60.0, ObstaclePattern.MOVE_TYPE.TOP_TO_BOTTOM, 120.0, 150.0)
	_add_moving_obs(pattern15, 500, 300.0, 60.0, ObstaclePattern.MOVE_TYPE.BOTTOM_TO_TOP, 120.0, 150.0)
	_patterns.append(pattern15)
	
	# Pattern 16: Oscillating Wall
	var pattern16 = ObstaclePattern.new()
	pattern16.pattern_name = "Oscillating Wall"
	pattern16.difficulty = 3
	_add_moving_obs(pattern16, 200, 0.0, 80.0, ObstaclePattern.MOVE_TYPE.OSCILLATING, 100.0, 50.0)
	_add_moving_obs(pattern16, 400, 200.0, 80.0, ObstaclePattern.MOVE_TYPE.OSCILLATING, 100.0, 50.0)
	_add_moving_obs(pattern16, 200, 400.0, 80.0, ObstaclePattern.MOVE_TYPE.OSCILLATING, 100.0, 50.0)
	_patterns.append(pattern16)

func _add_obs(pattern: ObstaclePattern, y: float, x: float = 0.0, h: float = 80.0, is_deadly: bool = true, col: Color = ObstaclePattern.COLOR_DEADLY, p_type: String = ""):
	var shape = ObstaclePattern.SHAPE.RECTANGLE
	if p_type == "":  # Only randomize non-powerup obstacles
		shape = _get_random_shape()
	
	pattern.obstacles.append(ObstaclePattern.ObstacleData.new(y, x, h, is_deadly, col, p_type, shape))

func _add_moving_obs(pattern: ObstaclePattern, y: float, x: float = 0.0, h: float = 80.0, m_type: ObstaclePattern.MOVE_TYPE = ObstaclePattern.MOVE_TYPE.NONE, m_speed: float = 100.0, m_range: float = 150.0):
	var shape = ObstaclePattern.SHAPE.RECTANGLE
	var col = ObstaclePattern.COLOR_DEADLY
	
	match m_type:
		ObstaclePattern.MOVE_TYPE.TOP_TO_BOTTOM:
			shape = ObstaclePattern.SHAPE.TRIANGLE_DOWN
			col = ObstaclePattern.COLOR_MOVING
		ObstaclePattern.MOVE_TYPE.BOTTOM_TO_TOP:
			shape = ObstaclePattern.SHAPE.TRIANGLE_UP
			col = ObstaclePattern.COLOR_MOVING
		ObstaclePattern.MOVE_TYPE.OSCILLATING:
			shape = ObstaclePattern.SHAPE.HEXAGON
			col = ObstaclePattern.COLOR_OSCILLATING
	
	pattern.obstacles.append(ObstaclePattern.ObstacleData.new(y, x, h, true, col, "", shape, m_type, m_speed, m_range))

func _get_random_shape() -> ObstaclePattern.SHAPE:
	var shapes = [
		ObstaclePattern.SHAPE.RECTANGLE,
		ObstaclePattern.SHAPE.TRIANGLE_UP,
		ObstaclePattern.SHAPE.TRIANGLE_DOWN,
		ObstaclePattern.SHAPE.TRIANGLE_LEFT,
		ObstaclePattern.SHAPE.TRIANGLE_RIGHT,
		ObstaclePattern.SHAPE.PENTAGON,
		ObstaclePattern.SHAPE.HEXAGON,
		ObstaclePattern.SHAPE.TRAPEZOID_A,
		ObstaclePattern.SHAPE.TRAPEZOID_B,
		ObstaclePattern.SHAPE.IRREGULAR
	]
	return shapes[randi() % shapes.size()]
