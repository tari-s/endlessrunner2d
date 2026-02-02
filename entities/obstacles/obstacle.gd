extends StaticBody2D

@export var deadly := true  # Collision = Game Over
@export var moving := false
@export var speed := 250

var current_shape: ObstaclePattern.SHAPE = ObstaclePattern.SHAPE.RECTANGLE
var current_height: float = 80.0

func _ready():
	if has_node("/root/Game/GameManager"):
		var gm = get_node("/root/Game/GameManager")
		speed = gm.get_current_speed()

func _process(delta):
	if moving:
		position.x -= speed * delta
		if position.x < -100:
			queue_free()

func set_height(new_height: float):
	current_height = new_height
	update_shape()

func set_shape(new_shape: ObstaclePattern.SHAPE):
	current_shape = new_shape
	update_shape()

func update_shape():
	var points = PackedVector2Array()
	var half_h = current_height / 2.0
	var w = 40.0
	var half_w = w / 2.0
	
	match current_shape:
		ObstaclePattern.SHAPE.RECTANGLE:
			points = PackedVector2Array([
				Vector2(-half_w, -half_h),
				Vector2(half_w, -half_h),
				Vector2(half_w, half_h),
				Vector2(-half_w, half_h)
			])
		ObstaclePattern.SHAPE.TRIANGLE_UP:
			points = PackedVector2Array([
				Vector2(0, -half_h),
				Vector2(half_w, half_h),
				Vector2(-half_w, half_h)
			])
		ObstaclePattern.SHAPE.TRIANGLE_DOWN:
			points = PackedVector2Array([
				Vector2(-half_w, -half_h),
				Vector2(half_w, -half_h),
				Vector2(0, half_h)
			])
		ObstaclePattern.SHAPE.TRIANGLE_LEFT:
			points = PackedVector2Array([
				Vector2(-half_w, 0),
				Vector2(half_w, -half_h),
				Vector2(half_w, half_h)
			])
		ObstaclePattern.SHAPE.TRIANGLE_RIGHT:
			points = PackedVector2Array([
				Vector2(-half_w, -half_h),
				Vector2(half_w, 0),
				Vector2(-half_w, half_h)
			])
		ObstaclePattern.SHAPE.PENTAGON:
			points = PackedVector2Array([
				Vector2(0, -half_h),
				Vector2(half_w, -half_h * 0.2),
				Vector2(half_w * 0.6, half_h),
				Vector2(-half_w * 0.6, half_h),
				Vector2(-half_w, -half_h * 0.2)
			])
		ObstaclePattern.SHAPE.HEXAGON:
			points = PackedVector2Array([
				Vector2(0, -half_h),
				Vector2(half_w, -half_h * 0.5),
				Vector2(half_w, half_h * 0.5),
				Vector2(0, half_h),
				Vector2(-half_w, half_h * 0.5),
				Vector2(-half_w, -half_h * 0.5)
			])
		ObstaclePattern.SHAPE.TRAPEZOID_A: # Wide bottom
			points = PackedVector2Array([
				Vector2(-half_w * 0.5, -half_h),
				Vector2(half_w * 0.5, -half_h),
				Vector2(half_w, half_h),
				Vector2(-half_w, half_h)
			])
		ObstaclePattern.SHAPE.TRAPEZOID_B: # Wide top
			points = PackedVector2Array([
				Vector2(-half_w, -half_h),
				Vector2(half_w, -half_h),
				Vector2(half_w * 0.5, half_h),
				Vector2(-half_w * 0.5, half_h)
			])
		ObstaclePattern.SHAPE.IRREGULAR:
			# Dynamic random shape with 4-7 sides
			var side_count = randi_range(4, 7)
			for i in range(side_count):
				var angle = (PI * 2.0 / side_count) * i
				# Vary the radius for each point to make it irregular
				var r_w = half_w * randf_range(0.7, 1.3)
				var r_h = half_h * randf_range(0.7, 1.3)
				points.append(Vector2(cos(angle) * r_w, sin(angle) * r_h))
	
	if has_node("Polygon2D"):
		get_node("Polygon2D").polygon = points
		
	if has_node("CollisionPolygon2D"):
		get_node("CollisionPolygon2D").polygon = points
		
	if has_node("Border"):
		var border = get_node("Border")
		var border_points = points.duplicate()
		border_points.append(points[0]) # Close the loop
		border.points = border_points
