extends Resource
class_name ObstaclePattern

# Defines a single obstacle in the pattern
class ObstacleData:
	var y_position: float  # Vertical position (0-600)
	var x_offset: float    # Horizontal offset from spawn point
	var height: float      # Obstacle height
	
	func _init(y: float, x: float = 0.0, h: float = 80.0):
		y_position = y
		x_offset = x
		height = h

# Array of obstacles in this pattern
var obstacles: Array[ObstacleData] = []
var pattern_name: String = ""
var difficulty: int = 1  # 1=easy, 2=medium, 3=hard

func _init():
	obstacles = []
