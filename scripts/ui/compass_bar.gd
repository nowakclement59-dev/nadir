class_name CompassBar
extends Control

const FOV_DEGREES: float = 150.0
const STEP_DEGREES: int = 15
const CARDINALS: Dictionary[int, String] = {
	0: "N",
	45: "NE",
	90: "E",
	135: "SE",
	180: "S",
	225: "SW",
	270: "W",
	315: "NW",
}

@export var module_name: String = "GYRO-1"

var heading_degrees: float = 0.0


func set_heading(degrees: float) -> void:
	heading_degrees = fposmod(degrees, 360.0)
	queue_redraw()


func _draw() -> void:
	var w: float = size.x
	var h: float = size.y
	var center_x: float = w * 0.5
	var pixels_per_degree: float = w / FOV_DEGREES
	var font: Font = ThemeDB.fallback_font
	var font_size: int = 11

	draw_line(
		Vector2(w * 0.08, 5.0),
		Vector2(w * 0.92, 5.0),
		Color(0.35, 0.82, 0.95, 0.2),
		1.0
	)
	var bracket_color: Color = Color(0.32, 0.86, 1.0, 0.35)
	draw_polyline(PackedVector2Array([Vector2(w * 0.06, 12.0), Vector2(w * 0.04, 5.0), Vector2(w * 0.08, 5.0)]), bracket_color, 1.2, true)
	draw_polyline(PackedVector2Array([Vector2(w * 0.94, 12.0), Vector2(w * 0.96, 5.0), Vector2(w * 0.92, 5.0)]), bracket_color, 1.2, true)
	draw_string(font, Vector2(w * 0.05, h - 1.0), "NAV // %s" % module_name, HORIZONTAL_ALIGNMENT_LEFT, -1, 8, Color(0.45, 0.84, 1.0, 0.42))

	var start_deg: int = floori((heading_degrees - FOV_DEGREES * 0.5) / float(STEP_DEGREES)) * STEP_DEGREES
	var end_deg: int = ceili((heading_degrees + FOV_DEGREES * 0.5) / float(STEP_DEGREES)) * STEP_DEGREES

	for raw_deg: int in range(start_deg, end_deg + STEP_DEGREES, STEP_DEGREES):
		var delta_deg: float = float(raw_deg) - heading_degrees
		var x: float = center_x + delta_deg * pixels_per_degree
		var norm_dist: float = absf(x - center_x) / maxf(center_x, 1.0)
		if norm_dist >= 0.92:
			continue
		var edge_alpha: float = clampf(1.0 - smoothstep(0.6, 0.92, norm_dist), 0.0, 1.0)

		var wrapped_deg: int = posmod(raw_deg, 360)
		var is_major: bool = (wrapped_deg % 45) == 0
		var tick_bottom: float = 11.0 if is_major else 8.0
		var tick_color: Color = Color(0.55, 0.92, 1.0, 0.8 * edge_alpha) if is_major else Color(0.55, 0.78, 0.9, 0.4 * edge_alpha)
		draw_line(Vector2(x, 3.0), Vector2(x, tick_bottom), tick_color, 1.0)

		if CARDINALS.has(wrapped_deg):
			var label: String = CARDINALS[wrapped_deg]
			var text_size: Vector2 = font.get_string_size(label, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size)
			var base_color: Color = Color(0.25, 0.96, 1.0, 0.95) if wrapped_deg == 0 else Color(0.84, 0.94, 1.0, 0.85)
			base_color.a *= edge_alpha
			draw_string(font, Vector2(x - text_size.x * 0.5, h - 2.0), label, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size, base_color)

	var chevron: PackedVector2Array = PackedVector2Array([
		Vector2(center_x, 5.0),
		Vector2(center_x - 4.0, 0.0),
		Vector2(center_x + 4.0, 0.0),
	])
	draw_colored_polygon(chevron, Color(1.0, 0.76, 0.25, 0.95))
