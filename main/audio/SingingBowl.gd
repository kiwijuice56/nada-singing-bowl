class_name SingingBowl
extends Node
# Handles audio files to simulate a singing bowl being played.

# Uses three audio clips of a singing bowl fading in, sustaining, and fading out
# in volume and resonance.

@export var preset_mappings: Array[BowlPreset]
@export var transition: float
@export var resonance_transition: float

var tail_front: float 
var tail_end: float 
var volume_db: float = 0
var state: String = "trans_in"

func _ready() -> void:
	reset()

func reset() -> void:
	volume_db = 0
	for child in get_children():
		child.volume_db = -64
		child.playing = false

func configure(bowl_type: int) -> void:
	var sound_resource: BowlPreset = preset_mappings[bowl_type]
	tail_front = sound_resource.in_trim_length
	tail_end = sound_resource.end_trim_length
	%TransitionIn.stream = sound_resource.transition_in
	%TransitionOut.stream = sound_resource.transition_out
	%Sustain.stream = sound_resource.sustain

func update(resonance: float, time_elapsed: float, time_left: float, delta: float, volume_offset: float) -> void:
	if time_left < 0:
		%TransitionIn.volume_db = lerp(%TransitionIn.volume_db, -64.0, transition * delta)
		%Sustain.volume_db = lerp(%Sustain.volume_db, -64.0, transition * delta)
		%TransitionOut.volume_db = lerp(%TransitionOut.volume_db, -64.0, transition * delta)
		
		return
	
	volume_db = lerp(volume_db, -64 + 64 * resonance, delta * resonance_transition) 
	if time_elapsed < %TransitionIn.stream.get_length() - tail_front:
		state = "trans_in"
		if not %TransitionIn.playing:
			%TransitionIn.playing = true
		%TransitionIn.volume_db =  lerp(%TransitionIn.volume_db, volume_offset + volume_db, transition * delta * 4)
	elif time_left < %TransitionOut.stream.get_length() - tail_end:
		state = "trans_out"
		if not %TransitionOut.playing:
			%TransitionOut.playing = true
		%Sustain.volume_db = lerp(%Sustain.volume_db, -64.0, transition * delta)
		%TransitionOut.volume_db = lerp(%TransitionOut.volume_db, volume_offset + volume_db, transition * delta * 12)
	else:
		state = "sustain"
		if not %Sustain.playing:
			%Sustain.playing = true
		%TransitionIn.volume_db = lerp(%TransitionIn.volume_db, -64.0, transition * delta)
		%TransitionOut.volume_db = lerp(%TransitionOut.volume_db, -64.0, transition * delta)
		%Sustain.volume_db = lerp(%Sustain.volume_db, volume_offset + volume_db, transition * delta * 12)
