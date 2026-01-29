extends StaticBody2D

@export var deadly := true  # Kollision = Game Over
@export var moving := false
@export var speed := 200.0

func _process(delta):
	if moving:
		position.x -= speed * delta
		if position.x < -100:
			queue_free()
