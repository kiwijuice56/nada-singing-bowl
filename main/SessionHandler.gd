class_name SessionHandler
extends Node
# Sets up meditation sessions and manages the intensity of the audio + visuals.

var session: Session
var in_session: bool = false

signal session_completed

func start_session(length: float, volume_offset: float):
	session = Session.new()
	session.length = length
	session.time_elapsed = 0
	session.volume_offset = volume_offset
	
	%ProgressMoon.start()
	%SingingBowl.reset()
	
	in_session = true
	await session_completed
	in_session = false
	
	%ProgressMoon.stop()
	
	%TouchParticles.on = false
	%BowlParticles.emitting = false

static func normal_dist(x: float) -> float:
	var e: float = 2.71828
	return exp(-e * (e * (x - 0.5)) ** 2)

func plataeu_dist(x: float) -> float:
	var e: float = 2.71828
	return exp(-e * 0.002 * (e * (x - 0.5)) ** 32)

func _process(delta: float) -> void:
	if in_session and session.time_elapsed >= session.length:
		session_completed.emit()
		%CircleInput.toggle = false
	
	var resonance: float = %CircleInput.resonance
	
	var time_scale: float
	var intensity: float = SessionHandler.normal_dist(0)
	
	if in_session:
		if resonance < 0.08 and not %BackMenu.visible:
			%BackMenu.enter()
		if resonance > 0.08 and %BackMenu.visible:
			%BackMenu.exit()
		
		time_scale = session.time_elapsed / session.length
		intensity = SessionHandler.normal_dist(time_scale)
		
		# Update session data.
		if not (%CircleInput.using_finger and %SingingBowl.state == "sustain"):
			session.time_elapsed += delta
		
		%BowlParticles.emitting = resonance > 0.5
		%TouchParticles.on = resonance > 0.5
		
		%SingingBowl.update(resonance, session.time_elapsed, session.length - session.time_elapsed, delta, session.volume_offset)
		%ProgressMoon.progress = session.time_elapsed / session.length
		%FractalNavigation.spatial_progress = plataeu_dist(session.time_elapsed / session.length)
	else:
		if %BackMenu.visible:
			%BackMenu.exit()
		%TouchParticles.on = false
		
		%SingingBowl.update(0.0, 0.0, -1.0, delta, 0.0)
	# Advance fractal animation.
	%FractalNavigation.advance_cycle(resonance * delta)
	%FractalNavigation.resonance = resonance 
	%FractalNavigation.color_intensity = lerp(%FractalNavigation.color_intensity, intensity if in_session else 0.0, delta * 0.5) 
