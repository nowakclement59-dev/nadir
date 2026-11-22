class_name DiveHUD
extends CanvasLayer

signal restart_requested

@export_group("Navigation")
@export var compass_bar: CompassBar
@export var depth_label: Label
@export var radar_display: RadarDisplay

@export_group("Vitals")
@export var status_label: Label
@export var oxygen_bar: ProgressBar
@export var oxygen_label: Label
@export var health_bar: ProgressBar
@export var health_label: Label
@export var pressure_label: Label
@export var inventory_label: Label
@export var inventory_slots_box: HBoxContainer

@export_group("Overlays")
@export var suffocation_rect: ColorRect
@export var death_overlay: Control
@export var death_reason_label: Label
@export var restart_button: Button

var _target_oxygen: float = 60.0
var _target_health: float = 100.0
var _oxygen_initialized: bool = false
var _health_initialized: bool = false


func _ready() -> void:
	if death_overlay != null:
		death_overlay.visible = false
	if restart_button != null:
		restart_button.pressed.connect(_on_restart_pressed)
	update_inventory(0, 6)
	update_suffocation(0.0)


func _process(delta: float) -> void:
	var weight: float = 1.0 - exp(-10.0 * delta)
	if oxygen_bar != null and not is_equal_approx(oxygen_bar.value, _target_oxygen):
		oxygen_bar.value = lerpf(oxygen_bar.value, _target_oxygen, weight)
	if health_bar != null and not is_equal_approx(health_bar.value, _target_health):
		health_bar.value = lerpf(health_bar.value, _target_health, weight)


func update_oxygen(current: float, maximum: float) -> void:
	var safe_max: float = maxf(maximum, 1.0)
	var ratio: float = clampf(current / safe_max, 0.0, 1.0)
	_target_oxygen = current
	if oxygen_bar != null:
		oxygen_bar.max_value = safe_max
		if not _oxygen_initialized:
			oxygen_bar.value = current
			_oxygen_initialized = true
		oxygen_bar.modulate = Color(1.0, 0.32, 0.35, 1.0) if ratio <= 0.25 else Color(0.15, 0.88, 1.0, 1.0)
	if oxygen_label != null:
		oxygen_label.text = "%d / %d" % [ceili(current), roundi(safe_max)]
	if status_label != null:
		if current <= 0.0:
			status_label.text = "■ HYPOXIE"
			status_label.modulate = Color(1.0, 0.25, 0.28, 1.0)
		elif ratio <= 0.25:
			status_label.text = "▲ O2 BAS"
			status_label.modulate = Color(1.0, 0.68, 0.2, 1.0)
		else:
			status_label.text = "● NOMINAL"
			status_label.modulate = Color(0.25, 0.96, 0.68, 0.95)


func update_health(current: float, maximum: float) -> void:
	var safe_max: float = maxf(maximum, 1.0)
	_target_health = current
	if health_bar != null:
		health_bar.max_value = safe_max
		if not _health_initialized:
			health_bar.value = current
			_health_initialized = true
	if health_label != null:
		health_label.text = "%d / %d" % [ceili(current), roundi(safe_max)]


func update_inventory(used_slots: int, total_slots: int) -> void:
	if inventory_label != null:
		inventory_label.text = "CARGO  %d / %d" % [used_slots, total_slots]
	if inventory_slots_box != null:
		var slot_index: int = 0
		for child: Node in inventory_slots_box.get_children():
			if child is CanvasItem:
				var slot_item: CanvasItem = child as CanvasItem
				slot_item.visible = slot_index < total_slots
				slot_item.modulate = Color(0.2, 0.92, 1.0, 0.95) if slot_index < used_slots else Color(0.25, 0.55, 0.7, 0.22)
			slot_index += 1


func update_navigation(heading_degrees: float, depth_meters: float, player_pos: Vector3, player_yaw: float) -> void:
	if compass_bar != null:
		compass_bar.set_heading(heading_degrees)
	if depth_label != null:
		depth_label.text = "%03d°  |  -%d m" % [roundi(fposmod(heading_degrees, 360.0)) % 360, roundi(depth_meters)]
	if pressure_label != null:
		var pressure_bar: float = 1.0 + maxf(depth_meters, 0.0) / 10.0
		pressure_label.text = "%.1f BAR" % pressure_bar
	if radar_display != null:
		radar_display.update_radar(player_pos, player_yaw)


func update_suffocation(progress: float) -> void:
	if suffocation_rect == null:
		return
	var mat: ShaderMaterial = suffocation_rect.material as ShaderMaterial
	if mat != null:
		mat.set_shader_parameter("intensity", clampf(progress, 0.0, 1.0))


func show_death_screen(reason: String) -> void:
	if death_reason_label != null:
		death_reason_label.text = reason
	if death_overlay != null:
		death_overlay.visible = true
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)


func _on_restart_pressed() -> void:
	restart_requested.emit()
