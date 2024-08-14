class_name PhysiologySensor 
extends Node

# Uses the gd-mobile-physiology addon to calculate heart and breath rate.
# Measures gyroscope and accelerometer samples.

@export var sample_size: int 

# The heart/breath arrays hold much of the same values, but usually have slightly different
# sample sizes; We could store this data in two arrays and then slice them before analyzing,
# but performance is more important than memory.
var accelerometer_heart: Array[Vector3]
var gyroscope_heart: Array[Vector3]
var accelerometer_breath: Array[Vector3]
var gyroscope_breath: Array[Vector3]

var heart_sample_size: int
var breathing_sample_size: int
var max_sample_size: int
var samples_taken: int = 0

signal rates_updated(heart_rate: float, breathing_rate: float)

func _ready() -> void:
	set_physics_process(false)

func _physics_process(_delta: float) -> void:
	var accel: Vector3 = Input.get_accelerometer()
	var gyro: Vector3 = Input.get_gyroscope()
	
	if samples_taken < heart_sample_size:
		accelerometer_heart.append(accel)
		gyroscope_heart.append(gyro)
	
	if samples_taken < breathing_sample_size:
		accelerometer_breath.append(accel)
		gyroscope_breath.append(gyro)
	
	samples_taken += 1
	
	# Wait until we've collected enough samples for both heart and breathing rates.
	# Calculating them at the same time is important, as stutters create artifacts
	# in the data.
	if samples_taken == max_sample_size:
		calculate_rates()
		reset()

func calculate_rates() -> void:
	var heart_rate_bpm: float = HeartRateAlgorithm.Analyze(accelerometer_heart, gyroscope_heart, false, {}, true)
	var breath_rate_bpm: float = BreathingRateAlgorithm.Analyze(accelerometer_breath, gyroscope_breath, false, {}, true)
	rates_updated.emit(heart_rate_bpm, breath_rate_bpm)
	
	print(heart_rate_bpm, " ", breath_rate_bpm)

func start_detection() -> void:
	reset()
	set_physics_process(true)

func stop_detection() -> void:
	set_physics_process(false)

func reset() -> void:
	heart_sample_size = HeartRateAlgorithm.GetActualSampleSize(sample_size)
	breathing_sample_size = BreathingRateAlgorithm.GetActualSampleSize(sample_size)
	max_sample_size = max(heart_sample_size, breathing_sample_size)
	
	samples_taken = 0
	
	accelerometer_heart = []
	gyroscope_heart = []
	accelerometer_breath = []
	gyroscope_breath = []
