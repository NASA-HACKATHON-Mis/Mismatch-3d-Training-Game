extends Control
## A single physical site. Only Mission may validate and apply edit requests.
signal edited(action: String, slot_id: int, kind: String)
signal closed
signal inspect_requested(slot_id: int)

const UI = preload("res://scripts/ui/ui_style.gd")
const Rules = preload("res://scripts/simulation/scenario.gd")
const Simulation = preload("res://scripts/simulation/simulation.gd")
const ResourceMeter = preload("res://scripts/ui/resource_meter.gd")
const ICON_PATH := "res://assets/ui/operations/facilities/"
const ICONS := {"generator": "energy", "battery": "storage", "greenhouse": "food", "shelter": "shield", "habitat": "oxygen"}
const EFFECTS := {
	"generator": "햇빛을 전력으로 바꿔요.",
	"battery": "전력을 더 많이 저장해요.",
	"greenhouse": "전력을 써서 식량을 길러요.",
	"shelter": "우주날씨 경보 때 대피해요.",
	"habitat": "승무원의 산소를 만들어요."
}

var _session
var _slot_id := -1
var _view_mode := "details"
var _selected_kind := "generator"
var _access_allowed := false
var _access_reason := ""
var _layout_state: Dictionary = {}
var _card: PanelContainer
var _scroll: ScrollContainer
var _title: Label
var _subtitle: Label
var _budget: Label
var _site_tags: Label
var _choices: GridContainer
var _choice_buttons: Dictionary = {}
var _facility_icon: TextureRect
var _description: Label
var _effect: Label
var _place: Button
var _remove: Button
var _inspect: Button
var _permission: Label
var _notice: Label
var _energy: ResourceMeter
var _oxygen: ResourceMeter
var _food: ResourceMeter

func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	UI.use_korean_theme(self)
	var shade := ColorRect.new()
	shade.color = Color(0.015, 0.035, 0.06, 0.38)
	shade.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(shade)
	_card = UI.panel(self, Color("#0b182cf8"), 18)
	_scroll = ScrollContainer.new()
	_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	_scroll.follow_focus = true
	_card.add_child(_scroll)
	var column := UI.column(_scroll, 12)
	UI.grow(column)
	var heading := UI.row(column, 8)
	var titles := UI.column(heading, 3)
	UI.grow(titles)
	_subtitle = UI.label(titles, "현장 조작", 16, UI.CYAN)
	_title = UI.label(titles, "", 26, UI.TEXT, true)
	UI.button(heading, "닫기\nEsc", func(): closed.emit(), UI.MUTED, 52)
	_site_tags = UI.label(column, "", 16, UI.AMBER, true)
	_budget = UI.label(column, "", 20, UI.AMBER)
	_choices = GridContainer.new()
	_choices.columns = 2
	_choices.add_theme_constant_override("h_separation", 8)
	_choices.add_theme_constant_override("v_separation", 8)
	column.add_child(_choices)
	for kind: String in Rules.BUILDABLE:
		var button := UI.button(_choices, "", _select_kind.bind(kind), UI.FACILITY_COLORS[kind], 72)
		UI.grow(button)
		button.icon = load(ICON_PATH + ICONS[kind] + ".svg")
		button.icon_alignment = HORIZONTAL_ALIGNMENT_LEFT
		button.add_theme_constant_override("icon_max_width", 32)
		_choice_buttons[kind] = button
	var feature := UI.panel(column, UI.CARD, 12)
	var feature_row := UI.row(feature, 12)
	_facility_icon = TextureRect.new()
	_facility_icon.custom_minimum_size = Vector2(48, 48)
	_facility_icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_facility_icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	_facility_icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
	feature_row.add_child(_facility_icon)
	var feature_text := UI.column(feature_row, 4)
	UI.grow(feature_text)
	_description = UI.label(feature_text, "", 18, UI.TEXT, true)
	_effect = UI.label(feature_text, "", 16, UI.MUTED, true)
	_place = UI.button(column, "", _place_selected, UI.CYAN, 48)
	_remove = UI.button(column, "", _remove_selected, UI.ALERT, 48)
	_inspect = UI.button(column, "3D로 살펴보기", _request_inspect, UI.PURPLE, 44)
	_permission = UI.label(column, "", 16, UI.AMBER, true)
	_notice = UI.label(column, "", 17, UI.CYAN, true)
	_notice.hide()
	UI.label(column, "현재 기지 자원", 17, UI.MUTED)
	var resources := UI.row(column, 12)
	_energy = ResourceMeter.new()
	_oxygen = ResourceMeter.new()
	_food = ResourceMeter.new()
	resources.add_child(_energy)
	resources.add_child(_oxygen)
	resources.add_child(_food)
	_energy.set_color(UI.AMBER)
	_oxygen.set_color(UI.CYAN)
	_food.set_color(UI.GREEN)
	UI.label(column, "배치를 마치면 단말기에서 턴을 진행해요.", 16, UI.MUTED, true)
	resized.connect(_position_card)
	_position_card()
	hide()

func _position_card() -> void:
	if not is_instance_valid(_card): return
	var width := minf(464, maxf(280, size.x - 32))
	_card.position = Vector2(size.x - width - 20, 20)
	_card.size = Vector2(width, maxf(180, size.y - 40))

func open_site(session, slot_id: int, view_mode: String = "edit") -> void:
	_session = session
	_slot_id = slot_id if slot_id >= 0 and slot_id < Rules.SLOT_COUNT else -1
	_view_mode = view_mode if view_mode in ["edit", "details"] else "details"
	_selected_kind = "generator"
	_access_allowed = false # Mission must explicitly grant the current physical access.
	_access_reason = "시설을 가까이에서 바라봐요."
	set_notice("")
	refresh(session)
	show()
	_scroll.scroll_vertical = 0

func refresh(session) -> void:
	_session = session
	if session == null: return
	var preview: Dictionary = session.preview()
	_layout_state = preview.get("state", session.state).duplicate(true)
	var facility := Simulation.facility_at(_layout_state, _slot_id)
	var empty := facility.is_empty()
	var editing := _view_mode == "edit"
	var kind: String = _selected_kind if empty and editing else str(facility.get("type", ""))
	_subtitle.text = "현장 설치·철거" if editing else "현장 상세 정보"
	_title.text = "%02d번 · %s" % [_slot_id + 1, "빈 부지" if empty else UI.name_for(kind)] if _slot_id >= 0 else "선택할 수 없는 위치"
	var tags: Array[String] = []
	if Rules.SUNLIT.has(_slot_id): tags.append("햇빛이 잘 들어요")
	if Rules.SHIELDED.has(_slot_id): tags.append("차폐 지형 · 대피소 할인")
	_site_tags.text = " · ".join(tags) if not tags.is_empty() else "일반 부지"
	_budget.text = "건설 토큰  %d" % int(_layout_state.get("budget", 0))
	_choices.visible = editing and empty and _slot_id >= 0
	for choice: String in _choice_buttons:
		var cost := Rules.cost(choice, _slot_id)
		var button: Button = _choice_buttons[choice]
		button.text = "%s\n%d 토큰" % [UI.name_for(choice), cost]
		UI.paint_button(button, UI.FACILITY_COLORS[choice], choice == _selected_kind)
	_facility_icon.visible = not kind.is_empty()
	if not kind.is_empty(): _facility_icon.texture = load(ICON_PATH + ICONS.get(kind, "info") + ".svg")
	_description.text = EFFECTS.get(kind, "아직 시설이 없어요.")
	_effect.text = _effect_text(kind, facility)
	_place.visible = editing and empty and _slot_id >= 0
	_place.text = "여기에 %s 설치 · %d 토큰" % [UI.name_for(_selected_kind), Rules.cost(_selected_kind, _slot_id)]
	_remove.visible = editing and not empty
	if not empty and kind != "habitat":
		@warning_ignore("integer_division")
		var refund: int = int(facility.get("actual_paid_cost", 0)) if int(facility.instance_id) >= int(session.state.next_instance_id) else int(facility.get("actual_paid_cost", 0)) / 2
		_remove.text = "이 시설 철거 · %d 토큰 돌려받기" % refund
	else:
		_remove.text = "고정 거주실 · 철거할 수 없어요"
	_inspect.visible = not empty
	_energy.set_values("전력", int(session.state.E), Simulation.energy_cap(session.state))
	_oxygen.set_values("산소", int(session.state.O), 100)
	_food.set_values("식량", int(session.state.F), 100)
	_update_access()

func _effect_text(kind: String, facility: Dictionary) -> String:
	match kind:
		"generator": return "기본 전력 +%d / 턴 · 사건에 따라 달라져요" % (18 if Rules.SUNLIT.has(_slot_id) else 12)
		"battery": return "전력 저장 한도 +20"
		"greenhouse": return "전력 4 사용 · 3번 가동하면 식량 +18\n성장 %d / 3" % int(facility.get("growth", 0))
		"shelter": return "경보 때 단말기에서 ‘대피’를 골라요."
		"habitat": return "전력 6 → 산소 8 · 고정 시설"
	return "설치하려면 닫고 1을 눌러요."

func set_access_allowed(enabled: bool, reason: String = "") -> void:
	_access_allowed = enabled and _slot_id >= 0
	_access_reason = reason
	_update_access()

func _update_access() -> void:
	if not is_instance_valid(_place) or _session == null: return
	var facility := Simulation.facility_at(_layout_state, _slot_id)
	var can_edit: bool = _access_allowed and _view_mode == "edit" and _session.state.phase == "planning"
	for button: Button in _choice_buttons.values(): button.disabled = not can_edit
	_place.disabled = not can_edit or not facility.is_empty() or int(_layout_state.get("budget", 0)) < Rules.cost(_selected_kind, _slot_id)
	_remove.disabled = not can_edit or facility.is_empty() or facility.get("type", "") == "habitat"
	_inspect.disabled = not _access_allowed or facility.is_empty()
	if not _access_allowed:
		_permission.text = _access_reason if not _access_reason.is_empty() else "시설을 가까이에서 바라봐요."
	elif _view_mode == "details":
		_permission.text = "정보를 보는 화면이에요."
	elif _session.state.phase != "planning":
		_permission.text = "턴이 끝났어요. 단말기에서 다음 턴을 준비해요."
	elif facility.is_empty() and _place.disabled:
		_permission.text = "건설 토큰이 부족해요."
	else:
		_permission.text = "선택한 이 위치에서만 바꿀 수 있어요."

func set_notice(text: String, is_error: bool = false) -> void:
	_notice.text = text
	_notice.visible = not text.is_empty()
	_notice.add_theme_color_override("font_color", UI.ALERT if is_error else UI.CYAN)

func _select_kind(kind: String) -> void:
	if not _access_allowed or _view_mode != "edit" or not Rules.BUILDABLE.has(kind): return
	if _session == null or _session.state.phase != "planning" or not Simulation.facility_at(_layout_state, _slot_id).is_empty(): return
	_selected_kind = kind
	set_notice("")
	refresh(_session)

func _place_selected() -> void:
	if not visible or _session == null: return
	refresh(_session)
	if _place.disabled or not _place.visible: return
	edited.emit("place", _slot_id, _selected_kind)

func _remove_selected() -> void:
	if not visible or _session == null: return
	refresh(_session)
	if _remove.disabled or not _remove.visible: return
	edited.emit("remove", _slot_id, "")

func _request_inspect() -> void:
	if not visible or _session == null: return
	refresh(_session)
	if _inspect.disabled or not _inspect.visible: return
	inspect_requested.emit(_slot_id)
