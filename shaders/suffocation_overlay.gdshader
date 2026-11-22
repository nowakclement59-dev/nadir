shader_type canvas_item;

uniform sampler2D screen_texture : hint_screen_texture, filter_linear_mipmap;
uniform float intensity : hint_range(0.0, 1.0) = 0.0;

void fragment() {
	if (intensity <= 0.001) {
		COLOR = vec4(0.0);
	} else {
		float radius = intensity * 0.008;
		vec3 blurred = vec3(0.0);
		for (int x = -1; x <= 1; x++) {
			for (int y = -1; y <= 1; y++) {
				vec2 offset = vec2(float(x), float(y)) * radius;
				blurred += texture(screen_texture, clamp(SCREEN_UV + offset, vec2(0.001), vec2(0.999))).rgb;
			}
		}
		blurred /= 9.0;

		float dist = distance(SCREEN_UV, vec2(0.5)) * 1.4142;
		float vignette_edge = smoothstep(mix(0.85, 0.1, intensity), 1.0, dist);
		float darken = clamp(vignette_edge * (0.5 + 0.5 * intensity) + intensity * 0.65, 0.0, 0.98);
		vec3 vignette_color = mix(vec3(0.01, 0.02, 0.04), vec3(0.16, 0.01, 0.02), vignette_edge * 0.55);

		COLOR = vec4(mix(blurred, vignette_color, darken), 1.0);
	}
}
