extends StaticBody2D

@export var move_speed := 200

func _physics_process(delta):
	position.x -= move_speed * delta
