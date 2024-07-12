class_name TitleMenu
extends Menu

func _ready() -> void:
	%InfoButton.pressed.connect(_on_info_button_pressed)
	%SettingsButton.pressed.connect(_on_settings_button_pressed)
	%HelpButton.pressed.connect(_on_help_button_pressed)
	get_parent().get_node("%SettingsMenu").exited.connect(_on_submenu_exited)
	get_parent().get_node("%InfoMenu").exited.connect(_on_submenu_exited)
	get_parent().get_node("%HelpMenu").exited.connect(_on_submenu_exited)
	get_parent().get_node("%Ambiance").enter()

func _on_submenu_exited() -> void:
	await get_parent().get_node("%BackgroundPanel").exit()
	await enter(true)

func _on_info_button_pressed() -> void:
	await exit(true)
	await get_parent().get_node("%BackgroundPanel").enter()
	await get_parent().get_node("%InfoMenu").enter()

func _on_settings_button_pressed() -> void:
	await exit()
	await get_parent().get_node("%BackgroundPanel").enter()
	await get_parent().get_node("%SettingsMenu").enter()

func _on_help_button_pressed() -> void:
	await exit(true)
	await get_parent().get_node("%BackgroundPanel").enter()
	await get_parent().get_node("%HelpMenu").enter()

# Show this menu.
func enter(show_circle_input: bool = false) -> void:
	play_sound(audio2)
	get_parent().get_node("%CircleInput").enter(show_circle_input)
	visible = true
	var tween: Tween = get_tree().create_tween()
	tween.tween_property(self, "modulate:a", 1.0, transition_time)
	await tween.finished
	entered.emit()

# Hide this menu.
func exit(hide_circle_input: bool = false) -> void:
	play_sound(audio1)
	
	get_parent().get_node("%CircleInput").exit(hide_circle_input)
	var tween: Tween = get_tree().create_tween()
	tween.tween_property(self, "modulate:a", 0.0, transition_time)
	await tween.finished
	visible = false
	exited.emit()

# Slightly different scenario, we now do not want to hide the CircleInput
func exit_session_started() -> void:
	get_parent().get_node("%Ambiance").exit()
	
	var tween: Tween = get_tree().create_tween()
	tween.tween_property(self, "modulate:a", 0.0, transition_time)
	await tween.finished
	visible = false
	exited.emit()

func enter_session_ended() -> void:
	get_parent().get_node("%Ambiance").enter()
	
	var tween: Tween = get_tree().create_tween()
	tween.tween_property(self, "modulate:a", 1.0, transition_time)
	await tween.finished
	visible = true
	exited.emit()
