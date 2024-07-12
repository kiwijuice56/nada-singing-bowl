class_name CircleInput
extends Menu
# Listens for the user to draw in a circular motion on the screen.
# Outputs `resonance`, a number between 0 and 1 that denotes the success
# of the user's input, 0 being no/poor input and 1 being sustained, circular 
# motion.

@export var minimum_speed: float = 0.0
@export var maximum_speed: float = 2.0
@export_range(0, 100, 1, "suffix:%") var inner_radius: float = 20
@export var good_color: Color
@export var bad_color: Color

@export var on_color: Color
@export var off_color: Color

@export var resonance_rate: float = 0.1
@export var deresonance_rate: float = 0.02
@export var resonance_threshold_upper: float = 0.7
@export var resonance_threshold_lower: float = 0.1

var old_state: bool = false
var is_resonating: bool = false
var resonance: float = 0.0
var using_finger: bool = false
var freeze_fade_started: bool = false
var toggle: bool = false

signal resonance_threshold_reached
signal resonance_stopped

func _ready() -> void:
	super._ready()
	modulate = bad_color

func _process(delta: float) -> void:
	is_resonating = true if toggle else is_resonating
	
	if is_resonating:
		resonance = lerp(resonance, 1.0, resonance_rate * delta)
	else:
		resonance = lerp(resonance, 0.0, deresonance_rate * delta)
	if resonance >= resonance_threshold_upper:
		resonance_threshold_reached.emit()
	if resonance <= resonance_threshold_lower:
		resonance_stopped.emit()
	
	if not Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		is_resonating = false
		using_finger = false
	
	if not is_resonating == old_state:
		old_state = is_resonating
	
	modulate = lerp(bad_color, good_color, resonance)
	%FreezeIcon.modulate = good_color if toggle else bad_color

func _input(event: InputEvent) -> void:
	var radius: float
	
	if event is InputEventScreenDrag or event is InputEventScreenTouch:
		var rect: Rect2 = get_global_rect()
		
		# Any out of bounds presses immediately kills resonance 
		if event.position.x < rect.position.x or event.position.y < rect.position.y:
			is_resonating = false
			return
		if event.position.x > rect.position.x + rect.size.x or event.position.y > rect.position.y + rect.size.y:
			is_resonating = false
			return
		
		var norm_x: float = (event.position.x - rect.position.x) / float(rect.size.x)
		var norm_y: float = (event.position.y - rect.position.y) / float(rect.size.y)
		
		norm_x -= 0.5
		norm_y -= 0.5
		
		radius = sqrt(norm_x ** 2 + norm_y ** 2)
	else:
		return
	
	# The user can place their finger in the center as well
	if event is InputEventScreenTouch and not event.is_pressed():
		# Add a small buffer zone (0.1) 
		if radius < (inner_radius + 0.1) / 100.0:
			toggle = not toggle
			if toggle:
				%On.play()
			else:
				%Off.play()
			return
	
	# Otherwise, they should be rotating at the correct speed
	if event is InputEventScreenDrag:
		var speed: float = event.velocity.length() / get_viewport().size.x
		if speed > maximum_speed or speed < minimum_speed:
			is_resonating = false
			return
		if (radius > 0.5 or radius < inner_radius / 100.):
			is_resonating = false
			return
		is_resonating = true

func enter(transition_alpha: bool = false) -> void:
	set_process_input(true)
	set_process(true)
	
	toggle = false
	%FreezeIcon.modulate = good_color if toggle else bad_color
	
	if transition_alpha:
		var tween: Tween = get_tree().create_tween().set_parallel(true)
		tween.tween_property(self, "self_modulate:a", 1.0, transition_time)
		tween.tween_property(%FreezeIcon, "self_modulate:a", 1.0, transition_time)
	
	mouse_filter = Control.MOUSE_FILTER_STOP
	get_parent().mouse_filter = mouse_filter

func exit(transition_alpha: bool = false) -> void:
	set_process_input(false)
	set_process(false)
	
	toggle = false
	%FreezeIcon.modulate = good_color if toggle else bad_color
	
	if transition_alpha:
		var tween: Tween = get_tree().create_tween().set_parallel(true)
		tween.tween_property(self, "self_modulate:a", 0.0, transition_time)
		tween.tween_property(%FreezeIcon, "self_modulate:a", 0.0, transition_time)
	
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	get_parent().mouse_filter = mouse_filter
	
	is_resonating = false
	resonance = 0.0
