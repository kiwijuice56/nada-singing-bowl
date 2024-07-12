class_name BowlSelector
extends Control

# Very hacky way of changing background color with selected bowl!
@onready var hue_hint_bg: ColorRect = get_tree().get_root().get_node("Main").get_node("%HueHint")

@export var bowl_option_scene: PackedScene
@export var vertical_offset: float = 390.0
@export var radius_increase: float = 128.0
@export var swing_length: float = 190.0
@export var drag_speed: float = 6.0
@export var reset_speed: float = 4.0
@export var response_speed: float = 8.0
@export var hue_change_speed: float = 3.0
@export var drag_width: float = 142.0

var index: int = 0
var sub_index: float = 0
var angle_offset: float = 0

var drag_start: Vector2
var drag_end: Vector2 
var dragging: bool = false

func _ready() -> void:
	# Create buttons from the presets available.
	for preset in get_tree().get_root().get_node("Main/SingingBowl").preset_mappings:
		var new_option: BowlOption = bowl_option_scene.instantiate()
		new_option.pressed.connect(_on_option_pressed.bind(new_option))
		add_child(new_option)
		new_option.initialize(preset)
	move_child(get_child(0), -1) # Move internal nodes to the end.
	
	# Select initial options.
	update_selected.call_deferred(-1)

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_left", false):
		index -= 1
	if event.is_action_pressed("ui_right", false):
		index += 1
	
	if event is InputEventScreenTouch:
		drag_start = event.position
		if event.is_released():
			dragging = false
	if event is InputEventScreenDrag and in_bounds(event.position) and in_bounds(drag_start):
		drag_end = event.position
		dragging = true

func _physics_process(delta: float) -> void:
	hue_hint_bg.color = lerp(hue_hint_bg.color, get_child(index).preset.color_1, delta * hue_change_speed)
	get_tree().get_root().get_node("Main/%BG").color = hue_hint_bg.color.darkened(0.8)
	
	var old_index: int = index
	
	if dragging:
		var velocity: Vector2 = (drag_end - drag_start)
		sub_index = lerp(sub_index, velocity.x / swing_length, delta * drag_speed)
		if sub_index > 1 or sub_index < -1:
			index += round(sub_index)
			sub_index = 0
			drag_start = drag_end
	else:
		sub_index = lerp(sub_index, 0.0, delta * reset_speed)
	
	if old_index != index:
		if index >= get_child_count() - 1:
			index = 0
		if index < 0:
			index = get_child_count() - 2
		update_selected(old_index)
	
	angle_offset = lerp_angle(angle_offset, (2 * PI) / (get_child_count() - 1) * (sub_index + index), delta * response_speed)
	reposition_children()

func _on_option_pressed(option: BowlOption) -> void:
	var old_index: int = index
	index = option.get_index()
	update_selected(old_index)

func reposition_children() -> void:
	var center: Vector2 = get_global_rect().get_center()
	var radius: float = get_global_rect().size.x / 2 + radius_increase
	var option_size: Vector2 = get_child(0).get_global_rect().size
	var angle_space: float = (-2 * PI) / (get_child_count() - 1)
	for i in range(get_child_count() - 1):
		var angle: float = angle_space * i + angle_offset - PI / 2
		get_child(i).global_position = center + Vector2(radius, 0).rotated(angle)
		get_child(i).global_position -= option_size / 2
		get_child(i).global_position.y += vertical_offset
		
		angle = fmod(angle, 2 * PI)
		
		# Make the unselected options less opaque
		var angle_dif: float = min((2 * PI) - abs(angle + PI / 2), abs(angle + PI / 2))
		get_child(i).modulate.a = 1.0 - angle_dif / (1.5 * PI)
		 

func update_selected(old_index: int) -> void:
	if not old_index == -1:
		%ChimePlayer.playing = false
		%ChimePlayer.play()
	else:
		old_index = 0 # -1 is technically the internal node! 
	
	get_child(old_index).set_selected(false)
	get_child(index).set_selected(true)
	
	%BowlDescription.text = "[center]" + get_child(index).preset.display_name + ": [color=#FFF]" + get_child(index).preset.description + "[/color][/center]"

func in_bounds(location: Vector2) -> bool:
	# Sorry for the magic "64" here, I wanted the radius to extend farther from the bowl.
	var bowl_radius: float = 64 + get_global_rect().size.x / 2 + radius_increase 
	var radius: float = (location - get_global_rect().get_center() + Vector2(0, vertical_offset)).length()
	return abs(radius - bowl_radius) < drag_width

func get_selected_preset() -> BowlPreset:
	return get_child(index).preset
