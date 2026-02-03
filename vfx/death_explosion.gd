extends Node2D

# ============================================================================
# LIFECYCLE METHODS
# ============================================================================

func _ready():
	# Start all particle systems
	for child in get_children():
		if child is CPUParticles2D:
			child.emitting = true
	
	# Wait for smoke (longest lifetime) to finish
	# Use a timer that works even when paused
	await get_tree().create_timer(1.2, true, false, true).timeout
	queue_free()
