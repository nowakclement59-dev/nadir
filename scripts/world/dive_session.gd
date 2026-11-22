class_name DiveSession
extends Node3D

@export_group("References")
@export var diver: DiverController
@export var oxygen_system: OxygenSystem
@export var health_system: HealthSystem
@export var inventory_system: InventorySystem
@export var dive_hud: DiveHUD

@export_group("Environment")
@export var surface_reference_y: float = 123.0


func _ready() -> void:
	if diver != null:
		diver.interact_requested.connect(_on_interact_requested)
	if oxygen_system != null:
		oxygen_system.oxygen_changed.connect(_on_oxygen_changed)
		oxygen_system.suffocation_changed.connect(_on_suffocation_changed)
		oxygen_system.suffocated.connect(_on_oxygen_suffocated)
	if health_system != null:
		health_system.health_changed.connect(_on_health_changed)
		health_system.died.connect(_on_health_died)
	if inventory_system != null:
		inventory_system.inventory_changed.connect(_on_inventory_changed)
		inventory_system.inventory_full.connect(_on_inventory_full)
	if dive_hud != null:
		dive_hud.restart_requested.connect(_on_restart_requested)
		if oxygen_system != null:
			dive_hud.update_oxygen(oxygen_system.current_oxygen, oxygen_system.max_oxygen)
		if health_system != null:
			dive_hud.update_health(health_system.current_health, health_system.max_health)
		if inventory_system != null:
			dive_hud.update_inventory(inventory_system.used_slots, inventory_system.max_slots)


func _process(_delta: float) -> void:
	if diver == null:
		return
	if oxygen_system != null:
		oxygen_system.is_sprinting = diver.is_sprinting_active()
	if dive_hud != null:
		var depth_meters: float = maxf(0.0, surface_reference_y - diver.global_position.y)
		var forward: Vector3 = -diver.global_basis.z
		var heading_degrees: float = rad_to_deg(atan2(forward.x, -forward.z))
		dive_hud.update_navigation(heading_degrees, depth_meters, diver.global_position, diver.rotation.y)
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
	if diver != null:
		diver.set_movement_enabled(false)
	if oxygen_system != null:
		oxygen_system.is_active = false
	if dive_hud != null:
		var summary: String = inventory_system.get_items_summary() if inventory_system != null else ""
		var total: int = inventory_system.get_total_value() if inventory_system != null else 0
		dive_hud.show_extraction_screen(summary, total)


func _on_oxygen_changed(current: float, maximum: float) -> void:
	if dive_hud != null:
		dive_hud.update_oxygen(current, maximum)


func _on_suffocation_changed(progress: float) -> void:
	if dive_hud != null:
		dive_hud.update_suffocation(progress)


func _on_health_changed(current: float, maximum: float) -> void:
	if dive_hud != null:
		dive_hud.update_health(current, maximum)


func _on_inventory_changed(used_slots: int, max_slots: int) -> void:
	if dive_hud != null:
		dive_hud.update_inventory(used_slots, max_slots)


func _on_inventory_full(_item: LootItemData) -> void:
	if dive_hud != null:
		dive_hud.show_feedback("CARGO PLEIN — Retournez au sas d'extraction", 2.2)


func _on_oxygen_suffocated() -> void:
	_on_player_died("Asphyxie — Réserves d'oxygène épuisées dans les abysses.")


func _on_health_died() -> void:
	_on_player_died("Intégrité vitale perdue — Combinaison détruite.")


func _on_player_died(reason: String) -> void:
	if inventory_system != null:
		inventory_system.clear_inventory()
	if diver != null:
		diver.set_movement_enabled(false)
	if oxygen_system != null:
		oxygen_system.is_active = false
	if dive_hud != null:
		dive_hud.show_death_screen(reason + "\n\nButin perdu dans les abysses.")


func _on_restart_requested() -> void:
	get_tree().reload_current_scene()
