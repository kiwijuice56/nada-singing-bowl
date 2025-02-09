class_name EndMenu extends Menu

func _ready() -> void:
	super._ready()
	%ContinueButton.pressed.connect(_on_continue_pressed)

func _on_continue_pressed() -> void:
	await exit()
