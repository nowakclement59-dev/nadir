class_name DiverShowcase
extends Node3D

@export var suit_root: Node3D
@export var torso_pivot: Node3D
@export var helmet_pivot: Node3D
@export var primary_meshes: Array[MeshInstance3D] = []
@export var accent_meshes: Array[MeshInstance3D] = []
@export var visor_meshes: Array[MeshInstance3D] = []
@export var extra_o2_tank: Node3D
@export var hydro_fins_nodes: Array[Node3D] = []
@export var sonar_lens_mesh: MeshInstance3D

var _idle_time: float = 0.0
var _primary_mat: StandardMaterial3D = StandardMaterial3D.new()
var _accent_mat: StandardMaterial3D = StandardMaterial3D.new()
var _visor_mat: StandardMaterial3D = StandardMaterial3D.new()
var _sonar_mat: StandardMaterial3D = StandardMaterial3D.new()


func _ready() -> void:
	_setup_materials()


func _process(delta: float) -> void:
	_idle_time += delta
	if torso_pivot != null:
		torso_pivot.position.y = 0.88 + sin(_idle_time * 1.8) * 0.012
	if helmet_pivot != null:
		helmet_pivot.rotation.y = sin(_idle_time * 0.85) * 0.09
		helmet_pivot.rotation.x = sin(_idle_time * 1.8) * 0.025


func rotate_preview(delta_x: float) -> void:
	if suit_root != null:
		suit_root.rotate_y(delta_x * 0.012)


func apply_state(state: GameStateService) -> void:
	if state == null:
		return
	var palette: Dictionary = _get_skin_palette(state.selected_skin_id)
	_primary_mat.albedo_color = palette["primary"] as Color
	_accent_mat.albedo_color = palette["accent"] as Color
	var visor_col: Color = palette["visor"] as Color
	_visor_mat.albedo_color = visor_col
	_visor_mat.emission = visor_col

	if extra_o2_tank != null:
		extra_o2_tank.visible = state.get_upgrade_level(&"oxygen_tank") >= 1
	var fins_lvl: int = state.get_upgrade_level(&"hydro_fins")
	for fin: Node3D in hydro_fins_nodes:
		if fin != null:
			fin.visible = fins_lvl >= 1
			fin.scale = Vector3.ONE * (1.0 + 0.15 * float(maxi(fins_lvl - 1, 0)))

	var sonar_lvl: int = state.get_upgrade_level(&"sonar_module")
	_sonar_mat.emission_energy_multiplier = 1.4 + float(sonar_lvl) * 1.2
	_sonar_mat.emission = Color(0.2, 0.96, 0.68) if sonar_lvl >= 2 else Color(0.24, 0.88, 1.0)
	if sonar_lens_mesh != null:
		sonar_lens_mesh.scale = Vector3.ONE * (1.0 + float(sonar_lvl) * 0.18)


func _setup_materials() -> void:
	_primary_mat.roughness = 0.42
	_primary_mat.metallic = 0.25
	_accent_mat.roughness = 0.35
	_accent_mat.metallic = 0.45
	_visor_mat.roughness = 0.15
	_visor_mat.emission_enabled = true
	_visor_mat.emission_energy_multiplier = 2.0
	_sonar_mat.albedo_color = Color(0.2, 0.85, 1.0)
	_sonar_mat.emission_enabled = true
	_sonar_mat.emission = Color(0.24, 0.88, 1.0)
	_assign_material(primary_meshes, _primary_mat)
	_assign_material(accent_meshes, _accent_mat)
	_assign_material(visor_meshes, _visor_mat)
	if sonar_lens_mesh != null:
		sonar_lens_mesh.material_override = _sonar_mat


func _assign_material(meshes: Array[MeshInstance3D], mat: Material) -> void:
	for m: MeshInstance3D in meshes:
		if m != null:
			m.material_override = mat


func _get_skin_palette(skin_id: StringName) -> Dictionary:
	match skin_id:
		&"hazard_amber":
			return {"primary": Color(0.18, 0.21, 0.25), "accent": Color(0.92, 0.52, 0.14), "visor": Color(1.0, 0.72, 0.25)}
		&"deep_stealth":
			return {"primary": Color(0.08, 0.1, 0.13), "accent": Color(0.14, 0.24, 0.28), "visor": Color(0.22, 0.96, 0.68)}
		_:
			return {"primary": Color(0.76, 0.82, 0.88), "accent": Color(0.16, 0.38, 0.52), "visor": Color(0.22, 0.88, 1.0)}
