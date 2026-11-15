extends RefCounted
## A shared visual vocabulary for the HUD and terminal.

const TEXT := Color("#eaf3ff")
const MUTED := Color("#a5b6cd")
const CYAN := Color("#75ebe0")
const AMBER := Color("#ffca82")
const GREEN := Color("#a5e595")
const PURPLE := Color("#c9b5ff")
const ALERT := Color("#ffae9d")
const CARD := Color("#101e32")
const DARK := Color("#0a1424")
const LINE := Color("#304764")
const FACILITY_COLORS := {"habitat": CYAN, "generator": AMBER, "battery": PURPLE,
	"greenhouse": GREEN, "shelter": Color("#95c2ff")}

static var _korean_theme: Theme


static func use_korean_theme(panel_root: Control) -> void:
	if _korean_theme == null:
		var font := FontVariation.new()
		font.base_font = load("res://resources/fonts/NotoSansKR.ttf")
		font.variation_opentype = {"wght": 500}
		font.variation_embolden = 0.55
		_korean_theme = Theme.new()
		_korean_theme.default_font = font
		_korean_theme.default_font_size = 18
	panel_root.theme = _korean_theme


static func trn(_ko: String, en: String) -> String:
	return en


static func name_for(kind: String) -> String:
	match kind:
		"habitat": return trn("Habitat", "Habitat")
		"generator": return trn("Solar array", "Solar array")
		"battery": return trn("Battery", "Battery")
		"greenhouse": return trn("Greenhouse", "Greenhouse")
		"shelter": return trn("Shelter", "Shelter")
	return ""


static func description(kind: String) -> String:
	match kind:
		"generator": return trn("3 tokens · +18 power in sun, +12 elsewhere", "3 tokens · +18 power in sun, +12 elsewhere")
		"battery": return trn("2 tokens · stores up to 20 extra power", "2 tokens · stores up to 20 extra power")
		"greenhouse": return trn("3 tokens · costs 4 power, yields food after 3 active turns", "3 tokens · costs 4 power, yields food after 3 active turns")
		"shelter": return trn("3–4 tokens · protects the crew during an alert", "3–4 tokens · protects the crew during an alert")
		"habitat": return trn("Habitat · uses 6 power to make 8 oxygen", "Habitat · uses 6 power to make 8 oxygen")
	return ""


static func phase_text(phase: String) -> String:
	match phase:
		"turn_complete": return trn("Turn cleared", "Turn cleared")
		"completed": return trn("Mission complete", "Mission complete")
		"failed_power": return trn("Stopped · out of power", "Stopped · out of power")
		"failed_safety": return trn("Stopped · shelter needed", "Stopped · shelter needed")
		"failed_life_support": return trn("Stopped · life support depleted", "Stopped · life support depleted")
	return ""


static func error_text(error: String) -> String:
	match error:
		"invalid_slot": return trn("Build inside the station grid.", "Build inside the station grid.")
		"occupied": return trn("That pad already holds a module.", "That pad already holds a module.")
		"budget": return trn("You need more build tokens.", "You need more build tokens.")
		"fixed_habitat": return trn("The central habitat must stay.", "The central habitat must stay.")
		"player_overlap": return trn("Step off this pad before building.", "Step off this pad before building.")
		"empty": return trn("Select a module to remove.", "Select a module to remove.")
		"choose_fault", "choose_weather", "acknowledge_delay":
			return trn("Choose a response to this event first.", "Choose a response to this event first.")
	return trn("This action is unavailable on the current turn.", "This action is unavailable on the current turn.")


static func box(fill: Color, border: Color = LINE, radius: int = 12, margin: int = 0) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = fill
	style.border_color = border
	style.set_border_width_all(1)
	style.set_corner_radius_all(radius)
	style.content_margin_left = margin
	style.content_margin_right = margin
	style.content_margin_top = margin
	style.content_margin_bottom = margin
	return style


static func panel(parent: Control, fill: Color = CARD, inset: int = 14) -> PanelContainer:
	var node := PanelContainer.new()
	node.add_theme_stylebox_override("panel", box(fill, LINE, 12, inset))
	parent.add_child(node)
	return node


static func column(parent: Control, spacing: int = 8) -> VBoxContainer:
	var node := VBoxContainer.new()
	node.add_theme_constant_override("separation", spacing)
	parent.add_child(node)
	return node


static func row(parent: Control, spacing: int = 8) -> HBoxContainer:
	var node := HBoxContainer.new()
	node.add_theme_constant_override("separation", spacing)
	parent.add_child(node)
	return node


static func label(parent: Control, value: String, size: int, color: Color = TEXT,
		wrap := false) -> Label:
	var node := Label.new()
	node.text = value
	node.add_theme_font_size_override("font_size", maxi(16, size))
	node.add_theme_color_override("font_color", color)
	node.mouse_filter = Control.MOUSE_FILTER_IGNORE
	if wrap:
		node.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	parent.add_child(node)
	return node


static func button(parent: Control, value: String, callback: Callable, color: Color = CYAN,
		height: int = 40) -> Button:
	var node := Button.new()
	node.text = value
	node.custom_minimum_size.y = height
	node.add_theme_font_size_override("font_size", 18)
	paint_button(node, color)
	if callback.is_valid():
		node.pressed.connect(callback)
	parent.add_child(node)
	return node


static func paint_button(node: Button, color: Color, active := false) -> void:
	node.add_theme_color_override("font_color", color)
	node.add_theme_color_override("font_hover_color", TEXT)
	node.add_theme_color_override("font_pressed_color", TEXT)
	node.add_theme_color_override("font_disabled_color", Color("#9aaec8"))
	node.add_theme_stylebox_override("normal", box(Color("#1c3b4b") if active else Color("#15263b"),
		color if active else LINE, 8, 7))
	node.add_theme_stylebox_override("hover", box(Color("#234359"), color, 8, 7))
	node.add_theme_stylebox_override("pressed", box(Color("#285564"), color, 8, 7))
	node.add_theme_stylebox_override("disabled", box(Color("#111c2d"), Color("#293a51"), 8, 7))
	var outline := box(Color.TRANSPARENT, Color("#e9f8ff"), 8)
	outline.set_border_width_all(2)
	node.add_theme_stylebox_override("focus", outline)


static func grow(node: Control) -> void:
	node.size_flags_horizontal = Control.SIZE_EXPAND_FILL


static func signed_delta(value: int) -> String:
	return ("+" if value > 0 else "") + str(value)
