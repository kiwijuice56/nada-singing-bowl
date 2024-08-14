class_name RateRing extends Sprite2D

@export var decay_time: float = 48.0
@export var maximum_scale: float = 48.0
@export var initial_scale: float = 1.0

var tween: Tween

var animation_scale: float:
	set(val):
		animation_scale = val
		scale = (initial_scale + animation_scale * (maximum_scale - initial_scale)) * Vector2(1, 1)
		modulate.a = 0.95 - animation_scale

func start() -> void:
	tween = get_tree().create_tween()
	tween = tween.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_EXPO)
	tween.tween_property(self, "animation_scale", 1.0, decay_time)
	await tween.finished
	queue_free()

func stop() -> void:
	if is_instance_valid(tween):
		tween.stop()
	tween = get_tree().create_tween()
	tween.tween_property(self, "modulate:a", 0.0, 1.0)
	await tween.finished
	queue_free()
