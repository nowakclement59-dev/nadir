class_name InventorySystem
extends Node

signal inventory_changed(used_slots: int, max_slots: int)
signal inventory_full(item: LootItemData)

@export var max_slots: int = 6

var items: Array[LootItemData] = []
var used_slots: int = 0


func can_add(item: LootItemData) -> bool:
	if item == null:
		return false
	return used_slots + maxi(item.slot_cost, 1) <= max_slots


func try_add(item: LootItemData) -> bool:
	if item == null:
		return false
	var cost: int = maxi(item.slot_cost, 1)
	if used_slots + cost > max_slots:
		inventory_full.emit(item)
		return false
	items.append(item)
	used_slots += cost
	inventory_changed.emit(used_slots, max_slots)
	return true


func get_total_value() -> int:
	var total: int = 0
	for item: LootItemData in items:
		total += item.credit_value
	return total


func get_items_summary() -> String:
	if items.is_empty():
		return "Aucun débris récupéré lors de cette plongée."
	var lines: PackedStringArray = PackedStringArray()
	for item: LootItemData in items:
		lines.append("• %s (+%d ¤)" % [item.display_name, item.credit_value])
	return "\n".join(lines)


func clear_inventory() -> void:
	items.clear()
	used_slots = 0
	inventory_changed.emit(used_slots, max_slots)
