class_name ProgressMoon
extends Sprite2D
# Script to controll the moon visual that moves across the screen as a session progresses.

@export var end_point: PackedScene
@export var progress: float = 0.0

# Holds references to the beginning and end markers, to fade in and out
var end_points: Array[Sprite2D] = []

func _ready() -> void:
	modulate.a = 0.2
	set_process(false)
	position = get_desired_position(1.0)
	modulate.a = 0.0
	
	add_points.call_deferred()

func add_points() -> void:
	var point_a: Sprite2D = end_point.instantiate()
	get_parent().add_child(point_a)
	
	
	var point_b: Sprite2D = end_point.instantiate()
	get_parent().add_child(point_b)
	
	end_points = [point_a, point_b]

func start() -> void:
	position = get_desired_position(0)
	
	var tween: Tween = get_tree().create_tween().set_parallel(true)
	tween.tween_property(self, "modulate:a", 1.0, 0.5)
	tween.tween_property(end_points[0], "modulate:a", 1.0, 0.5)
	tween.tween_property(end_points[1], "modulate:a", 1.0, 0.5)
	
	progress = 0.0
	set_process(true)

func stop() -> void:
	progress = 1.0
	set_process(false)
	
	var tween: Tween = get_tree().create_tween().set_parallel(true)
	tween.tween_property(self, "modulate:a", 0.0, 1.5)
	tween.tween_property(end_points[0], "modulate:a", 0.0, 0.5)
	tween.tween_property(end_points[1], "modulate:a", 0.0, 0.5)

func get_desired_position(x: float) -> Vector2:
	var size: Vector2 = get_viewport_rect().size
	var radius: float = size.y
	
	var angle_max: float = acos((size.x) / radius) + 0.09
	var angle_min: float = PI - angle_max 
	
	var angle: float = (angle_max - angle_min) * x + angle_min 
	
	var out: Vector2 = Vector2()
	out.x = 0.5 * size.x + 0.5 * radius * cos(angle) 
	out.y = size.y - radius * sin(angle) + 128
	
	%Flare.material.set_shader_parameter("intensity", pow(SessionHandler.normal_dist(x), 2))
	material.set_shader_parameter("cover_offset", Vector2(-0.5 + 2*x, 0.5))
	
	return out

func _process(_delta: float) -> void:
	end_points[0].global_position = get_desired_position(0)
	end_points[1].global_position = get_desired_position(1)
	
	position = get_desired_position(progress)
