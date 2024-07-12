class_name TouchParticles
extends CPUParticles2D
# Script to control "smoke ring" particles.

var on: bool = false

func _input(event: InputEvent) -> void:
	if event is InputEventScreenDrag or event is InputEventScreenTouch:
		global_position = event.position

func _physics_process(_delta: float) -> void:
	if on:
		emitting = Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT)
