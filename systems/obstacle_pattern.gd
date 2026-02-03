class_name ObstaclePattern

# ============================================================================
# CONSTANTS - Colors
# ============================================================================

const COLOR_DEADLY = Color(1.0, 0.3, 0.3)      # Red
const COLOR_SAFE = Color(0.2, 0.2, 0.2)        # Dark Grey (Environment)
const COLOR_MULTIPLIER = Color(0.9, 0.8, 0.2)  # Gold
const COLOR_SUPER_MULTIPLIER = Color(0.7, 0.2, 0.9)  # Purple
const COLOR_MOVING = Color(1.0, 0.5, 0.2)  # Orange/Red
const COLOR_OSCILLATING = Color(0.2, 0.8, 1.0)  # Cyan

const COLOR_DEADLY_BORDER = Color(0.5, 0.1, 0.1)
const COLOR_SAFE_BORDER = Color(0.05, 0.05, 0.05)
const COLOR_MULTIPLIER_BORDER = Color(0.5, 0.4, 0.1)
const COLOR_SUPER_MULTIPLIER_BORDER = Color(0.35, 0.1, 0.45)
const COLOR_PLAYER_BORDER = Color(0.2, 0.2, 0.5)
const COLOR_MOVING_BORDER = Color(0.6, 0.2, 0.0)
const COLOR_OSCILLATING_BORDER = Color(0.1, 0.4, 0.6)

# ============================================================================
# ENUMS
# ============================================================================

enum MOVE_TYPE {
	NONE,
	TOP_TO_BOTTOM,
	BOTTOM_TO_TOP,
	OSCILLATING
}

enum SHAPE {
	RECTANGLE,
	TRIANGLE_UP,
	TRIANGLE_DOWN,
	TRIANGLE_LEFT,
	TRIANGLE_RIGHT,
	PENTAGON,
	HEXAGON,
	TRAPEZOID_A,  # Wide bottom
	TRAPEZOID_B,  # Wide top
	IRREGULAR
}

# ============================================================================
# PUBLIC VARIABLES
# ============================================================================

var obstacles: Array[ObstacleData] = []
var pattern_name: String = ""
var difficulty: int = 1  # 1=easy, 2=medium, 3=hard

# ============================================================================
# NESTED CLASS - ObstacleData
# ============================================================================

class ObstacleData:
	var y_position: float  # Vertical position (0-600)
	var x_offset: float    # Horizontal offset from spawn point
	var height: float      # Obstacle height
	var deadly: bool       # Is it deadly?
	var color: Color       # Visual color
	var powerup_type: String = ""  # Type of powerup if non-deadly
	var shape: SHAPE = SHAPE.RECTANGLE
	var move_type: MOVE_TYPE = MOVE_TYPE.NONE
	var move_speed: float = 100.0
	var move_range: float = 150.0  # Total travel distance or oscillation amplitude
	
	func _init(y: float, x: float = 0.0, h: float = 80.0, is_deadly: bool = true, col: Color = COLOR_DEADLY, p_type: String = "", s: SHAPE = SHAPE.RECTANGLE, m_type: MOVE_TYPE = MOVE_TYPE.NONE, m_speed: float = 100.0, m_range: float = 150.0):
		y_position = y
		x_offset = x
		height = h
		deadly = is_deadly
		color = col
		powerup_type = p_type
		shape = s
		move_type = m_type
		move_speed = m_speed
		move_range = m_range

# ============================================================================
# LIFECYCLE METHODS
# ============================================================================

func _init():
	obstacles = []

# ============================================================================
# PUBLIC API
# ============================================================================

func get_width() -> float:
	var max_x = 40.0  # Minimum width for a single obstacle
	for obs in obstacles:
		if obs.x_offset + 40.0 > max_x:
			max_x = obs.x_offset + 40.0
	return max_x
