class_name ObstaclePattern

# Color Constants
const COLOR_DEADLY = Color(1.0, 0.3, 0.3)      # Red
const COLOR_SAFE = Color(0.2, 0.2, 0.2)        # Dark Grey (Environment)
const COLOR_MULTIPLIER = Color(0.9, 0.8, 0.2)  # Gold

# Defines a single obstacle in the pattern
class ObstacleData:
	var y_position: float  # Vertical position (0-600)
	var x_offset: float    # Horizontal offset from spawn point
	var height: float      # Obstacle height
	var deadly: bool       # Is it deadly?
	var color: Color       # Visual color
	var powerup_type: String = "" # Type of powerup if non-deadly
	
	func _init(y: float, x: float = 0.0, h: float = 80.0, is_deadly: bool = true, col: Color = COLOR_DEADLY, p_type: String = ""):
		y_position = y
		x_offset = x
		height = h
		deadly = is_deadly
		color = col
		powerup_type = p_type

# Array of obstacles in this pattern
var obstacles: Array[ObstacleData] = []
var pattern_name: String = ""
var difficulty: int = 1  # 1=easy, 2=medium, 3=hard

func _init():
	obstacles = []
