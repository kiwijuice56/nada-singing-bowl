class_name Ambiance
extends Menu
# Controls ambient rays of light and dust in the title screen.

## The color of the "god rays."
@export var base_light: Color = Color("#ffffff1c")

# Modulate has no effect on shader materials, so we need a custom variable
# to change the color of the light rays when we are fading the ambiance
# in or out.
var true_alpha: float = 0.0:
	set(val):
		true_alpha = val
		
		var new_color: Color = base_light
		new_color.a *= val
		material.set_shader_parameter("color", new_color)
		
		modulate.a = val

func enter() -> void:
	visible = true
	var tween: Tween = get_tree().create_tween()
	tween.tween_property(self, "true_alpha", 1.0, transition_time)
	await tween.finished
	entered.emit()

func exit() -> void:
	visible = true
	var tween: Tween = get_tree().create_tween()
	tween.tween_property(self, "true_alpha", 0.0, transition_time)
	await tween.finished
	entered.emit()
