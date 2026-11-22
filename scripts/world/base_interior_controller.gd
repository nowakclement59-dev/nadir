class_name BaseInteriorController
extends Node3D

const DIVE_SCENE_PATH: String = "res://scenes/world/test_abyss.tscn"
const LORE_TITLE: String = "JOURNAL SCUPEA // AILE EST — ARCHIVE #047"
const LORE_BODY: String = "Cycle 118 — La dépressurisation de l'aile Est s'est produite à 03h14 sans alerte sismique préalable. Les cloisons étanches du secteur B ont cédé vers l'extérieur.\n\nAvant la coupure des capteurs longs, l'hydrophone BATHYS a enregistré une oscillation basse fréquence stable au fond de la fosse, à 1 400 m sous la station. Si le signal persiste, des boîtes noires intactes doivent encore dériver près de l'épave."

@export var walker: StationWalker
@export var base_hud: BaseHUD
@export var station_ui: StationUI
@export var diver_showcase: DiverShowcase
@export var terminal_screen_mesh: MeshInstance3D

var _input_reader: DiverInput = DiverInput.new()
var _screen_mat: StandardMaterial3D = StandardMaterial3D.new()


func _ready() -> void:
	_screen_mat.emission_enabled = true
	_screen_mat.emission_energy_multiplier = 2.0
	if terminal_screen_mesh != null:
		terminal_screen_mesh.material_override = _screen_mat
	if station_ui != null:
		station_ui.configure_mode(true)
		station_ui.overlay_closed.connect(_resume_exploration)
		station_ui.launch_dive_requested.connect(_on_launch_dive_requested)
	if walker != null:
		walker.interact_requested.connect(_on_interact_requested)
	if base_hud != null:
		base_hud.lore_closed.connect(_resume_exploration)
	var state: GameStateService = GameStateService.from(self)
	if state != null:
		state.state_changed.connect(_refresh_props)
	_refresh_props()
	_resume_exploration()


func _unhandled_input(_event: InputEvent) -> void:
	if not _input_reader.is_hub_menu_just_pressed():
		return
	if station_ui != null and station_ui.is_overlay_open():
		station_ui.close_overlay()
		return
	if base_hud != null and base_hud.is_lore_open():
		base_hud.hide_lore_entry()
	_open_station_overlay(StationUI.Tab.HOME)


func _process(_delta: float) -> void:
	if base_hud == null or walker == null:
		return
	if not walker.movement_enabled:
		base_hud.update_prompt("")
		return
	var target: BaseInteractable = walker.get_looked_at_interactable()
	base_hud.update_prompt(target.prompt_text if target != null else "")


func _on_interact_requested() -> void:
	if walker == null or not walker.movement_enabled:
		return
	var target: BaseInteractable = walker.get_looked_at_interactable()
	if target == null:
		return
	match target.interact_id:
		&"dive_airlock":
			_on_launch_dive_requested()
		&"workbench":
			_open_station_overlay(StationUI.Tab.UPGRADES)
		&"trade_terminal":
			_open_station_overlay(StationUI.Tab.TRADE)
		&"lore_console":
			walker.set_movement_enabled(false)
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
			if base_hud != null:
				base_hud.show_lore_entry(LORE_TITLE, LORE_BODY)


func _open_station_overlay(tab_index: int) -> void:
	if walker != null:
		walker.set_movement_enabled(false)
	if base_hud != null:
		base_hud.set_hud_visible(false)
	if station_ui != null:
		station_ui.open_tab(tab_index)


func _resume_exploration() -> void:
	if base_hud != null:
		base_hud.set_hud_visible(true)
	if walker != null:
		walker.set_movement_enabled(true)
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)


func _on_launch_dive_requested() -> void:
	var state: GameStateService = GameStateService.from(self)
	if state != null:
		state.clear_last_run_report()
	get_tree().change_scene_to_file(DIVE_SCENE_PATH)


func _refresh_props() -> void:
	var state: GameStateService = GameStateService.from(self)
	if state == null:
		return
	if diver_showcase != null:
		diver_showcase.apply_state(state)
	var online: bool = state.is_trade_terminal_repaired()
	var col: Color = Color(0.22, 0.92, 1.0) if online else Color(0.95, 0.25, 0.22)
	_screen_mat.albedo_color = col
	_screen_mat.emission = col
