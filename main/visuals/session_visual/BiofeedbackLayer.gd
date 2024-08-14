class_name BiofeedbackLayer extends ColorRect

@export var offset_count: int = 0
@export var max_heart_rate_delta: float = 0.0
@export var max_breathing_rate_delta: float = 0.0
@export var relaxation_gradient: GradientTexture1D

@onready var output: Gradient = material.get_shader_parameter("color_gradient").gradient
@onready var data: PhysiologySensor = %PhysiologySensor

var animation_time: float
var relaxation_scores: Array[float] = []
var progress: float = 0:
	set(val):
		progress = val
		reset_points()
var tween: Tween
var animating: bool = false

var initial_heart_rate: float 
var initial_breathing_rate: float 
var initial_sample: bool = true

func _ready() -> void:
	data.rates_updated.connect(_rates_updated)

func _rates_updated(heart_rate: float, breathing_rate: float) -> void:
	if not animating:
		return
	
	if initial_sample:
		initial_heart_rate = heart_rate
		initial_breathing_rate = breathing_rate
		initial_sample = false
		return
	
	# Stop any lagging animations.
	if is_instance_valid(tween) and tween.is_running():
		tween.kill()
	
	relaxation_scores.insert(0, relaxation_heuristic(heart_rate, breathing_rate))
	if len(relaxation_scores) >= offset_count:
		relaxation_scores.pop_back()
	
	progress_points()

func start() -> void:
	relaxation_scores = []
	animation_time = data.max_sample_size / 60.0
	animating = true
	initial_sample = true
	
	# Fill in the amount of points needed.
	while output.get_point_count() < offset_count:
		output.add_point(0, Color(1, 1, 1, 0))
	
	reset_points()

func stop() -> void:
	animating = false

func progress_points() -> void:
	progress = 0
	tween = get_tree().create_tween()
	tween.tween_property(self, "progress", 1, animation_time)

func reset_points() -> void:
	# Update point offset and color.
	for i in range(offset_count):
		if i >= len(relaxation_scores):
			output.set_color(i, Color(1, 1, 1, 0))
		else:
			output.set_color(i, relaxation_gradient.gradient.sample(relaxation_scores[i]))
		if i == 0:
			output.set_offset(i, 0)
		else:
			output.set_offset(i, (i + progress - 1) / offset_count)

func relaxation_heuristic(heart_rate: float, breathing_rate: float) -> float:
	var relaxation_heart: float = 0.5 + clamp((initial_heart_rate - heart_rate) / max_heart_rate_delta, -1, 1) * 0.5
	var relaxation_breathing: float = 0.5 + clamp((initial_breathing_rate - breathing_rate) / max_breathing_rate_delta, -1, 1) * 0.5
	return (relaxation_heart + relaxation_breathing) / 2.0
