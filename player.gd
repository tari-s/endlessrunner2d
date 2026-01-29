extends CharacterBody2D

@export var move_speed := 350.0

func _physics_process(delta):
	velocity.x = 0
	velocity.y = 0

	if Input.is_action_pressed("ui_up"):
		velocity.y = -move_speed
	elif Input.is_action_pressed("ui_down"):
		velocity.y = move_speed

	move_and_slide()
	check_collisions()

func check_collisions():
	for i in range(get_slide_collision_count()):
		game_over()

func game_over():
	get_tree().reload_current_scene()
