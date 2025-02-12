class_name Plot
extends TextureRect

@export var plot_point_scene: PackedScene
@export var plot_line_scene: PackedScene

const POINT_SIZE: Vector2 = Vector2(50, 50)
const PLOT_SIZE: Vector2 = Vector2(1036, 824)

const RATE_MAX: float = 130
const RATE_MIN: float = 0

func _ready() -> void:
	clear()
	plot([0, 1, 2, 3, 4, 5, 6], [60, 70, 65, 80, 85], [10, 12, 20, 15, 16])

# len(timestamps) >= 2, len(hr) >= 0, len(br) >= 0
func plot(timestamps: Array[float], heart_points: Array[float], breathing_points: Array[float]) -> void:
	clear()
	
	
	var min_time: float = timestamps[0]
	var max_time: float = timestamps[-1]
	print(max_time, " ", min_time)
	%TimeMax.text = str(abs(int(max_time - min_time)))
	
	var samples: int = len(heart_points)
	
	var last_heart_point: PlotPoint
	var last_breath_point: PlotPoint
	
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
			new_icon.position.x = PLOT_SIZE.x * (time - min_time) / (max_time - min_time) - POINT_SIZE.x / 2
			new_icon.position.y = PLOT_SIZE.y - PLOT_SIZE.y * (rate - RATE_MIN) / (RATE_MAX - RATE_MIN) - POINT_SIZE.y / 2
			
			if i > 0:
				var new_line: Line2D = plot_line_scene.instantiate()
				add_child(new_line)
				new_line.points[0] = (last_heart_point if is_heart else last_breath_point).position + POINT_SIZE / 2
				new_line.points[1] = new_icon.position + POINT_SIZE / 2
			
			if is_heart:
				last_heart_point = new_icon
			else:
				last_breath_point = new_icon

func clear() -> void:
	for child in get_children():
		child.queue_free()
