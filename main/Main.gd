class_name Main
extends Node
# Head of the entire program, handling flow of control and UI.

var first_opened_app: bool = true

func _ready() -> void:
	%CircleInput.enter()
	
	first_opened_app = %SettingsMenu.settings_resource.first_opened_app
	%SettingsMenu.settings_resource.first_opened_app = false
	ResourceSaver.save(%SettingsMenu.settings_resource, "user://settings.tres")
	
	main()

# Main app loop.
func main():
	if first_opened_app:
		await %PhotosensitiveWarning.warn()
	else:
		await %PhotosensitiveWarning.fade()
	%PhotosensitiveWarning.visible = false
	while true:
		%BG.enter()
		# Wait until the singing bowl is vibrated to begin a session.
		await %CircleInput.resonance_threshold_reached
		
		%BG.exit()
		%WidgetContainer.enter()
		await %TitleMenu.exit_session_started()
		
		# Start taking samples for accelerometer/gyroscope
		%PhysiologySensor.start_detection()
		
		# Load settings from storage.
		var settings: UserSettings = %SettingsMenu.get_settings()
		
		# Update the fractal shader to the selected visual.
		%FractalNavigation.material.shader = %SingingBowl.preset_mappings[settings.bowl_type].fractal
		
		# Update the singing bowl sound files and other parameters
		%SingingBowl.configure(settings.bowl_type)
		
		# Undergo the actual session loop.
		%BiofeedbackLayer.start()
		await %SessionHandler.start_session(settings.session_duration, settings.volume)
		%BiofeedbackLayer.stop()
		%PhysiologySensor.stop_detection()
		
		# End of session sequence.
		await %EndLabel.enter()
		await get_tree().create_timer(5.0).timeout
		await %CircleInput.resonance_stopped
		await %EndLabel.exit()
		%WidgetContainer.exit()
		# Restart the loop, open the title menu.
		await %TitleMenu.enter_session_ended()

func reset() -> void:
	await %PhotosensitiveWarning.fade_in()
	
	get_tree().reload_current_scene.call_deferred()
