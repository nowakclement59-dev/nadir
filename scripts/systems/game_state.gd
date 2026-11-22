class_name GameStateService
extends Node

signal state_changed
signal upgrade_purchased(upgrade_id: StringName, new_level: int)

const DEFAULT_SAVE_PATH: String = "user://save_nadir.json"
const BASE_OXYGEN_SECONDS: float = 60.0
const OXYGEN_BONUS_PER_LEVEL: float = 30.0
const BASE_SWIM_SPEED: float = 5.5
const SWIM_SPEED_BONUS_RATIO: float = 0.15
const BASE_RADAR_RANGE: float = 35.0
const RADAR_BONUS_PER_LEVEL: float = 15.0

var save_path: String = DEFAULT_SAVE_PATH
var stash_items: Dictionary = {}
var credits: int = 0
var upgrade_levels: Dictionary = {}
var dives_completed: int = 0
var dives_lost: int = 0

static func from(node: Node) -> GameStateService:
	if node == null or not node.is_inside_tree():
		return null
	return node.get_node_or_null("/root/GameState") as GameStateService

func _ready() -> void:
	load_game()

func deposit_run_loot(items: Array[LootItemData]) -> Dictionary:
	dives_completed += 1
	var estimated_value: int = 0
	var count: int = 0
	for item: LootItemData in items:
		if item != null and not item.id.is_empty():
			var key: String = String(item.id)
			stash_items[key] = int(stash_items.get(key, 0)) + 1
			estimated_value += item.credit_value
			count += 1
	save_game()
	state_changed.emit()
	return {"count": count, "estimated_value": estimated_value}

func record_dive_loss() -> void:
	dives_lost += 1
	save_game()
	state_changed.emit()

func get_item_count(item_id: StringName) -> int:
	return int(stash_items.get(String(item_id), 0))
func get_upgrade_level(upgrade_id: StringName) -> int:
	return int(upgrade_levels.get(String(upgrade_id), 0))
func is_trade_terminal_repaired() -> bool:
	return get_upgrade_level(&"trade_terminal") >= 1
func get_max_oxygen() -> float:
	return BASE_OXYGEN_SECONDS + OXYGEN_BONUS_PER_LEVEL * float(get_upgrade_level(&"oxygen_tank"))
func get_swim_speed() -> float:
	return BASE_SWIM_SPEED * (1.0 + SWIM_SPEED_BONUS_RATIO * float(get_upgrade_level(&"hydro_fins")))
func get_radar_range() -> float:
	return BASE_RADAR_RANGE + RADAR_BONUS_PER_LEVEL * float(get_upgrade_level(&"sonar_module"))
func get_radar_module_name() -> String:
	return "BATHYS-S%d" % (1 + get_upgrade_level(&"sonar_module"))

func can_afford_upgrade(upgrade: UpgradeData) -> bool:
	if upgrade == null or upgrade.upgrade_id.is_empty():
		return false
	var lvl: int = get_upgrade_level(upgrade.upgrade_id)
	if lvl >= upgrade.max_level or credits < upgrade.get_credit_cost_for_level(lvl):
		return false
	var costs: Dictionary = upgrade.get_material_costs_for_level(lvl)
	for raw_key: Variant in costs.keys():
		if int(stash_items.get(str(raw_key), 0)) < int(costs[raw_key]):
			return false
	return true

func try_purchase_upgrade(upgrade: UpgradeData) -> bool:
	if not can_afford_upgrade(upgrade):
		return false
	var lvl: int = get_upgrade_level(upgrade.upgrade_id)
	var costs: Dictionary = upgrade.get_material_costs_for_level(lvl)
	for raw_key: Variant in costs.keys():
		_consume_stash_item(str(raw_key), int(costs[raw_key]))
	credits -= upgrade.get_credit_cost_for_level(lvl)
	var new_level: int = lvl + 1
	upgrade_levels[String(upgrade.upgrade_id)] = new_level
	save_game()
	upgrade_purchased.emit(upgrade.upgrade_id, new_level)
	state_changed.emit()
	return true

func sell_stash_item(item: LootItemData, quantity: int = 1) -> bool:
	if not is_trade_terminal_repaired() or item == null or item.id.is_empty() or quantity <= 0:
		return false
	var key: String = String(item.id)
	if int(stash_items.get(key, 0)) < quantity:
		return false
	_consume_stash_item(key, quantity)
	credits += item.credit_value * quantity
	save_game()
	state_changed.emit()
	return true

func save_game() -> bool:
	var file: FileAccess = FileAccess.open(save_path, FileAccess.WRITE)
	if file == null:
		return false
	file.store_string(JSON.stringify({"credits": credits, "dives_completed": dives_completed, "dives_lost": dives_lost, "stash_items": stash_items, "upgrade_levels": upgrade_levels}, "\t"))
	return true

func load_game() -> bool:
	var file: FileAccess = FileAccess.open(save_path, FileAccess.READ) if FileAccess.file_exists(save_path) else null
	var parsed: Variant = JSON.parse_string(file.get_as_text()) if file != null else null
	if not parsed is Dictionary:
		return false
	var data: Dictionary = parsed as Dictionary
	credits = int(data.get("credits", 0))
	dives_completed = int(data.get("dives_completed", 0))
	dives_lost = int(data.get("dives_lost", 0))
	stash_items = _parse_int_dict(data.get("stash_items", {}))
	upgrade_levels = _parse_int_dict(data.get("upgrade_levels", {}))
	state_changed.emit()
	return true

func reset_progress(delete_file: bool = false) -> void:
	stash_items.clear()
	upgrade_levels.clear()
	credits = 0
	dives_completed = 0
	dives_lost = 0
	if delete_file and FileAccess.file_exists(save_path):
		DirAccess.remove_absolute(ProjectSettings.globalize_path(save_path))
	state_changed.emit()

func _consume_stash_item(item_key: String, quantity: int) -> void:
	var remaining: int = int(stash_items.get(item_key, 0)) - quantity
	if remaining <= 0:
		stash_items.erase(item_key)
		return
	stash_items[item_key] = remaining

func _parse_int_dict(raw: Variant) -> Dictionary:
	var result: Dictionary = {}
	if raw is Dictionary:
		for key: Variant in (raw as Dictionary).keys():
			var amount: int = int((raw as Dictionary)[key])
			if amount > 0:
				result[str(key)] = amount
	return result
