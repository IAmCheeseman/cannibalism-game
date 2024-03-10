shader_type canvas_item;
render_mode blend_add;

uniform float wobble_strength = 2.0; 
uniform float wobble_speed = 4.0; 

void vertex() {
	VERTEX += vec2(
		cos(TIME * wobble_speed + float(VERTEX_ID)) * wobble_strength,
		sin(TIME * wobble_speed + float(VERTEX_ID)) * wobble_strength);
}

void fragment() {

}
