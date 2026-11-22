class_name RadarDisplay
extends Control

@export var radar_range: float = 35.0
@export var module_name: String = "BATHYS-S1"
@export var module_tier: int = 1

var _player_pos: Vector3 = Vector3.ZERO
var _player_yaw: float = 0.0
var _sweep_angle: float = 0.0


func _process(delta: float) -> void:
	_sweep_angle = fmod(_sweep_angle + 1.2 * delta, TAU)
	queue_redraw()


func update_radar(player_pos: Vector3, player_yaw: float) -> void:
	_player_pos = player_pos
	_player_yaw = player_yaw


func _draw() -> void:
	var w: float = size.x
	var h: float = size.y
	var bevel: float = 12.0
	var housing: PackedVector2Array = PackedVector2Array([
		Vector2(bevel, 0.0),
		Vector2(w, 0.0),
		Vector2(w, h - bevel),
		Vector2(w - bevel, h),
		Vector2(0.0, h),
		Vector2(0.0, bevel),
	])
	draw_colored_polygon(housing, Color(0.012, 0.032, 0.062, 0.48))
	var outline: PackedVector2Array = housing.duplicate()
	outline.append(housing[0])
	draw_polyline(outline, Color(0.24, 0.84, 1.0, 0.36), 1.0, true)
	_draw_corner_brackets(Color(0.28, 0.88, 1.0, 0.82), 14.0)

	var y: float = 6.0
	while y < h - 4.0:
		draw_line(Vector2(4.0, y), Vector2(w - 4.0, y), Color(0.25, 0.85, 1.0, 0.025), 1.0)
		y += 6.0

	var center: Vector2 = Vector2(w * 0.5, h * 0.5 + 4.0)
	var radius: float = minf(w, h) * 0.37
	var grid_color: Color = Color(0.24, 0.72, 0.88, 0.22)
	draw_arc(center, radius, 0.0, TAU, 40, grid_color, 1.0, true)
	draw_arc(center, radius * 0.5, 0.0, TAU, 32, grid_color, 1.0, true)
	draw_line(Vector2(center.x, center.y - radius), Vector2(center.x, center.y + radius), grid_color, 1.0)
	draw_line(Vector2(center.x - radius, center.y), Vector2(center.x + radius, center.y), grid_color, 1.0)

	var sweep_dir: Vector2 = Vector2(cos(_sweep_angle), sin(_sweep_angle))
	draw_line(center, center + sweep_dir * radius, Color(0.25, 0.95, 1.0, 0.45), 1.5, true)

	_draw_group_markers("radar_poi", center, radius, Color(0.24, 0.96, 0.68, 0.9), false)
	_draw_group_markers("radar_pod", center, radius, Color(0.25, 0.92, 1.0, 1.0), true)

	var tip: Vector2 = center + Vector2(0.0, -6.0)
	var left: Vector2 = center + Vector2(-3.8, 4.2)
	var right: Vector2 = center + Vector2(3.8, 4.2)
	draw_colored_polygon(PackedVector2Array([tip, right, left]), Color(0.95, 0.99, 1.0, 0.95))

	var font: Font = ThemeDB.fallback_font
	draw_string(font, Vector2(13.0, 14.0), "SONAR // %s" % module_name, HORIZONTAL_ALIGNMENT_LEFT, -1, 9, Color(0.45, 0.86, 1.0, 0.78))
	draw_string(font, Vector2(w - 40.0, h - 6.0), "%dm" % roundi(radar_range), HORIZONTAL_ALIGNMENT_RIGHT, 34.0, 9, Color(0.45, 0.86, 1.0, 0.65))


func _draw_corner_brackets(color: Color, leg: float) -> void:
	var w: float = size.x
	var h: float = size.y
	draw_polyline(PackedVector2Array([Vector2(0.0, 12.0 + leg), Vector2(0.0, 12.0), Vector2(12.0, 0.0), Vector2(12.0 + leg, 0.0)]), color, 1.5, true)
	draw_polyline(PackedVector2Array([Vector2(w - leg, 1.0), Vector2(w - 1.0, 1.0), Vector2(w - 1.0, leg)]), color, 1.5, true)
	draw_polyline(PackedVector2Array([Vector2(1.0, h - leg), Vector2(1.0, h - 1.0), Vector2(leg, h - 1.0)]), color, 1.5, true)
	draw_polyline(PackedVector2Array([Vector2(w - 12.0 - leg, h), Vector2(w - 12.0, h), Vector2(w, h - 12.0), Vector2(w, h - 12.0 - leg)]), color, 1.5, true)


func _draw_group_markers(group_name: StringName, center: Vector2, radius: float, color: Color, as_diamond: bool) -> void:
	if not is_inside_tree():
		return
	var scale_factor: float = radius / maxf(radar_range, 1.0)
	var cos_y: float = cos(_player_yaw)
	var sin_y: float = sin(_player_yaw)

	for node: Node in get_tree().get_nodes_in_group(group_name):
		if node is not Node3D:
			continue
		var target_3d: Node3D = node as Node3D
		var dx: float = target_3d.global_position.x - _player_pos.x
		var dz: float = target_3d.global_position.z - _player_pos.z
		var local_right: float = dx * cos_y - dz * sin_y
		var local_forward: float = -(dx * sin_y + dz * cos_y)
		var radar_offset: Vector2 = Vector2(local_right, -local_forward) * scale_factor
		if radar_offset.length() > radius:
			radar_offset = radar_offset.normalized() * radius

		var pos: Vector2 = center + radar_offset
		if as_diamond:
			var diamond: PackedVector2Array = PackedVector2Array([
				pos + Vector2(0.0, -4.5),
				pos + Vector2(4.5, 0.0),
				pos + Vector2(0.0, 4.5),
				pos + Vector2(-4.5, 0.0),
			])
			draw_colored_polygon(diamond, color)
		else:
			draw_circle(pos, 2.8, color)
