extends GridContainer
## Read-only resource/status overview; confirmed and draft values stay separate.
const UI = preload("res://scripts/ui/ui_style.gd")
const IDS := ["energy", "oxygen", "food"]
const LABELS := {"energy": "Power", "oxygen": "Oxygen", "food": "Food"}
const COLORS := {"energy": UI.AMBER, "oxygen": UI.CYAN, "food": UI.GREEN}
var _cards: Dictionary = {}
var _life_food: Label
var _shield_panel: PanelContainer
var _shield_label: Label
var _shield_detail: Label

class ResourceIcon extends Control:
	var resource_id := ""
	var ink := Color.WHITE
	func _init(id: String, tint: Color) -> void:
		resource_id = id
		ink = tint
		custom_minimum_size = Vector2(28, 28)
		mouse_filter = Control.MOUSE_FILTER_IGNORE
	func _draw() -> void:
		match resource_id:
			"energy":
				draw_colored_polygon(PackedVector2Array([Vector2(16,2),Vector2(6,16),Vector2(13,16),Vector2(11,26),Vector2(23,11),Vector2(16,11)]), ink)
			"oxygen":
				draw_arc(Vector2(14,14),10,0,TAU,32,ink,3,true)
				draw_line(Vector2(10,14),Vector2(18,14),ink,2,true)
				draw_line(Vector2(14,10),Vector2(14,18),ink,2,true)
			"food":
				draw_line(Vector2(13,25),Vector2(13,9),ink,2,true)
				draw_colored_polygon(PackedVector2Array([Vector2(13,16),Vector2(3,11),Vector2(3,4),Vector2(11,7)]),ink)
				draw_colored_polygon(PackedVector2Array([Vector2(14,20),Vector2(24,13),Vector2(24,5),Vector2(16,10)]),ink)
			"shield":
				draw_polyline(PackedVector2Array([Vector2(14,2),Vector2(25,7),Vector2(22,19),Vector2(14,27),Vector2(6,19),Vector2(3,7),Vector2(14,2)]),ink,2,true)

func _init() -> void:
	custom_minimum_size.x = 280
	size_flags_horizontal = Control.SIZE_EXPAND_FILL
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_theme_constant_override("h_separation", 10)
	add_theme_constant_override("v_separation", 8)
	UI.use_korean_theme(self)
	for id: String in IDS:
		var panel := UI.panel(self, UI.CARD, 10)
		panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		var body := UI.column(panel, 4)
		var heading := UI.row(body, 8)
		heading.add_child(ResourceIcon.new(id, COLORS[id]))
		var title := UI.label(heading, LABELS[id], 18)
		title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		title.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		var current := UI.label(body, "Now · Unknown", 16)
		current.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		var current_bar := _bar(body, COLORS[id], false)
		var preview_box := UI.column(body, 4)
		var preview := UI.label(preview_box, "After layout · Unknown", 16, UI.MUTED)
		preview.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		var preview_bar := _bar(preview_box, COLORS[id], true)
		if id == "oxygen":
			_life_food = UI.label(body, "", 16, UI.GREEN, true)
			_life_food.hide()
		_cards[id] = {"panel":panel, "title":title, "current":current, "current_bar":current_bar,
			"preview":preview, "preview_bar":preview_bar, "preview_box":preview_box}
	_shield_panel = UI.panel(self, UI.CARD, 10)
	_shield_panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var shield_body := UI.column(_shield_panel, 4)
	var shield_heading := UI.row(shield_body, 8)
	shield_heading.add_child(ResourceIcon.new("shield", UI.PURPLE))
	UI.label(shield_heading, "Shelter readiness", 18)
	_shield_label = UI.label(shield_body, "No shelter", 18, UI.AMBER, true)
	_shield_detail = UI.label(shield_body, "Build a shelter to prepare", 16, UI.MUTED, true)
	resized.connect(_layout)
	set_view_model({})

func _bar(parent: Control, tint: Color, outlined: bool) -> ProgressBar:
	var bar := ProgressBar.new()
	bar.mouse_filter = Control.MOUSE_FILTER_IGNORE
	bar.show_percentage = false
	bar.min_value = 0
	bar.max_value = 1
	bar.step = 0
	bar.custom_minimum_size.y = 12
	bar.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	bar.add_theme_stylebox_override("background", UI.box(UI.DARK, UI.LINE, 3))
	bar.add_theme_stylebox_override("fill", UI.box(UI.DARK if outlined else tint, tint, 3))
	parent.add_child(bar)
	return bar

func _layout() -> void:
	columns = 3 if size.x >= 840 else 1

func set_view_model(data: Dictionary) -> void:
	var mission_status := bool(data.get("mission_status", false))
	var entries: Dictionary = {}
	var values: Variant = data.get("resources", [])
	if values is Array:
		for item: Variant in values:
			if item is Dictionary and item.get("id", "") in IDS:
				entries[item.id] = item
	for id: String in IDS:
		var card: Dictionary = _cards[id]
		var entry: Dictionary = entries.get(id, {})
		var title: String = str(entry.get("label", LABELS[id]))
		card.title.text = title if not title.is_empty() else LABELS[id]
		_set_value(card.current, card.current_bar, "Now", entry.get("current"), entry.get("capacity"))
		_set_value(card.preview, card.preview_bar, "After layout", entry.get("preview"), entry.get("preview_capacity"))
		card.preview_box.visible = bool(data.get("show_preview", false))
	_cards.food.panel.visible = not mission_status
	_life_food.visible = mission_status
	_shield_panel.visible = mission_status
	if mission_status:
		_cards.oxygen.title.text = "Life support"
		_cards.oxygen.current.text = _cards.oxygen.current.text.replace("Now", "Oxygen")
		var food: Variant = entries.get("food", {}).get("current")
		_life_food.text = "Food unknown"
		if _finite_number(food):
			_life_food.text = "Food %s · %s" % [str(food), "Empty! Life support at risk" if float(food) <= 0 else ("Low! Check the next turn" if float(food) <= 6 else "In stock")]
		_life_food.add_theme_color_override("font_color", UI.ALERT if _finite_number(food) and float(food) <= 6 else UI.GREEN)
		var status: String = str(data.get("shield_status", "absent"))
		_shield_label.text = {"absent":"No shelter", "prepared":"Shelter ready", "selected":"Shelter selected"}.get(status, "No shelter")
		_shield_detail.text = {"absent":"Build a shelter to prepare", "prepared":"Choose Shelter when an alert requires it", "selected":"Shelter when this turn runs"}.get(status, "")
		if not str(data.get("shield_detail", "")).is_empty(): _shield_detail.text = str(data.shield_detail)
		_shield_label.add_theme_color_override("font_color", UI.AMBER if status == "absent" else UI.CYAN)
	_layout()

func _set_value(caption: Label, bar: ProgressBar, prefix: String, value: Variant, cap: Variant) -> void:
	bar.value = 0
	if not _finite_number(value):
		caption.text = prefix + " · Unknown"
		return
	if not _finite_number(cap) or float(cap) <= 0:
		caption.text = "%s %s / Unknown" % [prefix, str(value)]
		return
	caption.text = "%s %s / %s" % [prefix, str(value), str(cap)]
	bar.value = clampf(float(value) / float(cap), 0, 1)

func _finite_number(value: Variant) -> bool:
	return (value is int or value is float) and is_finite(float(value))
