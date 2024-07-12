shader_type canvas_item;
// Creates an annulus shape for the singing bowl visual.

// The radius [0, 0.5] of the hole.
uniform float inner_radius = 0.2; 

// These color options are used for the BowlOption circles
uniform vec4 color_top: source_color = vec4(1.0);
uniform vec4 color_bottom: source_color = vec4(1.0);
uniform vec4 color_top1: source_color = vec4(1.0);
uniform vec4 color_bottom1: source_color = vec4(1.0);
uniform bool half_color = false;
uniform bool use_gradient = true;

void fragment() {
	float u = UV.x - 0.5;
	float v = UV.y - 0.5;
	float radius = sqrt(u * u + v * v);
	if (radius > 0.5 || radius < inner_radius) {
		COLOR.a = 0.0;
	} else {
		COLOR.a = COLOR.a;
		if (use_gradient) {
			if (half_color && UV.x < 0.5) {
				COLOR.rgb = color_bottom1.rgb * UV.y + color_top1.rgb * (1.0 - UV.y);
			} else {
				COLOR.rgb = color_bottom.rgb * UV.y + color_top.rgb * (1.0 - UV.y);
			}
		}
	}
}