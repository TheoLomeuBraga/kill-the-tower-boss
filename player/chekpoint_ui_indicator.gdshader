shader_type canvas_item;

uniform float transparency : hint_range(0.0, 1.0) = 1.0;

void vertex() {
	COLOR.a = transparency;
}
