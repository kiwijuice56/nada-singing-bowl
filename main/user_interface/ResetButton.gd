class_name ResetButton
extends Button


func _ready() -> void:
	pressed.connect(get_tree().get_root().get_node("Main").reset)
