class_name LootPickup
extends Area3D

@export var item_data: LootItemData


func get_prompt_text() -> String:
	if item_data == null:
		return "[E] Récupérer l'objet"
	var cost: int = maxi(item_data.slot_cost, 1)
	var suffix: String = "s" if cost > 1 else ""
	return "[E] Récupérer : %s (%d ¤ | %d slot%s)" % [
		item_data.display_name,
		item_data.credit_value,
		cost,
		suffix,
	]


func collect() -> void:
	queue_free()
