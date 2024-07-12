class_name PhotosensitiveWarning
extends ColorRect

func _ready() -> void:
	modulate.a = 0.0
	visible = true

func warn() -> void:
	modulate.a = 1.0
	$Label.modulate.a = 0.0
	
	var tween: Tween = get_tree().create_tween()
	tween.tween_property($Label, "modulate:a", 1.0, 0.5)
	await tween.finished
	
	await get_tree().create_timer(3.0).timeout
	
	tween = get_tree().create_tween()
	tween.tween_property(self, "modulate:a", 0.0, 0.8)
	await tween.finished
	
	visible = false

func fade() -> void:
	visible = true
	modulate.a = 1.0
	$Label.modulate.a = 0.0
	
	var tween: Tween = get_tree().create_tween()
	tween.tween_property(self, "modulate:a", 0.0, 0.8)
	await tween.finished
	visible = false

func fade_in() -> void:
	modulate.a = 0.0
	visible = true
	
	var tween: Tween = get_tree().create_tween()
	tween.tween_property(self, "modulate:a", 1.0, 0.4)
	await tween.finished
	await get_tree().create_timer(0.5).timeout
