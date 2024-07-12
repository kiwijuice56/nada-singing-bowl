shader_type canvas_item;

uniform float intensity;
uniform sampler2D noise: hint_default_black;

void fragment() {
	float u = UV.x - 0.5;
	float v = UV.y - 0.5;
	
	float radius = sqrt(u * u + v * v);
	
	COLOR.rgb = vec3(1.0);
	COLOR.a = texture(noise, UV).r;
}
