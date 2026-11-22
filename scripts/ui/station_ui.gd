class_name StationUI
extends CanvasLayer

signal launch_dive_requested
signal explore_base_requested
signal overlay_closed

enum Tab { HOME, UPGRADES, TRADE }

@export var credits_label: Label
@export var home_tab_button: Button
@export var upgrades_tab_button: Button
@export var trade_tab_button: Button
@export var tab_content: VBoxContainer
@export var feedback_label: Label
@export var base_3d_button: Button
@export var launch_dive_button: Button

var active_tab: int = Tab.HOME
var _is_base_overlay: bool = false


func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	for pair: Array in _tab_pairs():
		var btn: Button = pair[0] as Button
		var tab_idx: int = int(pair[1])
		if btn != null:
			btn.pressed.connect(func() -> void: set_active_tab(tab_idx))
	if base_3d_button != null:
		base_3d_button.disabled = false
		base_3d_button.text = "EXPLORER LA BASE 3D"
		base_3d_button.pressed.connect(_on_base_3d_pressed)
	if launch_dive_button != null:
		launch_dive_button.pressed.connect(func() -> void: launch_dive_requested.emit())
	var state: GameStateService = GameStateService.from(self)
	if state != null:
		state.state_changed.connect(refresh)
	refresh()


func _unhandled_input(_event: InputEvent) -> void:
	if _is_base_overlay and visible and Input.is_action_just_pressed(&"pause"):
		close_overlay()
		get_viewport().set_input_as_handled()


func configure_mode(is_overlay_in_base: bool) -> void:
	_is_base_overlay = is_overlay_in_base
	visible = not is_overlay_in_base
	if is_overlay_in_base:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	if base_3d_button != null:
		base_3d_button.visible = true
		base_3d_button.disabled = false
		base_3d_button.text = "REPRENDRE EXPLORATION [Tab]" if is_overlay_in_base else "EXPLORER LA BASE 3D"


func open_tab(tab_index: int) -> void:
	visible = true
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	set_active_tab(tab_index)


func close_overlay() -> void:
	visible = false
	overlay_closed.emit()


func is_overlay_open() -> bool:
	return visible


func _on_base_3d_pressed() -> void:
	if _is_base_overlay:
		close_overlay()
	else:
		explore_base_requested.emit()


func set_active_tab(tab_index: int) -> void:
	active_tab = tab_index
	if feedback_label != null:
		feedback_label.text = ""
	refresh()


func refresh() -> void:
	var state: GameStateService = GameStateService.from(self)
	if state == null:
		return
	if credits_label != null:
		credits_label.text = "%d ¤" % state.credits
	_update_tab_buttons()
	if tab_content == null:
		return
	for child: Node in tab_content.get_children():
		tab_content.remove_child(child)
		child.queue_free()
	match active_tab:
		Tab.UPGRADES:
			StationTabBuilders.build_upgrades_tab(tab_content, state, _on_buy_upgrade)
		Tab.TRADE:
			StationTabBuilders.build_trade_tab(tab_content, state, _on_sell_item, _on_buy_offer)
		_:
			StationTabBuilders.build_home_tab(tab_content, state, _on_select_skin, _on_set_canisters)


func _tab_pairs() -> Array[Array]:
	return [[home_tab_button, Tab.HOME], [upgrades_tab_button, Tab.UPGRADES], [trade_tab_button, Tab.TRADE]]

func _update_tab_buttons() -> void:
	for pair: Array in _tab_pairs():
		var btn: Button = pair[0] as Button
		if btn != null:
			btn.disabled = (int(pair[1]) == active_tab)

func _on_select_skin(skin_id: StringName) -> void:
	var state: GameStateService = GameStateService.from(self)
	if state != null and state.select_skin(skin_id):
		_set_feedback("Apparence appliquée : %s" % GameCatalog.get_skin_display_name(skin_id), StationUIHelpers.ACCENT_CYAN)

func _on_set_canisters(count: int) -> void:
	var state: GameStateService = GameStateService.from(self)
	if state != null:
		state.set_loadout_o2_canisters(count)
		_set_feedback("Loadout O2 mis à jour (%d / 2)" % state.loadout_o2_canisters, StationUIHelpers.ACCENT_CYAN)

func _on_buy_upgrade(upgrade: UpgradeData) -> void:
	var state: GameStateService = GameStateService.from(self)
	if state != null and state.try_purchase_upgrade(upgrade):
		_set_feedback("Installé : %s (Niv. %d)" % [upgrade.display_name, state.get_upgrade_level(upgrade.upgrade_id)], StationUIHelpers.ACCENT_OK)

func _on_sell_item(item: LootItemData) -> void:
	var state: GameStateService = GameStateService.from(self)
	if state != null:
		var price: int = state.get_sell_price(item)
		if state.sell_stash_item(item, 1):
			_set_feedback("Vendu : %s (+%d ¤)" % [item.display_name, price], StationUIHelpers.ACCENT_CYAN)

func _on_buy_offer(offer: TradeOfferData) -> void:
	var state: GameStateService = GameStateService.from(self)
	if state != null and state.try_buy_trade_offer(offer):
		_set_feedback("Commande livrée : %s" % offer.display_name, StationUIHelpers.ACCENT_OK)

func _set_feedback(msg: String, color: Color) -> void:
	if feedback_label != null:
		feedback_label.text = msg
		feedback_label.modulate = color
