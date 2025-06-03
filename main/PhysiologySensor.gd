class_name PhysiologySensor 
extends Node

# Uses the gd-mobile-physiology addon to calculate heart and breath rate.
# Measures gyroscope and accelerometer samples.

@export var sample_size: int 

@export var kurtosis_cutoff_breathing: float = 0.0
@export var kurtosis_cutoff_heart: float = 0.0

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

var heart_rates: Array[float]
var breathing_rates: Array[float]
var timestamps: Array[float]

signal rates_updated(heart_rate: float, breathing_rate: float)

func _ready() -> void:
	set_physics_process(false)

func _physics_process(_delta: float) -> void:
	var accel: Vector3 = Input.get_accelerometer()
	var gyro: Vector3 = Input.get_gyroscope()
	
	if samples_taken < heart_sample_size:
		accelerometer_heart.append(accel)
		gyroscope_heart.append(gyro)
		
		%ReadingLabel.text = str(accel) + " " + str(gyro)
	
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
	if not %SettingsMenu.settings_resource.phys_readings:
		return
	
	var heart_info: Dictionary = HeartRateAlgorithm.Analyze(accelerometer_heart, gyroscope_heart, false)
	var breath_info: Dictionary = BreathingRateAlgorithm.Analyze(accelerometer_breath, gyroscope_breath, false)
	
	var heart_rate: float = heart_info["rate"]
	var breath_rate: float = breath_info["rate"]
	
	if not is_valid_reading(heart_info["kurtosis"], kurtosis_cutoff_heart) or not is_valid_reading(breath_info["kurtosis"], kurtosis_cutoff_breathing):
		rates_updated.emit(-1, -1)
	else:
		rates_updated.emit(heart_rate, breath_rate)
		
		if heart_rate > 0 and breath_rate > 0:
			heart_rates.append(heart_rate)
			breathing_rates.append(breath_rate)
			timestamps.append(Time.get_unix_time_from_system())
	
	print(heart_info, " ", breath_info, " ", timestamps[-1])

func start_detection() -> void:
	heart_rates = []
	breathing_rates = []
	timestamps = []
	timestamps.append(Time.get_unix_time_from_system())
	reset()
	set_physics_process(true)

func stop_detection() -> void:
	set_physics_process(false)
	timestamps.append(Time.get_unix_time_from_system())

# Resets current samples only, not history of HR/BR
func reset() -> void:
	heart_sample_size = HeartRateAlgorithm.GetActualSampleSize(sample_size)
	breathing_sample_size = BreathingRateAlgorithm.GetActualSampleSize(sample_size)
	max_sample_size = max(heart_sample_size, breathing_sample_size)
	
	samples_taken = 0
	
	accelerometer_heart = []
	gyroscope_heart = []
	accelerometer_breath = []
	gyroscope_breath = []

func is_valid_reading(kurtosis: float, cutoff: float) -> bool:
	return not is_nan(kurtosis) and not kurtosis < cutoff
