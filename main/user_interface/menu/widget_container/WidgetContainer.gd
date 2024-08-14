class_name WidgetContainer extends Menu

func enter() -> void:
	await super.enter()
	for child in get_children():
		child.start()

func exit() -> void:
	await super.exit()
	for child in get_children():
		child.stop()
