class_name Plot
extends TextureRect

@export var plot_point_scene: PackedScene

const POINT_SIZE: Vector2 = Vector2(50, 50)
const PLOT_SIZE: Vector2 = Vector2(1036, 824)

const RATE_MAX: float = 130
const RATE_MIN: float = 0


func _ready() -> void:
	plot([0, 1, 2, 3, 4, 5, 6], [60, 70, 65, 80, 85], [10, 12, 20, 15, 16])

# len(timestamps) >= 2, len(hr) >= 0, len(br) >= 0
func plot(timestamps: Array[float], heart_points: Array[float], breathing_points: Array[float]) -> void:
	var min_time: float = timestamps[0]
	var max_time: float = timestamps[-1]
	var samples: int = len(heart_points)
	
	for i in range(samples):
		var time: float = timestamps[i + 1]
		var hr: float = heart_points[i]
		var br: float = breathing_points[i]
		
		for j in range(2):
			var is_heart: bool = j == 0
			var rate: float = hr if is_heart else br
			
			var new_icon: PlotPoint = plot_point_scene.instantiate()
			add_child(new_icon)
			new_icon.initialize(PlotPoint.HEART if is_heart else PlotPoint.BREATHING, rate)
			new_icon.position.x = PLOT_SIZE.x * (time - min_time) / max_time - POINT_SIZE.x / 2
			new_icon.position.y = PLOT_SIZE.y - PLOT_SIZE.y * (rate - RATE_MIN) / RATE_MAX - POINT_SIZE.y / 2

func clear() -> void:
	for child in get_children():
		child.queue_free()
