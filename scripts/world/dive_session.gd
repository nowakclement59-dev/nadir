class_name DiveSession
extends Node3D

const STATION_SCENE_PATH: String = "res://scenes/world/station_hub.tscn"

@export_group("References")
@export var diver: DiverController
@export var oxygen_system: OxygenSystem
@export var health_system: HealthSystem
@export var inventory_system: InventorySystem
@export var dive_hud: DiveHUD

@export_group("Environment")
@export var surface_reference_y: float = 123.0

var _run_finished: bool = false


func _ready() -> void:
	_apply_persistent_upgrades()
	_connect_signals()


func _connect_signals() -> void:
	if diver != null:
		diver.interact_requested.connect(_on_interact_requested)
	if oxygen_system != null:
		oxygen_system.suffocated.connect(_on_player_died.bind("Asphyxie — Réserves d'oxygène épuisées dans les abysses."))
	if health_system != null:
		health_system.died.connect(_on_player_died.bind("Intégrité vitale perdue — Combinaison détruite."))
	if inventory_system != null:
		inventory_system.inventory_full.connect(func(_item: LootItemData) -> void:
			if dive_hud != null:
				dive_hud.show_feedback("CARGO PLEIN — Retournez au sas d'extraction", 2.2))
	if dive_hud == null:
		return
	dive_hud.restart_requested.connect(_return_to_station)
	if oxygen_system != null:
		oxygen_system.oxygen_changed.connect(dive_hud.update_oxygen)
		oxygen_system.suffocation_changed.connect(dive_hud.update_suffocation)
		dive_hud.update_oxygen(oxygen_system.current_oxygen, oxygen_system.max_oxygen)
	if health_system != null:
		health_system.health_changed.connect(dive_hud.update_health)
		dive_hud.update_health(health_system.current_health, health_system.max_health)
	if inventory_system != null:
		inventory_system.inventory_changed.connect(dive_hud.update_inventory)
		dive_hud.update_inventory(inventory_system.used_slots, inventory_system.max_slots)


func _process(_delta: float) -> void:
	if diver == null:
		return
	if oxygen_system != null:
		oxygen_system.is_sprinting = diver.is_sprinting_active()
	if dive_hud != null:
		var depth_meters: float = maxf(0.0, surface_reference_y - diver.global_position.y)
		var forward: Vector3 = -diver.global_basis.z
		dive_hud.update_navigation(rad_to_deg(atan2(forward.x, -forward.z)), depth_meters, diver.global_position, diver.rotation.y)
		dive_hud.update_interaction_prompt(_get_target_prompt())


func _get_target_prompt() -> String:
	if diver == null or not diver.movement_enabled:
		return ""
	var target: Node = diver.get_looked_at_interactable()
	if target is LootPickup:
		return (target as LootPickup).get_prompt_text()
	if target is ExtractionPod:
		return (target as ExtractionPod).get_prompt_text()
	return ""


func _on_interact_requested() -> void:
	if diver == null or not diver.movement_enabled:
		return
	var target: Node = diver.get_looked_at_interactable()
	if target is LootPickup and inventory_system != null:
		var pickup: LootPickup = target as LootPickup
		if inventory_system.try_add(pickup.item_data):
			pickup.collect()
	elif target is ExtractionPod:
		_complete_extraction()


func _complete_extraction() -> void:
	if _run_finished:
		return
	_run_finished = true
	if diver != null:
		diver.set_movement_enabled(false)
	if oxygen_system != null:
		oxygen_system.is_active = false
	var state: GameStateService = GameStateService.from(self)
	if state != null and inventory_system != null:
		var summary: String = inventory_system.get_items_summary()
		var report: Dictionary = state.deposit_run_loot(inventory_system.items)
		state.set_last_run_report("extracted", summary, int(report.get("estimated_value", 0)), int(report.get("count", 0)))
	_return_to_station()


func _on_player_died(reason: String) -> void:
	if _run_finished:
		return
	_run_finished = true
	var state: GameStateService = GameStateService.from(self)
	if state != null:
		state.record_dive_loss()
		state.set_last_run_report("died", reason + "\nButin perdu dans les abysses.", 0, 0)
	if inventory_system != null:
		inventory_system.clear_inventory()
	if diver != null:
		diver.set_movement_enabled(false)
	if oxygen_system != null:
		oxygen_system.is_active = false
	if dive_hud != null:
		dive_hud.show_death_screen(reason + "\n\nButin perdu dans les abysses.")


func _apply_persistent_upgrades() -> void:
	var state: GameStateService = GameStateService.from(self)
	if state == null:
		return
	var bonus_canisters: int = state.consume_equipped_loadout_for_dive()
	if oxygen_system != null:
		oxygen_system.max_oxygen = state.get_max_oxygen() + float(bonus_canisters) * 25.0
		oxygen_system.reset_oxygen()
	if diver != null:
		diver.swim_speed = state.get_swim_speed()
	if dive_hud != null:
		dive_hud.configure_radar(state.get_radar_range(), state.get_radar_module_name(), 1 + state.get_upgrade_level(&"sonar_module"))
		if bonus_canisters > 0:
			dive_hud.show_feedback("Loadout actif : +%ds O2" % (bonus_canisters * 25), 3.0)


func _return_to_station() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	get_tree().change_scene_to_file(STATION_SCENE_PATH)
