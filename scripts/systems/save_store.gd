class_name SaveStore
extends RefCounted


static func save_json(path: String, payload: Dictionary) -> bool:
	var file: FileAccess = FileAccess.open(path, FileAccess.WRITE)
	if file == null:
		return false
	file.store_string(JSON.stringify(payload, "\t"))
	return true


static func load_json(path: String) -> Dictionary:
	if not FileAccess.file_exists(path):
		return {}
	var file: FileAccess = FileAccess.open(path, FileAccess.READ)
	if file == null:
		return {}
	var parsed: Variant = JSON.parse_string(file.get_as_text())
	return (parsed as Dictionary) if parsed is Dictionary else {}


static func delete_file(path: String) -> void:
	if FileAccess.file_exists(path):
		DirAccess.remove_absolute(ProjectSettings.globalize_path(path))


static func parse_int_dict(raw: Variant) -> Dictionary:
	var result: Dictionary = {}
	if raw is Dictionary:
		var src: Dictionary = raw as Dictionary
		for key: Variant in src.keys():
			var amount: int = int(src[key])
			if amount > 0:
				result[str(key)] = amount
	return result


static func parse_string_array(raw: Variant, defaults: Array[String]) -> Array[String]:
	var result: Array[String] = defaults.duplicate()
	if raw is Array:
		for entry: Variant in (raw as Array):
			var text: String = str(entry)
			if not text.is_empty() and not result.has(text):
				result.append(text)
	return result
