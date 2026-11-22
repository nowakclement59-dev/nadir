class_name BaseHUD
extends CanvasLayer

signal lore_closed

@export var prompt_label: Label
@export var hud_root: Control
@export var lore_overlay: Control
@export var lore_title_label: Label
@export var lore_body_label: Label
@export var lore_close_button: Button


func _ready() -> void:
	if prompt_label != null:
		prompt_label.visible = false
	if lore_overlay != null:
		lore_overlay.visible = false
	if lore_close_button != null:
		lore_close_button.pressed.connect(hide_lore_entry)


func _unhandled_input(_event: InputEvent) -> void:
	if is_lore_open() and Input.is_action_just_pressed(&"pause"):
		hide_lore_entry()
		get_viewport().set_input_as_handled()


func update_prompt(text: String) -> void:
	if prompt_label == null:
		return
	prompt_label.text = text
	prompt_label.visible = not text.is_empty()


func show_lore_entry(title: String, body: String) -> void:
	if lore_title_label != null:
		lore_title_label.text = title
	if lore_body_label != null:
		lore_body_label.text = body
	if prompt_label != null:
		prompt_label.visible = false
	if lore_overlay != null:
		lore_overlay.visible = true


func hide_lore_entry() -> void:
	if lore_overlay != null and not lore_overlay.visible:
		return
	if lore_overlay != null:
		lore_overlay.visible = false
	lore_closed.emit()


func is_lore_open() -> bool:
	return lore_overlay != null and lore_overlay.visible


func set_hud_visible(show_hud: bool) -> void:
	if hud_root != null:
		hud_root.visible = show_hud
