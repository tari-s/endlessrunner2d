extends StaticBody2D

@export var deadly := false
@export var is_powerup := true
@export var powerup_type := "multiplier"
@export var moving := true
@export var speed := 250

func _ready():
	if has_node("/root/Game/GameManager"):
		var gm = get_node("/root/Game/GameManager")
		speed = gm.get_current_speed()

func _process(delta):
	if moving:
		position.x -= speed * delta
		if position.x < -100:
			queue_free()
