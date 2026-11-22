class_name StationUI
extends CanvasLayer

signal launch_dive_requested
signal explore_base_requested

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


func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	if home_tab_button != null:
		home_tab_button.pressed.connect(func() -> void: set_active_tab(Tab.HOME))
	if upgrades_tab_button != null:
		upgrades_tab_button.pressed.connect(func() -> void: set_active_tab(Tab.UPGRADES))
	if trade_tab_button != null:
		trade_tab_button.pressed.connect(func() -> void: set_active_tab(Tab.TRADE))
	if base_3d_button != null:
		base_3d_button.disabled = true
		base_3d_button.text = "EXPLORER BASE 3D (Étape 3)"
		base_3d_button.pressed.connect(func() -> void: explore_base_requested.emit())
	if launch_dive_button != null:
		launch_dive_button.pressed.connect(func() -> void: launch_dive_requested.emit())
	var state: GameStateService = GameStateService.from(self)
	if state != null:
		state.state_changed.connect(refresh)
	refresh()


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


func _update_tab_buttons() -> void:
	var pairs: Array[Array] = [
		[home_tab_button, Tab.HOME],
		[upgrades_tab_button, Tab.UPGRADES],
		[trade_tab_button, Tab.TRADE],
	]
	for pair: Array in pairs:
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
