class_name StationHubController
extends Node3D

const DIVE_SCENE_PATH: String = "res://scenes/world/test_abyss.tscn"

@export var diver_showcase: DiverShowcase
@export var terminal_screen_mesh: MeshInstance3D
@export var station_ui: StationUI

var _dragging: bool = false
var _screen_mat: StandardMaterial3D = StandardMaterial3D.new()


func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	_screen_mat.emission_enabled = true
	_screen_mat.emission_energy_multiplier = 2.0
	if terminal_screen_mesh != null:
		terminal_screen_mesh.material_override = _screen_mat
	if station_ui != null:
		station_ui.launch_dive_requested.connect(_on_launch_dive_requested)
	var state: GameStateService = GameStateService.from(self)
	if state != null:
		state.state_changed.connect(_refresh_visuals)
	_refresh_visuals()


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		var mb: InputEventMouseButton = event as InputEventMouseButton
		if mb.button_index == MOUSE_BUTTON_LEFT:
			if mb.pressed:
				var split_x: float = get_viewport().get_visible_rect().size.x * 0.56
				_dragging = mb.position.x >= split_x
			else:
				_dragging = false
	elif event is InputEventMouseMotion and _dragging and diver_showcase != null:
		var motion: InputEventMouseMotion = event as InputEventMouseMotion
		diver_showcase.rotate_preview(motion.relative.x)


func _refresh_visuals() -> void:
	var state: GameStateService = GameStateService.from(self)
	if state == null:
		return
	if diver_showcase != null:
		diver_showcase.apply_state(state)
	var online: bool = state.is_trade_terminal_repaired()
	var col: Color = Color(0.22, 0.92, 1.0) if online else Color(0.95, 0.25, 0.22)
	_screen_mat.albedo_color = col
	_screen_mat.emission = col


func _on_launch_dive_requested() -> void:
	var state: GameStateService = GameStateService.from(self)
	if state != null:
		state.clear_last_run_report()
	get_tree().change_scene_to_file(DIVE_SCENE_PATH)
