class_name SettingsMenu
extends Menu

var settings_resource: UserSettings

func _ready() -> void:
	super._ready()
	
	if ResourceLoader.exists("user://settings.tres"):
		var version: String = ProjectSettings.get_setting("application/config/version")
		settings_resource = ResourceLoader.load("user://settings.tres") 
		if not "version" in settings_resource or settings_resource.version != version:
			settings_resource = preload("res://main/user_settings/default_settings.tres")
	else:
		settings_resource = preload("res://main/user_settings/default_settings.tres")
	
	settings_resource.version = ProjectSettings.get_setting("application/config/version")
	
	%DurationSlider.value_changed.connect(_on_duration_changed)
	%ExitButton.pressed.connect(_on_exit_pressed)
	
	load_settings(settings_resource)

func _on_duration_changed(duration: int) -> void:
	var minutes: int = floor(duration / 60.0)
	var seconds: int = duration - minutes * 60
	%TimeLabel.text = "%d:%02d" % [minutes, seconds]

func _on_exit_pressed() -> void:
	await exit()

func enter() -> void:
	load_settings(settings_resource)
	super.enter()

func exit() -> void:
	save_settings()
	super.exit()

func get_settings() -> UserSettings:
	return settings_resource

# Place stored values into UI components.
func load_settings(settings: UserSettings):
	%DurationSlider.value = settings.session_duration
	_on_duration_changed(settings.session_duration)
	%VolumeSlider.value = settings.volume
	%BowlSelector.index = settings.bowl_type

# Save values from UI components onto storage.
func save_settings():
	settings_resource.session_duration = %DurationSlider.value 
	settings_resource.volume = %VolumeSlider.value 
	settings_resource.bowl_type = %BowlSelector.index
	
	ResourceSaver.save(settings_resource, "user://settings.tres")


func choice_selected(parent: Container, selected_index: int) -> void:
	for i in range(parent.get_child_count()):
		parent.get_child(i).button_pressed = i == selected_index
		if parent == %SoundTypeContainer and i == selected_index:
			%SoundDescriptionLabel.text = parent.get_child(i).description
