class_name SettingButton
extends Button
# The generated buttons in the settings menu

var description: String

func initialize(title: String, description: String, subtitle: String) -> void:
	text = title
	self.description = description
	$Label.text = subtitle
