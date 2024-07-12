shader_type canvas_item;

global uniform vec4 app_hue;
uniform float alpha = 0.2;

void fragment() {
	COLOR = app_hue;
	COLOR.a = alpha;
}
