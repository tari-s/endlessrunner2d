extends CharacterBody2D
@export var speed := 200
@export var vertical_speed := 300
@export var player_size := Vector2(40, 40)
@export var margin := 40

var is_dead := false

func _ready():
	setup_player()

func setup_player():
	var screen_size = get_viewport_rect().size

	# Position
	position = Vector2(
		100,
		screen_size.y / 2
	)

	# Visuelle Größe
	$Body.size = player_size
	$Body.color = Color.DODGER_BLUE

	# Kollision (explizit setzen)
	var rect_shape := RectangleShape2D.new()
	rect_shape.size = player_size
	$CollisionShape2D.shape = rect_shape

func clamp_to_play_area():
	var screen_size = get_viewport_rect().size
	var half_height = player_size.y / 2

	var top_limit = margin + half_height
	var bottom_limit = screen_size.y - margin - half_height

	position.y = clamp(position.y, top_limit, bottom_limit)

func _physics_process(delta):
	if is_dead:
		return
	velocity.x = speed

	if Input.is_action_pressed("ui_up"):
		velocity.y = -vertical_speed
	elif Input.is_action_pressed("ui_down"):
		velocity.y = vertical_speed
	else:
		velocity.y = 0

	move_and_slide()
	clamp_to_play_area()
	check_collision()

func check_collision():
	for i in range(get_slide_collision_count()):
		var collision = get_slide_collision(i)
		if collision.get_collider() is StaticBody2D:
			die()
func _input(event):
	if is_dead and event.is_action_pressed("ui_accept"):
		get_tree().reload_current_scene()

func die():
	is_dead = true
	velocity = Vector2.ZERO
	print("Game Over")
