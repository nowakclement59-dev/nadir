class_name StationUIHelpers
extends RefCounted

const TEXT_WHITE: Color = Color(0.96, 0.99, 1.0, 1.0)
const TEXT_MUTED: Color = Color(0.76, 0.88, 0.96, 1.0)
const ACCENT_CYAN: Color = Color(0.24, 0.84, 1.0, 0.95)
const ACCENT_OK: Color = Color(0.25, 0.96, 0.68, 1.0)
const BORDER_CYAN: Color = Color(0.24, 0.84, 1.0, 0.34)


static func make_card(border_color: Color = BORDER_CYAN, margin: int = 10) -> PanelContainer:
	var panel: PanelContainer = PanelContainer.new()
	var style: StyleBoxFlat = StyleBoxFlat.new()
	style.bg_color = Color(0.014, 0.042, 0.078, 0.62)
	style.border_color = border_color
	style.set_border_width_all(1)
	style.set_corner_radius_all(6)
	style.set_content_margin_all(margin)
	panel.add_theme_stylebox_override("panel", style)
	return panel


static func make_label(text_value: String, font_size: int, color: Color = TEXT_WHITE, expand: bool = false) -> Label:
	var lbl: Label = Label.new()
	lbl.text = text_value
	lbl.add_theme_font_size_override("font_size", font_size)
	lbl.add_theme_color_override("font_color", color)
	if expand:
		lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	return lbl


static func make_section_title(title_text: String) -> Label:
	return make_label(title_text, 12, ACCENT_CYAN)


static func format_upgrade_costs(upgrade: UpgradeData, state: GameStateService, lvl: int, is_max: bool) -> String:
	if is_max:
		return "Statut : Système à capacité maximale"
	var parts: PackedStringArray = PackedStringArray()
	var costs: Dictionary = upgrade.get_material_costs_for_level(lvl)
	for raw_key: Variant in costs.keys():
		var item_key: String = str(raw_key)
		parts.append("%s %d/%d" % [GameCatalog.get_item_display_name(item_key), state.get_item_count(StringName(item_key)), int(costs[raw_key])])
	var credit_cost: int = upgrade.get_credit_cost_for_level(lvl)
	if credit_cost > 0:
		parts.append("%d ¤" % credit_cost)
	return "Coût : " + "  •  ".join(parts)


static func make_upgrade_card(upgrade: UpgradeData, state: GameStateService, on_buy: Callable) -> PanelContainer:
	var lvl: int = state.get_upgrade_level(upgrade.upgrade_id)
	var is_max: bool = lvl >= upgrade.max_level
	var is_term: bool = upgrade.upgrade_id == &"trade_terminal"
	var card: PanelContainer = make_card()
	var vbox: VBoxContainer = VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 5)
	card.add_child(vbox)
	var head: HBoxContainer = HBoxContainer.new()
	vbox.add_child(head)
	head.add_child(make_label(upgrade.display_name, 13, TEXT_WHITE, true))
	var badge_txt: String = "OPÉRATIONNEL" if (is_term and is_max) else ("MAX" if is_max else "NIV. %d / %d" % [lvl, upgrade.max_level])
	head.add_child(make_label(badge_txt, 11, ACCENT_OK if is_max else ACCENT_CYAN))
	var desc: Label = make_label(upgrade.description, 11, TEXT_MUTED)
	desc.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	vbox.add_child(desc)
	var foot: HBoxContainer = HBoxContainer.new()
	foot.add_theme_constant_override("separation", 10)
	vbox.add_child(foot)
	foot.add_child(make_label(format_upgrade_costs(upgrade, state, lvl, is_max), 11, TEXT_WHITE, true))
	var btn: Button = Button.new()
	btn.custom_minimum_size = Vector2(104.0, 30.0)
	btn.text = "MAX" if is_max else ("RÉPARER" if is_term else "AMÉLIORER")
	btn.disabled = is_max or not state.can_afford_upgrade(upgrade)
	btn.pressed.connect(func() -> void: on_buy.call(upgrade))
	foot.add_child(btn)
	return card
