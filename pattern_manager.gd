extends Node
class_name PatternManager

# Store all available patterns
var patterns: Array[ObstaclePattern] = []
var current_difficulty: int = 1

func _ready():
	_create_patterns()

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

func _add_obs(pattern: ObstaclePattern, y: float, x: float = 0.0, h: float = 80.0, is_deadly: bool = true, col: Color = ObstaclePattern.COLOR_DEADLY, p_type: String = ""):
	var shape = ObstaclePattern.SHAPE.RECTANGLE
	if p_type == "": # Only randomize non-powerup obstacles
		shape = _get_random_shape()
	
	pattern.obstacles.append(ObstaclePattern.ObstacleData.new(y, x, h, is_deadly, col, p_type, shape))

func _create_patterns():
	# Pattern 1: Single Low Obstacle
	var pattern1 = ObstaclePattern.new()
	pattern1.pattern_name = "Low Single"
	pattern1.difficulty = 1
	_add_obs(pattern1, 400, 0.0, 80.0, true, ObstaclePattern.COLOR_DEADLY)
	patterns.append(pattern1)
	
	# Pattern 2: Single High Obstacle
	var pattern2 = ObstaclePattern.new()
	pattern2.pattern_name = "High Single"
	pattern2.difficulty = 1
	_add_obs(pattern2, 200, 0.0, 80.0, true, ObstaclePattern.COLOR_DEADLY)
	patterns.append(pattern2)
	
	# Pattern 3: Single Middle Obstacle
	var pattern3 = ObstaclePattern.new()
	pattern3.pattern_name = "Middle Single"
	pattern3.difficulty = 1
	_add_obs(pattern3, 300, 0.0, 80.0, true, ObstaclePattern.COLOR_DEADLY)
	patterns.append(pattern3)
	
	# Pattern 4: Two Obstacles - Top and Bottom Gap
	var pattern4 = ObstaclePattern.new()
	pattern4.pattern_name = "Top-Bottom Gap"
	pattern4.difficulty = 2
	_add_obs(pattern4, 120, 0.0, 80.0, true, ObstaclePattern.COLOR_DEADLY)
	_add_obs(pattern4, 480, 0.0, 80.0, true, ObstaclePattern.COLOR_DEADLY)
	patterns.append(pattern4)
	
	# Pattern 5: Staircase Up
	var pattern5 = ObstaclePattern.new()
	pattern5.pattern_name = "Staircase Up"
	pattern5.difficulty = 2
	_add_obs(pattern5, 450, 0.0, 80.0, true, ObstaclePattern.COLOR_DEADLY)
	_add_obs(pattern5, 350, 150.0, 80.0, true, ObstaclePattern.COLOR_DEADLY)
	_add_obs(pattern5, 250, 300.0, 80.0, true, ObstaclePattern.COLOR_DEADLY)
	patterns.append(pattern5)
	
	# Pattern 6: Staircase Down
	var pattern6 = ObstaclePattern.new()
	pattern6.pattern_name = "Staircase Down"
	pattern6.difficulty = 2
	_add_obs(pattern6, 150, 0.0, 80.0, true, ObstaclePattern.COLOR_DEADLY)
	_add_obs(pattern6, 250, 150.0, 80.0, true, ObstaclePattern.COLOR_DEADLY)
	_add_obs(pattern6, 350, 300.0, 80.0, true, ObstaclePattern.COLOR_DEADLY)
	patterns.append(pattern6)
	
	# Pattern 7: Zigzag
	var pattern7 = ObstaclePattern.new()
	pattern7.pattern_name = "Zigzag"
	pattern7.difficulty = 3
	_add_obs(pattern7, 150, 0.0, 80.0, true, ObstaclePattern.COLOR_DEADLY)
	_add_obs(pattern7, 450, 120.0, 80.0, true, ObstaclePattern.COLOR_DEADLY)
	_add_obs(pattern7, 250, 240.0, 80.0, true, ObstaclePattern.COLOR_DEADLY)
	patterns.append(pattern7)
	
	# Pattern 8: Narrow Corridor
	var pattern8 = ObstaclePattern.new()
	pattern8.pattern_name = "Narrow Corridor"
	pattern8.difficulty = 3
	_add_obs(pattern8, 100, 0.0, 120.0, true, ObstaclePattern.COLOR_DEADLY)
	_add_obs(pattern8, 440, 0.0, 120.0, true, ObstaclePattern.COLOR_DEADLY)
	patterns.append(pattern8)

	# Pattern 9: Safe Single
	var pattern9 = ObstaclePattern.new()
	pattern9.pattern_name = "Safe Single"
	pattern9.difficulty = 1
	_add_obs(pattern9, 300, 0.0, 80.0, false, ObstaclePattern.COLOR_SAFE)
	patterns.append(pattern9)
	
	# Pattern 10: Safe Tunnel
	var pattern10 = ObstaclePattern.new()
	pattern10.pattern_name = "Safe Tunnel"
	pattern10.difficulty = 2
	_add_obs(pattern10, 100, 0.0, 120.0, false, ObstaclePattern.COLOR_SAFE)
	_add_obs(pattern10, 440, 0.0, 120.0, false, ObstaclePattern.COLOR_SAFE)
	patterns.append(pattern10)

	# Pattern 11: Multiplier Intro (Difficulty 3)
	var pattern11 = ObstaclePattern.new()
	pattern11.pattern_name = "Multiplier Intro"
	pattern11.difficulty = 3
	_add_obs(pattern11, 300, 0.0, 40.0, false, ObstaclePattern.COLOR_MULTIPLIER, "multiplier")
	patterns.append(pattern11)
	
	# Pattern 12: Multiplier Challenge (Difficulty 3)
	var pattern12 = ObstaclePattern.new()
	pattern12.pattern_name = "Multiplier Challenge"
	pattern12.difficulty = 3
	_add_obs(pattern12, 150, 0.0, 80.0, true, ObstaclePattern.COLOR_DEADLY)
	_add_obs(pattern12, 450, 0.0, 80.0, true, ObstaclePattern.COLOR_DEADLY)
	_add_obs(pattern12, 300, 150.0, 40.0, false, ObstaclePattern.COLOR_MULTIPLIER, "multiplier")
	patterns.append(pattern12)

func get_random_pattern(max_difficulty: int = 3) -> ObstaclePattern:
	# Filter patterns by difficulty
	var available = patterns.filter(func(p): return p.difficulty <= max_difficulty)
	
	if available.is_empty():
		return patterns[0]  # Fallback to first pattern
	
	return available[randi() % available.size()]

func get_pattern_by_name(name: String) -> ObstaclePattern:
	for pattern in patterns:
		if pattern.pattern_name == name:
			return pattern
	return null

func get_patterns_by_difficulty(difficulty: int) -> Array[ObstaclePattern]:
	var result: Array[ObstaclePattern] = []
	for pattern in patterns:
		if pattern.difficulty == difficulty:
			result.append(pattern)
	return result
