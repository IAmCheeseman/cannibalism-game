shader_type canvas_item;

uniform float amp = 1.0;
uniform float freq = 1.0;

void vertex() {
	VERTEX.x += VERTEX.y * sin(TIME * freq + float(VERTEX_ID) * 0.2) * amp;
}
