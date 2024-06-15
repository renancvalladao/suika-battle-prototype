shader_type canvas_item;

uniform float fill_percentage = 0.5;

void fragment() {
	if (UV.y < (1.0 - fill_percentage) && COLOR.a > 0.0) {
		//COLOR.a = 0.5;
		COLOR.r = 0.0;
		COLOR.g = 0.0;
		COLOR.b = 0.0;
	}
}
