class_name BowlOption
extends ColorRect

signal pressed

var preset: BowlPreset
var selected: bool = false
var detecting_press: bool = false

func _ready() -> void:
	$Timer.timeout.connect(_on_timer_timeout)

func _on_timer_timeout() -> void:
	detecting_press = false

func _input(event: InputEvent) -> void:
	if event is InputEventScreenTouch and event.is_pressed() and not detecting_press:
		$Timer.start()
		detecting_press = true
	if event is InputEventScreenTouch and event.is_released() and is_visible_in_tree() and detecting_press:
		if get_global_rect().has_point(event.position):
			pressed.emit()

func initialize(preset: BowlPreset) -> void:
	self.preset = preset
	
	material = material.duplicate(true) # ShaderMaterials are otherwise shared across intances
	material.set_shader_parameter("color_top", preset.color_1)
	material.set_shader_parameter("color_bottom", preset.color_2)
	if not preset.color_3 == Color.BLACK: 
		material.set_shader_parameter("half_color", true)
		material.set_shader_parameter("color_top1", preset.color_3)
		material.set_shader_parameter("color_bottom1", preset.color_4)
	$Label.text = str(preset.frequency) + " Hz"
	
	# Random conversion so that higher frequency options have
	# more waves moving :) looks nice
	$CPUParticles2D.amount = 1 + int(preset.frequency / 128)
	%SelectedParticles.amount = 1 + int(preset.frequency / 300)

func set_selected(selected: bool) -> void:
	self.selected = selected
	%SelectedParticles.emitting = selected
