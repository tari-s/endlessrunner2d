extends Node2D

# ============================================================================
# LIFECYCLE METHODS
# ============================================================================

func _ready():
	if has_node("Sparks"):
		$Sparks.emitting = true
	
	# Wait for particles to finish then free
	await get_tree().create_timer(0.5, true, false, true).timeout
	queue_free()

# ============================================================================
# PUBLIC API
# ============================================================================

func set_color(new_color: Color):
	if has_node("Sparks"):
		$Sparks.color = new_color
