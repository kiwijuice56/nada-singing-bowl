shader_type canvas_item;
// Creates an eclipse shape.

uniform vec2 cover_offset; 

void fragment() {
	float u = UV.x - 0.5;
	float v = UV.y - 0.5;
	
	float u1 = UV.x - cover_offset.x;
	float v1 = UV.y - cover_offset.y;
	
	float radius = sqrt(u * u + v * v);
	float radius1 = sqrt(u1 * u1 + v1 * v1);
	if (radius > 0.5) {
		COLOR.a = 0.0;
	} else if (radius1 < 0.495) {
		COLOR.rgb = vec3(0.0);
		COLOR.a = 0.6;
	} else {
		COLOR.a = COLOR.a;
	}
}