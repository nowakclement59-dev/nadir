class_name UpgradeData
extends Resource

@export var upgrade_id: StringName = &""
@export var display_name: String = ""
@export var description: String = ""
@export var max_level: int = 3
@export var base_material_costs: Dictionary = {}
@export var credit_cost_per_level: int = 0


func get_material_costs_for_level(current_level: int) -> Dictionary:
	if current_level >= max_level:
		return {}
	var multiplier: int = maxi(current_level + 1, 1)
	var costs: Dictionary = {}
	for raw_key: Variant in base_material_costs.keys():
		var item_key: String = str(raw_key)
		var base_qty: int = int(base_material_costs.get(raw_key, 0))
		if base_qty > 0:
			costs[item_key] = base_qty * multiplier
	return costs


func get_credit_cost_for_level(current_level: int) -> int:
	if current_level >= max_level:
		return 0
	return credit_cost_per_level * maxi(current_level + 1, 1)
