class_name FractalNavigation
extends ColorRect
# Updates the fractal shader (on this rect's ShaderMaterial) to dynamically 
# resize and zoom. 

# The fractal visual itself is coded using GLSL shaders, which are swapped out
# depending on what singing bowl type is selected.

# Each of these fractals are different, but they must have the following
# uniform variables:

# - color_intensity: [0.0, 1.0] The brightness of the fractal. 0.0
# should be entirely black so that it becomes invisible when the session ends.
# - scale: [0.25, 8.25] The zoom factor of the fractal, with 8.25 being the most
# zoomed out. Used to move in and out of the fractal throughout a session
# - time: [-0.34, 0.34] Constantly swings from the min amd max value as the
# session goes on. The fractal should animate cyclically based on this value.
# - audio1: [0.0, 1.0]: The volume of the audio playing in the app. Use this
# to make the fractal respons to the singing bowl.

# These uniform variables are synced by this script and SessionHandler.gd

# Set by SessionHandler.
var color_intensity: float = 0.0:
	set(val):
		color_intensity = val
		material.set_shader_parameter("color_intensity", min(resonance * resonance, sqrt(color_intensity)) * 0.85)

# Set by SessionHandler.
var resonance: float = 0.0

# Set by SessionHandler.
var spatial_progress: float = 0.0:
	set(val):
		spatial_progress = val
		material.set_shader_parameter("scale", 8.0 - spatial_progress * 8.0 + 0.25)
var real_time: float = 0

var spectrum: AudioEffectSpectrumAnalyzerInstance

func _ready() -> void:
	resized.connect(_on_resized)
	_on_resized()
	self.color_intensity = 0.0
	self.spatial_progress = 0.0
	
	spectrum = AudioServer.get_bus_effect_instance(0, 0)

func _on_resized() -> void:
	material.set_shader_parameter("aspect_ratio", size.x / size.y)

func advance_cycle(amount: float) -> void:
	# Update the sound-responsive parameter.
	var audio_strength: float = spectrum.get_magnitude_for_frequency_range(300, 1000).length()
	material.set_shader_parameter("audio1", audio_strength)
	material.set_shader_parameter("uv_offset", Vector2(0.0, 0.135))
	
	# Increase the time parameter. 
	real_time += amount * 0.35 # Slow the increase down a little so it isn't too harsh.
	
	# Bound the actual time parmaeter between two values that look nice.
	material.set_shader_parameter("time", cos(real_time) * 0.34)
