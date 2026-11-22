class_name GameStateService
extends Node

signal state_changed
signal upgrade_purchased(upgrade_id: StringName, new_level: int)

const DEFAULT_SAVE_PATH: String = "user://save_nadir.json"
const DEFAULT_SKINS: Array[String] = ["scupea_cyan", "hazard_amber"]
const BONUS_CYCLE: Array[StringName] = [&"bio_sample", &"data_core", &"alloy_scrap"]
const BASE_OXYGEN: float = 60.0
const OXYGEN_PER_LEVEL: float = 30.0
const BASE_SWIM_SPEED: float = 5.5
const SWIM_BONUS_RATIO: float = 0.15
const BASE_RADAR_RANGE: float = 35.0
const RADAR_PER_LEVEL: float = 15.0

var save_path: String = DEFAULT_SAVE_PATH
var stash_items: Dictionary = {}
var credits: int = 0
var upgrade_levels: Dictionary = {}
var dives_completed: int = 0
var dives_lost: int = 0
var selected_skin_id: StringName = &"scupea_cyan"
var unlocked_skins: Array[String] = DEFAULT_SKINS.duplicate()
var loadout_o2_canisters: int = 0
var last_run_report: Dictionary = {}

static func from(node: Node) -> GameStateService:
	return (node.get_node_or_null("/root/GameState") as GameStateService) if (node != null and node.is_inside_tree()) else null
func _ready() -> void: load_game()
func set_last_run_report(outcome: String, summary: String, total_value: int, item_count: int) -> void:
	last_run_report = {"outcome": outcome, "summary": summary, "total_value": total_value, "item_count": item_count}
func clear_last_run_report() -> void: last_run_report.clear()
func get_item_count(item_id: StringName) -> int: return int(stash_items.get(String(item_id), 0))
func get_upgrade_level(upgrade_id: StringName) -> int: return int(upgrade_levels.get(String(upgrade_id), 0))
func is_trade_terminal_repaired() -> bool: return get_upgrade_level(&"trade_terminal") >= 1
func is_skin_unlocked(skin_id: StringName) -> bool: return unlocked_skins.has(String(skin_id))
func get_bonus_sell_item_id() -> StringName: return BONUS_CYCLE[dives_completed % BONUS_CYCLE.size()]
func get_sell_price(item: LootItemData) -> int:
	return (roundi(float(item.credit_value) * 1.3) if item.id == get_bonus_sell_item_id() else item.credit_value) if item != null else 0
func get_max_oxygen() -> float: return BASE_OXYGEN + OXYGEN_PER_LEVEL * float(get_upgrade_level(&"oxygen_tank"))
func get_swim_speed() -> float: return BASE_SWIM_SPEED * (1.0 + SWIM_BONUS_RATIO * float(get_upgrade_level(&"hydro_fins")))
func get_radar_range() -> float: return BASE_RADAR_RANGE + RADAR_PER_LEVEL * float(get_upgrade_level(&"sonar_module"))
func get_radar_module_name() -> String: return "BATHYS-S%d" % (1 + get_upgrade_level(&"sonar_module"))

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
	dives_lost += 1; save_game(); state_changed.emit()

func can_afford_upgrade(upgrade: UpgradeData) -> bool:
	if upgrade == null or upgrade.upgrade_id.is_empty(): return false
	var lvl: int = get_upgrade_level(upgrade.upgrade_id)
	if lvl >= upgrade.max_level or credits < upgrade.get_credit_cost_for_level(lvl): return false
	var costs: Dictionary = upgrade.get_material_costs_for_level(lvl)
	for raw_key: Variant in costs.keys():
		if int(stash_items.get(str(raw_key), 0)) < int(costs[raw_key]): return false
	return true

func try_purchase_upgrade(upgrade: UpgradeData) -> bool:
	if not can_afford_upgrade(upgrade): return false
	var lvl: int = get_upgrade_level(upgrade.upgrade_id)
	var costs: Dictionary = upgrade.get_material_costs_for_level(lvl)
	for raw_key: Variant in costs.keys(): _consume_stash_item(str(raw_key), int(costs[raw_key]))
	credits -= upgrade.get_credit_cost_for_level(lvl)
	var new_level: int = lvl + 1
	upgrade_levels[String(upgrade.upgrade_id)] = new_level
	save_game(); upgrade_purchased.emit(upgrade.upgrade_id, new_level); state_changed.emit()
	return true

func sell_stash_item(item: LootItemData, quantity: int = 1) -> bool:
	if not is_trade_terminal_repaired() or item == null or item.id.is_empty() or quantity <= 0: return false
	var key: String = String(item.id)
	if int(stash_items.get(key, 0)) < quantity: return false
	_consume_stash_item(key, quantity); credits += get_sell_price(item) * quantity
	save_game(); state_changed.emit()
	return true

func can_buy_trade_offer(offer: TradeOfferData) -> bool:
	if not is_trade_terminal_repaired() or offer == null or credits < offer.price_credits: return false
	return not (offer.grant_type == &"skin" and is_skin_unlocked(offer.target_id))

func try_buy_trade_offer(offer: TradeOfferData) -> bool:
	if not can_buy_trade_offer(offer): return false
	credits -= offer.price_credits
	if offer.grant_type == &"skin": unlocked_skins.append(String(offer.target_id))
	else: stash_items[String(offer.target_id)] = get_item_count(offer.target_id) + maxi(offer.grant_quantity, 1)
	save_game()
	state_changed.emit()
	return true

func select_skin(skin_id: StringName) -> bool:
	if not is_skin_unlocked(skin_id): return false
	selected_skin_id = skin_id
	save_game()
	state_changed.emit()
	return true

func set_loadout_o2_canisters(count: int) -> void:
	loadout_o2_canisters = clampi(count, 0, mini(2, get_item_count(&"o2_canister")))
	save_game()
	state_changed.emit()

func consume_equipped_loadout_for_dive() -> int:
	var used: int = mini(loadout_o2_canisters, get_item_count(&"o2_canister"))
	loadout_o2_canisters = 0
	if used > 0: _consume_stash_item("o2_canister", used)
	save_game()
	return used

func save_game() -> bool:
	return SaveStore.save_json(save_path, {"credits": credits, "dives_completed": dives_completed, "dives_lost": dives_lost, "stash_items": stash_items, "upgrade_levels": upgrade_levels, "selected_skin_id": String(selected_skin_id), "unlocked_skins": unlocked_skins, "loadout_o2_canisters": loadout_o2_canisters})

func load_game() -> bool:
	var data: Dictionary = SaveStore.load_json(save_path)
	if data.is_empty(): return false
	credits = int(data.get("credits", 0)); dives_completed = int(data.get("dives_completed", 0)); dives_lost = int(data.get("dives_lost", 0))
	stash_items = SaveStore.parse_int_dict(data.get("stash_items", {}))
	upgrade_levels = SaveStore.parse_int_dict(data.get("upgrade_levels", {}))
	unlocked_skins = SaveStore.parse_string_array(data.get("unlocked_skins", []), DEFAULT_SKINS)
	var saved_skin: StringName = StringName(str(data.get("selected_skin_id", "scupea_cyan")))
	selected_skin_id = saved_skin if is_skin_unlocked(saved_skin) else &"scupea_cyan"
	loadout_o2_canisters = clampi(int(data.get("loadout_o2_canisters", 0)), 0, mini(2, get_item_count(&"o2_canister")))
	state_changed.emit()
	return true

func reset_progress(delete_file: bool = false) -> void:
	stash_items.clear(); upgrade_levels.clear(); last_run_report.clear(); credits = 0; dives_completed = 0; dives_lost = 0; loadout_o2_canisters = 0
	selected_skin_id = &"scupea_cyan"; unlocked_skins = DEFAULT_SKINS.duplicate()
	if delete_file: SaveStore.delete_file(save_path)
	state_changed.emit()

func _consume_stash_item(item_key: String, quantity: int) -> void:
	var remaining: int = int(stash_items.get(item_key, 0)) - quantity
	if remaining <= 0: stash_items.erase(item_key)
	else: stash_items[item_key] = remaining
