class_name EndMenu extends Menu

func _ready() -> void:
	super._ready()
	%ContinueButton.pressed.connect(_on_continue_pressed)

func _on_continue_pressed() -> void:
	play_sound(audio2)
	await exit()

func initialize(show_plot: bool) -> void:
	%PlotContainer.visible = show_plot
	%EndLabel.visible = not show_plot
