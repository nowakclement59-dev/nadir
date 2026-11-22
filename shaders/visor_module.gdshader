shader_type canvas_item;

uniform float scanline_density : hint_range(40.0, 400.0) = 160.0;
uniform float scanline_alpha : hint_range(0.0, 0.25) = 0.065;
uniform vec4 tint_color : source_color = vec4(0.18, 0.86, 1.0, 1.0);

void fragment() {
	float wave = 0.5 + 0.5 * sin(UV.y * scanline_density * 6.2831853);
	float sheen = (1.0 - UV.y) * 0.035;
	float alpha = wave * scanline_alpha + sheen;
	COLOR = vec4(tint_color.rgb, alpha);
}
