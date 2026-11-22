class_name StationTabBuilders
extends RefCounted


static func build_home_tab(container: VBoxContainer, state: GameStateService, on_select_skin: Callable, on_set_canisters: Callable) -> void:
	if not state.last_run_report.is_empty():
		var ok: bool = str(state.last_run_report.get("outcome", "")) == "extracted"
		var border: Color = StationUIHelpers.ACCENT_OK if ok else Color(1.0, 0.42, 0.4, 0.8)
		var card: PanelContainer = StationUIHelpers.make_card(border, 10)
		var box: VBoxContainer = VBoxContainer.new()
		card.add_child(box)
		box.add_child(StationUIHelpers.make_label("● SAS PRESSURISÉ — EXTRACTION RÉUSSIE" if ok else "▲ SAUVETAGE D'URGENCE — BUTIN PERDU", 13, border))
		var body_txt: String = str(state.last_run_report.get("summary", ""))
		if ok:
			body_txt += "\nStock sécurisé en base (valeur estimée : %d ¤)" % int(state.last_run_report.get("total_value", 0))
		var body: Label = StationUIHelpers.make_label(body_txt, 11, StationUIHelpers.TEXT_WHITE)
		body.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		box.add_child(body)
		container.add_child(card)

	var stats_card: PanelContainer = StationUIHelpers.make_card()
	var stats_txt: String = "TÉLÉMÉTRIE SCAPHANDRE\nO2 : %ds  |  Vitesse : %.1f m/s  |  Sonar : %s (%dm)\nPlongées réussies : %d  |  Sauvetages : %d" % [
		roundi(state.get_max_oxygen()), state.get_swim_speed(), state.get_radar_module_name(),
		roundi(state.get_radar_range()), state.dives_completed, state.dives_lost]
	stats_card.add_child(StationUIHelpers.make_label(stats_txt, 12))
	container.add_child(stats_card)

	container.add_child(StationUIHelpers.make_section_title("APPARENCE DU SCAPHANDRE"))
	var skin_card: PanelContainer = StationUIHelpers.make_card()
	var skin_row: HBoxContainer = HBoxContainer.new()
	skin_row.add_theme_constant_override("separation", 8)
	skin_card.add_child(skin_row)
	for skin_id: StringName in GameCatalog.get_skin_ids():
		var unlocked: bool = state.is_skin_unlocked(skin_id)
		var active: bool = skin_id == state.selected_skin_id
		var btn: Button = Button.new()
		btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		btn.custom_minimum_size = Vector2(0.0, 32.0)
		var label_name: String = GameCatalog.get_skin_display_name(skin_id)
		btn.text = ("[ACTIF] " + label_name) if active else (label_name if unlocked else label_name + " [Terminal]")
		btn.disabled = not unlocked or active
		btn.pressed.connect(func() -> void: on_select_skin.call(skin_id))
		skin_row.add_child(btn)
	container.add_child(skin_card)

	container.add_child(StationUIHelpers.make_section_title("LOADOUT DE PLONGÉE"))
	var load_card: PanelContainer = StationUIHelpers.make_card()
	var load_row: HBoxContainer = HBoxContainer.new()
	load_row.add_theme_constant_override("separation", 8)
	load_card.add_child(load_row)
	var owned: int = state.get_item_count(&"o2_canister")
	var equipped: int = state.loadout_o2_canisters
	load_row.add_child(StationUIHelpers.make_label("Cartouche O2 d'urgence (+25s)\nÉquipées : %d / 2   |   Stock : %d" % [equipped, owned], 12, StationUIHelpers.TEXT_WHITE, true))
	for delta: int in [-1, 1]:
		var btn: Button = Button.new()
		btn.text = " - " if delta < 0 else " + "
		btn.custom_minimum_size = Vector2(36.0, 32.0)
		btn.disabled = (equipped <= 0) if delta < 0 else (equipped >= mini(2, owned))
		btn.pressed.connect(func() -> void: on_set_canisters.call(equipped + delta))
		load_row.add_child(btn)
	container.add_child(load_card)


static func build_upgrades_tab(container: VBoxContainer, state: GameStateService, on_buy: Callable) -> void:
	var stock_row: HBoxContainer = HBoxContainer.new()
	stock_row.add_theme_constant_override("separation", 8)
	for item: LootItemData in GameCatalog.get_loot_items():
		var badge: PanelContainer = StationUIHelpers.make_card(item.accent_color.lerp(StationUIHelpers.ACCENT_CYAN, 0.35), 6)
		badge.add_child(StationUIHelpers.make_label("%s : x%d" % [item.display_name, state.get_item_count(item.id)], 11))
		stock_row.add_child(badge)
	container.add_child(stock_row)

	container.add_child(StationUIHelpers.make_section_title("ÉQUIPEMENT DU SCAPHANDRE"))
	var infra_added: bool = false
	for upg: UpgradeData in GameCatalog.get_upgrades():
		if upg.upgrade_id == &"trade_terminal" and not infra_added:
			container.add_child(StationUIHelpers.make_section_title("INFRASTRUCTURE DE LA BASE"))
			infra_added = true
		container.add_child(StationUIHelpers.make_upgrade_card(upg, state, on_buy))


static func build_trade_tab(container: VBoxContainer, state: GameStateService, on_sell: Callable, on_buy_offer: Callable) -> void:
	var online: bool = state.is_trade_terminal_repaired()
	var status_card: PanelContainer = StationUIHelpers.make_card(StationUIHelpers.ACCENT_OK if online else Color(1.0, 0.68, 0.25, 0.8), 8)
	var bonus_id: StringName = state.get_bonus_sell_item_id()
	var status_txt: String = "● LIAISON ORBITALE EN LIGNE  —  Prime (+30%%) : %s" % GameCatalog.get_item_display_name(String(bonus_id)) if online else "▲ TERMINAL HORS SERVICE — Réparez-le dans l'onglet AMÉLIORATIONS"
	status_card.add_child(StationUIHelpers.make_label(status_txt, 12, StationUIHelpers.ACCENT_OK if online else Color(1.0, 0.68, 0.25, 1.0)))
	container.add_child(status_card)

	container.add_child(StationUIHelpers.make_section_title("VENDRE DES SURPLUS"))
	for item: LootItemData in GameCatalog.get_loot_items():
		var owned: int = state.get_item_count(item.id)
		var price: int = state.get_sell_price(item)
		var row: PanelContainer = StationUIHelpers.make_card(StationUIHelpers.BORDER_CYAN, 8)
		var hbox: HBoxContainer = HBoxContainer.new()
		hbox.add_theme_constant_override("separation", 10)
		row.add_child(hbox)
		hbox.add_child(StationUIHelpers.make_label("%s (x%d)" % [item.display_name, owned], 12, StationUIHelpers.TEXT_WHITE, true))
		hbox.add_child(StationUIHelpers.make_label("+%d ¤%s" % [price, " [+30%]" if item.id == bonus_id else ""], 12, StationUIHelpers.ACCENT_CYAN))
		var btn: Button = Button.new()
		btn.text = "VENDRE x1"
		btn.custom_minimum_size = Vector2(96.0, 30.0)
		btn.disabled = not online or owned <= 0
		btn.pressed.connect(func() -> void: on_sell.call(item))
		hbox.add_child(btn)
		container.add_child(row)

	container.add_child(StationUIHelpers.make_section_title("COMMANDER VIA LIAISON ORBITALE"))
	for offer: TradeOfferData in GameCatalog.get_trade_offers():
		var card: PanelContainer = StationUIHelpers.make_card(StationUIHelpers.BORDER_CYAN, 8)
		var hbox: HBoxContainer = HBoxContainer.new()
		hbox.add_theme_constant_override("separation", 10)
		card.add_child(hbox)
		var info: Label = StationUIHelpers.make_label("%s\n%s" % [offer.display_name, offer.description], 11, StationUIHelpers.TEXT_WHITE, true)
		info.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		hbox.add_child(info)
		hbox.add_child(StationUIHelpers.make_label("%d ¤" % offer.price_credits, 12, StationUIHelpers.ACCENT_CYAN))
		var unlocked_skin: bool = offer.grant_type == &"skin" and state.is_skin_unlocked(offer.target_id)
		var buy_btn: Button = Button.new()
		buy_btn.custom_minimum_size = Vector2(96.0, 30.0)
		buy_btn.text = "DÉBLOQUÉ" if unlocked_skin else "ACHETER"
		buy_btn.disabled = unlocked_skin or not state.can_buy_trade_offer(offer)
		buy_btn.pressed.connect(func() -> void: on_buy_offer.call(offer))
		hbox.add_child(buy_btn)
		container.add_child(card)
