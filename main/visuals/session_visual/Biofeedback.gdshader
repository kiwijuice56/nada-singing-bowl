shader_type canvas_item;

uniform vec2 uv_offset;
uniform float scale = 2.0;
uniform float aspect_ratio = 0.5;

uniform sampler2D color_gradient;
uniform sampler2D distance_gradient;
uniform float spiral_width = 0.15;
uniform float color_intensity = 1.0;

vec4 base_spiral_color(vec2 position) {
	float radius = distance(vec2(0.0), position);
	float angle = mod(PI + atan(position.y, position.x), 2.0 * PI);
	
	float spiral_distance = distance(0.0, mod(angle, PI / 4.0));
	if (spiral_distance < spiral_width) {
		return vec4(0.0);
	}
	
	return texture(color_gradient, vec2(radius));
}

void fragment() {
	vec2 position = UV - vec2(0.5, 0.5) + uv_offset;
	position.x *= aspect_ratio;
	position *= scale * 5.0;
	
	float radius = distance(vec2(0.0), position);
	
	float angle = radius * 16.0 - TIME * 0.1; 
	mat2 rotation_matrix = mat2(vec2(sin(angle), -cos(angle)),
								vec2(cos(angle), sin(angle)));
	
	COLOR *= color_intensity * texture(distance_gradient, vec2(radius)) * base_spiral_color(position * rotation_matrix);
}