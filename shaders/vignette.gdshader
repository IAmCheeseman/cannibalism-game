shader_type canvas_item;

uniform vec4 vignette_color : source_color;
uniform float strength  : hint_range(0.0, 1.0, 0.01) = 1.0;
uniform sampler2D vein_noise;
uniform sampler2D screen_texture : hint_screen_texture, repeat_disable, filter_nearest;

void fragment() {
	vec4 color = texture(screen_texture, SCREEN_UV);
	float circle = sin(UV.x * PI) * sin(UV.y * PI);
	float vignette = (1.0 - circle) * strength;
	float vein = texture(vein_noise, UV).r * (1.0 - circle) * strength * 0.75;
	vignette = mix(vignette, vein, 0.5);
	COLOR = mix(color, vignette_color, vignette);
}