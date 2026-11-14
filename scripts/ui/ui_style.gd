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


static func trn(ko: String, en: String) -> String:
	return en if OS.has_feature("web") or not OS.get_locale_language().begins_with("ko") else ko


static func name_for(kind: String) -> String:
	match kind:
		"habitat": return trn("거주실", "Habitat")
		"generator": return trn("발전기", "Solar array")
		"battery": return trn("배터리", "Battery")
		"greenhouse": return trn("재배실", "Greenhouse")
		"shelter": return trn("대피소", "Shelter")
	return ""


static func description(kind: String) -> String:
	match kind:
		"generator": return trn("3 토큰 · 일조 칸 +18 전력, 그 외 +12", "3 tokens · +18 power in sun, +12 elsewhere")
		"battery": return trn("2 토큰 · 공용 전력 저장 한도 +20", "2 tokens · stores up to 20 extra power")
		"greenhouse": return trn("3 토큰 · 전력 4, 3번 가동하면 식량 +18", "3 tokens · costs 4 power, yields food after 3 active turns")
		"shelter": return trn("3–4 토큰 · 우주날씨 경보 때 대피", "3–4 tokens · protects the crew during an alert")
		"habitat": return trn("거주실 · 전력 6을 써서 산소 8 생산", "Habitat · uses 6 power to make 8 oxygen")
	return ""


static func phase_text(phase: String) -> String:
	match phase:
		"turn_complete": return trn("턴 완료", "Turn cleared")
		"completed": return trn("훈련 완료", "Mission complete")
		"failed_power": return trn("중단 · 전력 부족", "Stopped · out of power")
		"failed_safety": return trn("중단 · 대피 필요", "Stopped · shelter needed")
		"failed_life_support": return trn("중단 · 생명 유지 자원 부족", "Stopped · life support depleted")
	return ""


static func error_text(error: String) -> String:
	match error:
		"invalid_slot": return trn("기지 격자 안에서만 지을 수 있어요.", "Build inside the station grid.")
		"occupied": return trn("이미 시설이 있는 칸이에요.", "That pad already holds a module.")
		"budget": return trn("건설 토큰이 부족해요.", "You need more build tokens.")
		"fixed_habitat": return trn("가운데 거주실은 옮기거나 철거할 수 없어요.", "The central habitat must stay.")
		"player_overlap": return trn("이 위치에 서 있어요. 비운 뒤 다시 지어 보세요.", "Step off this pad before building.")
		"empty": return trn("철거할 시설을 먼저 골라요.", "Select a module to remove.")
		"choose_fault", "choose_weather", "acknowledge_delay":
			return trn("사건에 어떻게 대응할지 먼저 골라요.", "Choose a response to this event first.")
	return trn("현재 턴에서는 할 수 없어요.", "This action is unavailable on the current turn.")


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
	node.add_theme_font_size_override("font_size", size)
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
	node.add_theme_font_size_override("font_size", 16)
	paint_button(node, color)
	if callback.is_valid():
		node.pressed.connect(callback)
	parent.add_child(node)
	return node


static func paint_button(node: Button, color: Color, active := false) -> void:
	node.add_theme_color_override("font_color", color)
	node.add_theme_color_override("font_hover_color", TEXT)
	node.add_theme_color_override("font_pressed_color", TEXT)
	node.add_theme_color_override("font_disabled_color", Color("#708199"))
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
