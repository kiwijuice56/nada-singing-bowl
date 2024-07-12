class_name InfoMenu
extends Menu

func _ready() -> void:
	super._ready()
	%ExitButton.pressed.connect(_on_exit_pressed)

func _on_exit_pressed() -> void:
	await exit()
