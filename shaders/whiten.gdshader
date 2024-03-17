shader_type canvas_item;

uniform float strength : hint_range(0.0, 1.0, 0.01) = 0.;

void fragment() {
	vec4 tex_color = texture(TEXTURE, UV);
	COLOR = mix(tex_color, vec4(1.), strength * tex_color.a);
}
