class_name ModuleBezel
extends Control

@export var bevel_size: float = 14.0
@export var fill_color: Color = Color(0.012, 0.032, 0.062, 0.52)
@export var border_color: Color = Color(0.24, 0.84, 1.0, 0.42)
@export var accent_color: Color = Color(0.32, 0.94, 1.0, 0.85)


func _draw() -> void:
	var w: float = size.x
	var h: float = size.y
	if w <= bevel_size * 2.0 or h <= bevel_size * 2.0:
		return

	var b: float = bevel_size
	var chassis: PackedVector2Array = PackedVector2Array([
		Vector2(b, 0.0),
		Vector2(w - 4.0, 0.0),
		Vector2(w, 4.0),
		Vector2(w, h - b),
		Vector2(w - b, h),
		Vector2(4.0, h),
		Vector2(0.0, h - 4.0),
		Vector2(0.0, b),
	])
	draw_colored_polygon(chassis, fill_color)

	var outline: PackedVector2Array = chassis.duplicate()
	outline.append(chassis[0])
	draw_polyline(outline, border_color, 1.2, true)

	# Technical top-left bevel accent and bottom-right corner accent
	draw_polyline(PackedVector2Array([
		Vector2(0.0, b + 12.0),
		Vector2(0.0, b),
		Vector2(b, 0.0),
		Vector2(b + 26.0, 0.0),
	]), accent_color, 2.0, true)
	draw_polyline(PackedVector2Array([
		Vector2(w - b - 20.0, h),
		Vector2(w - b, h),
		Vector2(w, h - b),
		Vector2(w, h - b - 10.0),
	]), accent_color, 1.8, true)

	# Subtle internal visor grid scanlines
	var step_y: float = 6.0
	var y: float = step_y
	while y < h - 4.0:
		draw_line(Vector2(6.0, y), Vector2(w - 6.0, y), Color(0.25, 0.85, 1.0, 0.025), 1.0)
		y += step_y
