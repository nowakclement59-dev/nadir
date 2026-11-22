class_name BaseInteractable
extends Area3D

## Zone d'interaction générique détectable par le rayon du contrôleur en station.

@export var interact_id: StringName = &""
@export var prompt_text: String = "[E] Interagir"


func get_prompt_text() -> String:
	return prompt_text
