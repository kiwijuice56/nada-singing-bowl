class_name PlotPoint
extends TextureRect

@export var heart_icon: Texture
@export var breathing_icon: Texture

enum { HEART, BREATHING }

func initialize(type: int, bpm: float) -> void:
	if type == HEART:
		texture = heart_icon
	else:
		texture = breathing_icon
	%Label.text = str(int(round(bpm)))
