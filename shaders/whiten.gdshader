shader_type canvas_item;

uniform float strength = 0.;

void fragment() {
	vec4 tex_color = texture(TEXTURE, UV);
	COLOR = mix(tex_color, vec4(1.), strength * tex_color.a);
}
