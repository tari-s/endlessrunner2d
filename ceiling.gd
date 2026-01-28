extends StaticBody2D

@export var height := 40
@export var color := Color.DIM_GRAY

func _ready():
	setup_ceiling()

func setup_ceiling():
	var screen_size = get_viewport_rect().size

	# Sichtbare Fläche
	$ColorRect.size = Vector2(screen_size.x, height)
	$ColorRect.color = color

	# Kollision (immer neu erzeugen!)
	var rect_shape := RectangleShape2D.new()
	rect_shape.size = Vector2(screen_size.x, height)
	$CollisionShape2D.shape = rect_shape

	# Position oben
	position = Vector2(0, 0)
