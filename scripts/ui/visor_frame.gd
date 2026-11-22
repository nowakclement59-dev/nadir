class_name VisorFrame
extends Control


func _draw() -> void:
	var w: float = size.x
	var h: float = size.y
	if w <= 80.0 or h <= 80.0:
		return

	var outer_color: Color = Color(0.28, 0.86, 1.0, 0.22)
	var inner_color: Color = Color(0.22, 0.78, 0.96, 0.11)
	var tick_color: Color = Color(0.22, 0.78, 0.96, 0.14)
	var pad: float = 8.0
	var r: float = 26.0

	# Sleek, compact curved helmet-visor corner arcs
	draw_arc(Vector2(pad + r, pad + r), r, PI, PI * 1.5, 16, outer_color, 1.2, true)
	draw_arc(Vector2(w - pad - r, pad + r), r, PI * 1.5, TAU, 16, outer_color, 1.2, true)
	draw_arc(Vector2(w - pad - r, h - pad - r), r, 0.0, PI * 0.5, 16, outer_color, 1.2, true)
	draw_arc(Vector2(pad + r, h - pad - r), r, PI * 0.5, PI, 16, outer_color, 1.2, true)

	# Subtle inner accent arcs
	var r_in: float = 20.0
	var pad_in: float = 12.0
	draw_arc(Vector2(pad_in + r_in, pad_in + r_in), r_in, PI * 1.08, PI * 1.42, 10, inner_color, 1.0, true)
	draw_arc(Vector2(w - pad_in - r_in, pad_in + r_in), r_in, PI * 1.58, PI * 1.92, 10, inner_color, 1.0, true)
	draw_arc(Vector2(w - pad_in - r_in, h - pad_in - r_in), r_in, PI * 0.08, PI * 0.42, 10, inner_color, 1.0, true)
	draw_arc(Vector2(pad_in + r_in, h - pad_in - r_in), r_in, PI * 0.58, PI * 0.92, 10, inner_color, 1.0, true)

	# Minimal lateral visor ticks
	var mid_y: float = h * 0.5
	for i: int in range(-1, 2):
		var ty: float = mid_y + float(i) * 26.0
		var tick_len: float = 6.0 if i == 0 else 3.5
		draw_line(Vector2(10.0, ty), Vector2(10.0 + tick_len, ty), tick_color, 1.0)
		draw_line(Vector2(w - 10.0, ty), Vector2(w - 10.0 - tick_len, ty), tick_color, 1.0)

	var font: Font = ThemeDB.fallback_font
	draw_string(
		font,
		Vector2(20.0, h - 16.0),
		"SCUPEA SUIT-OS // BUS MODULAIRE",
		HORIZONTAL_ALIGNMENT_LEFT,
		-1,
		10,
		Color(0.45, 0.84, 1.0, 0.32)
	)
