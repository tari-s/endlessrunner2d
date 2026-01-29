extends StaticBody2D

@export var deadly := true  # Collision = Game Over
@export var moving := false
@export var speed := 250

func _process(delta):
	if moving:
		position.x -= speed * delta
		if position.x < -100:
			queue_free()

func set_height(new_height: float):
	# Update ColorRect if it exists
	if has_node("ColorRect"):
		var color_rect = get_node("ColorRect")
		color_rect.custom_minimum_size.y = new_height
		color_rect.size.y = new_height
		color_rect.offset_bottom = new_height
		color_rect.offset_top = -new_height / 2
		color_rect.offset_bottom = new_height / 2
	
	# Update CollisionShape2D if it exists
	if has_node("CollisionShape2D"):
		var collision = get_node("CollisionShape2D")
		if collision.shape is RectangleShape2D:
			collision.shape.size.y = new_height
			collision.position.y = 0  # Center it
