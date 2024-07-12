class_name DustParticles
extends CPUParticles2D
# Script to control ambient dust particles.

func _ready() -> void:
	get_viewport().size_changed.connect(_on_resized)
	_on_resized()

# The dust particles should emit randomly from any position on the screen.
func _on_resized() -> void:
	var size: Vector2 = get_viewport_rect().size
	emission_rect_extents = size / 2
	position = size / 2
