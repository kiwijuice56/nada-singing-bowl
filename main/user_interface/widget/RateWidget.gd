class_name RateWidget extends TextureRect

@export var sensor: PhysiologySensor
@export_enum("heart", "breath") var rate_type: String
@export var period_update_speed: float
@export var rate_ring_scene: PackedScene
@export var initial_period: float
@export var normal_modulate: Color
@export var no_reading_modulate: Color

var target_period: float
var period: float
var has_initial_reading: bool = false

signal hide_rings

func _ready() -> void:
	%RateTimer.timeout.connect(_on_period_complete)
	sensor.rates_updated.connect(_on_rates_updated)
	modulate = no_reading_modulate

func _on_period_complete() -> void:
	%RateTimer.start(period)
	%AnimationPlayer.speed_scale = 1.0 / period
	%AnimationPlayer.stop()
	%AnimationPlayer.play("beat")
	var new_ring: RateRing = rate_ring_scene.instantiate()
	hide_rings.connect(new_ring.stop)
	%Rings.add_child(new_ring)
	new_ring.global_position = global_position + size / 2
	new_ring.start()

func _on_rates_updated(heart_rate: float, breathing_rate: float) -> void:
	if not has_initial_reading:
		var tween: Tween = get_tree().create_tween()
		tween.tween_property(self, "modulate", normal_modulate, 0.5)
		has_initial_reading = true
	var target_rate: float
	if rate_type == "heart":
		target_rate = heart_rate
	else:
		target_rate = breathing_rate
	target_period = 1 / (target_rate / 60)

func _process(delta: float) -> void:
	period = lerp(period, target_period, delta * period_update_speed)

func start() -> void:
	period = initial_period
	target_period = initial_period
	%RateTimer.start(period)
	
	modulate = no_reading_modulate

func stop() -> void:
	has_initial_reading = false
	%RateTimer.stop()
	hide_rings.emit()
	
	var tween: Tween = get_tree().create_tween()
	tween.tween_property(self, "modulate", no_reading_modulate, 0.5)
