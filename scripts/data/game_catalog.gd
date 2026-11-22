class_name GameCatalog
extends RefCounted

const LOOT_PATHS: Array[String] = [
	"res://resources/loot/alloy_scrap.tres",
	"res://resources/loot/data_core.tres",
	"res://resources/loot/bio_sample.tres",
]

const UPGRADE_PATHS: Array[String] = [
	"res://resources/upgrades/oxygen_tank.tres",
	"res://resources/upgrades/hydro_fins.tres",
	"res://resources/upgrades/sonar_module.tres",
	"res://resources/upgrades/trade_terminal.tres",
]

const TRADE_OFFER_PATHS: Array[String] = [
	"res://resources/trade/o2_canister_offer.tres",
	"res://resources/trade/alloy_pack_offer.tres",
	"res://resources/trade/data_core_offer.tres",
	"res://resources/trade/stealth_skin_offer.tres",
]


static func get_loot_items() -> Array[LootItemData]:
	var result: Array[LootItemData] = []
	for path: String in LOOT_PATHS:
		var item: LootItemData = load(path) as LootItemData
		if item != null:
			result.append(item)
	return result


static func get_upgrades() -> Array[UpgradeData]:
	var result: Array[UpgradeData] = []
	for path: String in UPGRADE_PATHS:
		var upg: UpgradeData = load(path) as UpgradeData
		if upg != null:
			result.append(upg)
	return result


static func get_trade_offers() -> Array[TradeOfferData]:
	var result: Array[TradeOfferData] = []
	for path: String in TRADE_OFFER_PATHS:
		var offer: TradeOfferData = load(path) as TradeOfferData
		if offer != null:
			result.append(offer)
	return result


static func get_item_display_name(item_id: String) -> String:
	for item: LootItemData in get_loot_items():
		if String(item.id) == item_id:
			return item.display_name
	return item_id


static func get_skin_ids() -> Array[StringName]:
	return [&"scupea_cyan", &"hazard_amber", &"deep_stealth"]


static func get_skin_display_name(skin_id: StringName) -> String:
	match skin_id:
		&"hazard_amber":
			return "Hazard Orange"
		&"deep_stealth":
			return "Deep Stealth"
		_:
			return "SCUPEA Standard"
