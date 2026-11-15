extends Control

signal selected_slot_changed(slot: int)
signal inspect_requested
signal closed
signal edited(action: String, slot_id: int, kind: String)
signal cancelled
signal advanced(choice: String)
signal rewound(turn_id: int)
signal help_requested
signal guidance_changed(enabled: bool)

const UI = preload("res://scripts/ui/ui_style.gd")
const Rules = preload("res://scripts/simulation/scenario.gd")
const Simulation = preload("res://scripts/simulation/simulation.gd")
const Preview = preload("res://scripts/simulation/turn_preview.gd")
const History = preload("res://scripts/ui/history_explanation.gd")
const Outcome = preload("res://scripts/ui/outcome_summary.gd")
const Learning = preload("res://resources/content/learning.gd")
const GLYPHS := {"habitat": "HAB", "generator": "SOL", "battery": "BAT", "greenhouse": "GROW", "shelter": "SAFE"}

var _session
var _selected_kind := "generator"
var _selected_slot := -1
var _timeline_turn := 1
var _choice := ""
var _last_turn := -1
var _locked := false
var _slots: Array[Button] = []
var _timeline: Array[Button] = []
var _facilities := {}
var _close: Button
var help_button: Button
var _advance: Button
var _remove: Button
var _cancel: Button
var _rewind: Button
var _summary: Label
var _map_help: Label
var _event_title: Label
var _event_text: Label
var _options: HBoxContainer
var _event_buttons: Array[Button] = []
var _event_values: Array[String] = []
var _notice: Label
var _result: Label
var _compare_title: Label
var _prior: Label
var _current: Label
var _delta: Label
var _map_card: PanelContainer
var _controls_card: PanelContainer
var _working: BoxContainer
var _header_actions: BoxContainer
var _timeline_top: BoxContainer
var _comparison_sides: BoxContainer
var _guide_body: VBoxContainer
var _guide_text: Label
var _guide_toggle: Button
var _history_toggle: Button
var _history_body: VBoxContainer
var _history_empty: Label
var _history_open := false
var guidance_enabled := true
var _selection_detail: Label
var _capacity: Label
var _advance_reason: Label
var _preview_toggle: Button
var _preview_detail: Label
var _preview_open := false
var _candidate_note: Label
var _candidate_buttons: Array[Button] = []
var _start_preview: Label
var _inspect: Button
var _clear_selection: Button
var _scroll: ScrollContainer
var _outcome_card: PanelContainer
var _outcome_title: Label
var _outcome_reason: Label
var _outcome_details: Label
var _outcome_toggle: Button
var _outcome_action: Button


func _ready() -> void:
	UI.use_korean_theme(self)
	var shade := ColorRect.new()
	shade.color = Color("#06101de9")
	shade.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(shade)
	var scroll := ScrollContainer.new()
	_scroll = scroll
	scroll.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	scroll.offset_left = 24
	scroll.offset_right = -24
	scroll.offset_top = 20
	scroll.offset_bottom = -18
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	scroll.follow_focus = true
	add_child(scroll)
	var outer := VBoxContainer.new()
	outer.size_flags_horizontal = SIZE_EXPAND_FILL
	outer.size_flags_vertical = SIZE_EXPAND_FILL
	outer.add_theme_constant_override("separation", 10)
	scroll.add_child(outer)
	_build_header(outer)
	_build_outcome(outer)
	_build_guidance(outer)
	_working = BoxContainer.new()
	_working.add_theme_constant_override("separation", 12)
	outer.add_child(_working)
	_build_map(_working)
	_build_controls(_working)
	_build_timeline(outer)
	resized.connect(_layout)
	_layout()


func _build_header(parent: Control) -> void:
	var panel := UI.panel(parent, UI.CARD, 12)
	var contents := UI.column(panel, 8)
	_header_actions = BoxContainer.new()
	contents.add_child(_header_actions)
	var title := UI.label(_header_actions, "기지 운영 단말기", 26)
	UI.grow(title)
	help_button = UI.button(_header_actions, "안내서  H", func(): help_requested.emit(), UI.CYAN)
	_close = UI.button(_header_actions, "닫기  Esc", func(): closed.emit(), UI.MUTED)
	_summary = UI.label(contents, "", 18, UI.TEXT, true)

func _build_outcome(parent: Control) -> void:
	_outcome_card = UI.panel(parent, Color("#133047"), 16)
	var contents := UI.column(_outcome_card, 10)
	_outcome_title = UI.label(contents, "", 28, UI.CYAN, true)
	_outcome_reason = UI.label(contents, "", 18, UI.TEXT, true)
	_outcome_action = UI.button(contents, "과거 기록에서 다시 시도하기", _open_outcome_history, UI.AMBER)
	_outcome_toggle = UI.button(contents, "내 선택·자원 기록 보기", _toggle_outcome_details, UI.MUTED)
	_outcome_details = UI.label(contents, "", 18, UI.TEXT, true)
	_outcome_details.hide()
	_outcome_card.hide()

func _toggle_outcome_details() -> void:
	_outcome_details.visible = not _outcome_details.visible
	_outcome_toggle.text = "내 선택·자원 기록 접기" if _outcome_details.visible else "내 선택·자원 기록 보기"

func scroll_to_outcome() -> void:
	_scroll.scroll_vertical = 0

func _open_outcome_history() -> void:
	_history_open = true
	_refresh_timeline()
	_history_toggle.grab_focus()
	_scroll.call_deferred("ensure_control_visible", _history_toggle)

func _refresh_outcome() -> void:
	var state: Dictionary = _session.state
	_outcome_card.visible = Outcome.ended(state)
	if not _outcome_card.visible:
		_outcome_details.hide()
		_outcome_toggle.text = "내 선택·자원 기록 보기"
		return
	_outcome_title.text = Outcome.heading(state)
	_outcome_title.add_theme_color_override("font_color", UI.CYAN if state.phase == "completed" else UI.ALERT)
	_outcome_reason.text = Outcome.reason(_session.result_at(state.turn_id))
	_outcome_details.text = Outcome.history_lines(_session)
	_outcome_action.text = "과거 기록·되감기와 비교" if state.phase == "completed" else "과거 기록에서 다시 시도하기"

func _build_guidance(parent: Control) -> void:
	var card := UI.panel(parent, Color("#133047"), 12)
	var contents := UI.column(card, 6)
	var heading := UI.row(contents, 8)
	var title := UI.label(heading, "지금 할 일", 16, UI.CYAN)
	UI.grow(title)
	_guide_toggle = UI.button(heading, "첫 안내 건너뛰기", _toggle_guidance, UI.MUTED, 30)
	_guide_toggle.add_theme_font_size_override("font_size", 16)
	_guide_body = UI.column(contents, 4)
	_guide_text = UI.label(_guide_body, "", 20, UI.TEXT, true)

func _toggle_guidance() -> void:
	set_guidance(not guidance_enabled)
	guidance_changed.emit(guidance_enabled)

func set_guidance(enabled: bool) -> void:
	guidance_enabled = enabled
	_guide_body.visible = enabled
	_guide_toggle.text = "첫 안내 건너뛰기" if enabled else "첫 안내 다시 보기"

func _layout() -> void:
	if not is_instance_valid(_working): return
	_working.vertical = size.x < 1100
	_working.move_child(_controls_card if _working.vertical else _map_card, 0)
	_header_actions.vertical = size.x < 600
	_timeline_top.vertical = size.x < 1100
	_comparison_sides.vertical = size.x < 900

func _refresh_guidance(planning: bool, edit_state: Dictionary) -> void:
	if not planning:
		_guide_text.text = "결과를 읽고, 과거 기록에서 다시 해 볼 턴을 골라요."
	elif not _session.draft.is_empty():
		_guide_text.text = "2  배치를 확인해요. 바꾸려면 ‘이번 변경 취소’를 눌러요."
	else:
		_guide_text.text = "1  시설을 고른 뒤, 지도에서 비어 있는 칸을 눌러요."
	if planning and not _event_values.is_empty():
		_guide_text.text = "2  사건에 어떻게 대응할지 골라요." if _choice.is_empty() else "3  준비됐다면 ‘이번 턴 진행’을 눌러요."
	elif planning and Simulation.count_kind(edit_state, "generator") > 0:
		_guide_text.text = "3  준비됐다면 ‘이번 턴 진행’을 눌러요. 시설은 더 놓아도 돼요."


func _build_map(parent: Control) -> void:
	var card := UI.panel(parent)
	_map_card = card
	UI.grow(card)
	card.size_flags_stretch_ratio = 0.94
	var map := UI.column(card, 8)
	UI.label(map, "배치 지도", 16, UI.CYAN)
	UI.label(map, UI.trn("북쪽 / NORTH · 일조: 발전 증가 · 차폐: 대피소 할인", "NORTH · SUN: more power · SHIELD: cheaper shelter"),
		16, UI.MUTED, true)
	var grid := GridContainer.new()
	grid.columns = 5
	grid.size_flags_vertical = SIZE_SHRINK_BEGIN
	grid.add_theme_constant_override("h_separation", 5)
	grid.add_theme_constant_override("v_separation", 5)
	map.add_child(grid)
	for slot_id in Rules.SLOT_COUNT:
		var button := UI.button(grid, "", _select_slot.bind(slot_id), UI.TEXT, 58)
		UI.grow(button)
		button.size_flags_vertical = SIZE_EXPAND_FILL
		button.add_theme_font_size_override("font_size", 16)
		_slots.append(button)
	_map_help = UI.label(map, "", 18, UI.MUTED, true)
	_inspect = UI.button(map,"선택 칸 3D 보기",func(): inspect_requested.emit(),UI.CYAN)
	_clear_selection = UI.button(map,"선택 해제",func(): _selected_slot = -1; refresh(_session),UI.MUTED)
	var buttons := UI.row(map)
	_remove = UI.button(buttons, UI.trn("선택 시설 철거", "Remove selected"),
		func(): edited.emit("remove", _selected_slot, ""), UI.ALERT, 36)
	_cancel = UI.button(buttons, UI.trn("이번 변경 취소", "Cancel this turn’s changes"),
		func(): cancelled.emit(), UI.MUTED, 36)
	UI.grow(_remove)
	UI.grow(_cancel)


func _build_controls(parent: Control) -> void:
	var card := UI.panel(parent)
	_controls_card = card
	UI.grow(card)
	card.size_flags_stretch_ratio = 1.06
	var controls := UI.column(card, 6)
	UI.label(controls, "시설 고르기", 16, UI.CYAN)
	var facility_grid := GridContainer.new()
	facility_grid.columns = 2
	facility_grid.add_theme_constant_override("h_separation", 6)
	facility_grid.add_theme_constant_override("v_separation", 6)
	controls.add_child(facility_grid)
	for kind: String in Rules.BUILDABLE:
		var label := UI.name_for(kind) + "   /   " + ("3–4" if kind == "shelter" else str(Rules.cost(kind, 1)))
		var button := UI.button(facility_grid, label, _select_kind.bind(kind), UI.FACILITY_COLORS[kind], 35)
		UI.grow(button)
		button.tooltip_text = UI.description(kind)
		_facilities[kind] = button
	_selection_detail = UI.label(controls, "", 18, UI.TEXT, true)
	_notice = UI.label(controls, "", 18, UI.ALERT, true)
	_notice.hide()
	_capacity = UI.label(controls, "", 18, UI.CYAN, true)
	_event_title = UI.label(controls, "", 18, UI.AMBER)
	_event_text = UI.label(controls, "", 18, UI.TEXT, true)
	_options = UI.row(controls, 6)
	_options.custom_minimum_size.y = 34
	for i in 2:
		var button := UI.button(_options, "", _choose_event.bind(i), UI.AMBER, 34)
		button.add_theme_font_size_override("font_size", 18)
		UI.grow(button)
		_event_buttons.append(button)
	_advance = UI.button(controls, "", _advance_turn, UI.CYAN, 43)
	_advance_reason = UI.label(controls, "", 18, UI.AMBER, true)
	_preview_toggle = UI.button(controls, "이번 턴 예상 자세히 보기", _toggle_preview, UI.MUTED, 36)
	_preview_detail = UI.label(controls, "", 18, UI.TEXT, true)
	_preview_detail.hide()
	_result = UI.label(controls, "", 18, UI.TEXT, true)
	_result.custom_minimum_size.y = 58


func _build_timeline(parent: Control) -> void:
	var panel := UI.panel(parent, Color("#0d192b"), 12)
	var content := UI.column(panel, 8)
	_history_toggle = UI.button(content, "과거 기록 · 되감기와 비교", _toggle_history, UI.CYAN)
	_history_empty = UI.label(content, "아직 실행 결과가 없어요. 저장된 시작 상태는 아래 기록을 열어 확인해요.", 18, UI.MUTED, true)
	_history_body = UI.column(content, 8)
	_candidate_note = UI.label(_history_body,"",18,UI.MUTED,true)
	for index in 2:
		var candidate := UI.button(_history_body,"",_select_candidate.bind(index),UI.CYAN)
		candidate.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		_candidate_buttons.append(candidate)
	_timeline_top = BoxContainer.new()
	_timeline_top.add_theme_constant_override("separation", 7)
	_history_body.add_child(_timeline_top)
	var turns := UI.row(_timeline_top, 5)
	UI.grow(turns)
	for turn in range(1, 8):
		var button := UI.button(turns, "T%d" % turn, _select_turn.bind(turn), UI.CYAN, 40)
		UI.grow(button)
		_timeline.append(button)
	_rewind = UI.button(_timeline_top, "선택 턴 시작으로", func(): rewound.emit(_timeline_turn), UI.PURPLE, 40)
	_start_preview = UI.label(_history_body,"",18,UI.MUTED,true)
	_compare_title = UI.label(_history_body, "", 18, UI.CYAN)
	_comparison_sides = BoxContainer.new()
	_comparison_sides.add_theme_constant_override("separation", 12)
	_history_body.add_child(_comparison_sides)
	_prior = UI.label(_comparison_sides, "", 18, UI.TEXT, true)
	_current = UI.label(_comparison_sides, "", 18, UI.TEXT, true)
	UI.grow(_prior)
	UI.grow(_current)
	_delta = UI.label(_history_body, "", 18, UI.AMBER, true)

func _toggle_history() -> void:
	_history_open = not _history_open
	_refresh_timeline()


func refresh(session) -> void:
	_session = session
	var state: Dictionary = session.state
	var preview: Dictionary = session.preview()
	var edit_state: Dictionary = preview.state
	var turn: int = state.turn_id
	if _last_turn != turn:
		_choice = ""
		_last_turn = turn
	var planning: bool = state.phase == "planning"
	_summary.text = UI.trn("T%d / 7    전력 %d/%d    산소 %d    식량 %d    건설 토큰 %d",
		"T%d / 7    POWER %d/%d    OXYGEN %d    FOOD %d    Build tokens: %d") % [
		turn, state.E, Simulation.energy_cap(state), state.O, state.F, edit_state.budget]
	_refresh_map(edit_state, planning)
	_refresh_facilities(edit_state, planning)
	_refresh_event(turn, planning, edit_state)
	_advance.text = UI.trn("이번 턴 진행 · T%d", "Advance this turn · T%d") % turn if planning else UI.phase_text(state.phase)
	_advance.disabled = _locked or not planning or (_event_values.size() > 0 and _choice.is_empty())
	var last: Dictionary = session.result_at(turn - 1 if planning else turn)
	_result.text = _result_text(last)
	if last.is_empty():
		_result.text = UI.trn("아직 결과가 없어요. 이번 턴을 진행하면 자원의 변화를 볼 수 있어요.",
			"No result yet. Advance this turn to see resource changes.")
	_refresh_preview(planning, edit_state)
	_refresh_guidance(planning, edit_state)
	_refresh_timeline()
	_refresh_outcome()
	_inspect.disabled = _selected_slot < 0
	_clear_selection.disabled = _selected_slot < 0
	selected_slot_changed.emit(_selected_slot)


func _card_effect(kind: String) -> String:
	match kind:
		"generator": return "일조 전력 +18 / 그 외 +12"
		"battery": return "저장 공간 +20 · 생산 없음"
		"greenhouse": return "전력 4 사용 · 가동 3회 식량 +18"
		"shelter": return "경보 때 대피 · 차폐 칸 할인"
	return ""

func _cost_caption(kind: String) -> String:
	if kind == "shelter" and _selected_slot < 0: return "3~4"
	return str(Rules.cost(kind, maxi(0,_selected_slot)))

func _refresh_facilities(layout: Dictionary, planning: bool) -> void:
	for kind: String in _facilities:
		var button: Button = _facilities[kind]
		var price: int = Rules.cost(kind, maxi(0,_selected_slot))
		var shortfall: int = maxi(0,price - layout.budget)
		var shortage := "\n건설 토큰 %d개 부족" % shortfall if shortfall > 0 else ""
		if kind == "shelter" and _selected_slot < 0 and layout.budget >= 3: shortage = ""
		button.text = "%s · 토큰 %s\n%s%s" % [UI.name_for(kind),_cost_caption(kind),_card_effect(kind),shortage]
		button.add_theme_font_size_override("font_size",16)
		button.disabled = false # Descriptions remain accessible even when placement is unavailable.
		UI.paint_button(button, UI.MUTED if shortfall > 0 else UI.FACILITY_COLORS[kind], kind == _selected_kind)
	var cost: int = Rules.cost(_selected_kind, maxi(0,_selected_slot))
	var gap: int = maxi(0,cost - layout.budget)
	var location := "선택 칸 %02d" % (_selected_slot + 1) if _selected_slot >= 0 else "칸을 고르면 실제 비용을 확인해요"
	_selection_detail.text = "%s · %s\n%s" % [UI.name_for(_selected_kind),location,UI.description(_selected_kind)]
	if _selected_kind == "shelter":
		_selection_detail.text += "\n차폐 칸01·21은 토큰3, 다른 칸은 토큰4예요."
	if gap > 0:
		_selection_detail.text += "\n건설 토큰 %d개 부족해요. 설명은 계속 볼 수 있어요." % gap
	if not planning: _selection_detail.text += "\n완료된 턴에서는 배치할 수 없어요. 과거 턴으로 돌아가요."

func _toggle_preview() -> void:
	_preview_open = not _preview_open
	_preview_detail.visible = _preview_open
	_preview_toggle.text = "이번 턴 예상 접기" if _preview_open else "이번 턴 예상 자세히 보기"

func _refresh_preview(planning: bool, layout: Dictionary) -> void:
	_advance_reason.text = ""
	if not planning:
		_advance_reason.text = "훈련이 끝났어요. 과거 기록에서 다시 해 볼 턴을 골라요."
	elif _locked: _advance_reason.text = "이번 턴을 처리하고 있어요."
	elif not _event_values.is_empty() and _choice.is_empty():
		_advance_reason.text = "사건 대응을 먼저 골라요."
	_advance_reason.visible = not _advance_reason.text.is_empty()
	_preview_toggle.visible = planning
	_preview_detail.visible = planning and _preview_open
	if not planning:
		_capacity.text = "현재 전력 %d/%d" % [_session.state.E,Simulation.energy_cap(_session.state)]
		return
	var prediction: Dictionary = Preview.inspect(_session.snapshot(_session.state.turn_id),_session.draft,_choice)
	if prediction.has("error"):
		_preview_detail.text = UI.error_text(prediction.error)
		return
	_capacity.text = "현재 전력 %d/%d · 배치 후 저장 공간 %d" % [prediction.current_energy,prediction.current_capacity,prediction.layout_capacity]
	if _session.draft.is_empty():
		_capacity.text = "현재 전력 %d/%d · 배치 변경 없음" % [prediction.current_energy,prediction.current_capacity]
	if prediction.spill > 0: _capacity.text += "\n배치 확정 때 초과 전력 %d가 줄어든 뒤 턴을 계산해요." % prediction.spill
	var lines: Array[String] = ["이번 턴 진행 후 예상 · 현재 자원은 아직 바뀌지 않아요."]
	if prediction.conditional: lines.append("선택에 따라 달라져요. 아래는 각 대응을 골랐을 때의 예상이에요.")
	for outcome: Dictionary in prediction.outcomes:
		var result: Dictionary = outcome.result
		var label: String = Preview.choice_label(outcome.choice)
		if not outcome.available:
			lines.append(label + ": 먼저 대피소를 지어야 선택할 수 있어요.")
			continue
		if result.has("error"):
			lines.append(label + ": " + UI.error_text(result.error))
			continue
		lines.append(label + " · " + UI.phase_text(result.phase))
		lines.append(Preview.flow_lines(_session.state,result))
	lines.append(Preview.current_effect(layout,_choice))
	lines.append(Preview.growth_lines(layout,_choice))
	_preview_detail.text = "\n".join(lines)

func _refresh_map(state: Dictionary, planning: bool) -> void:
	for slot_id in Rules.SLOT_COUNT:
		var facility := Simulation.facility_at(state, slot_id)
		var kind: String = facility.get("type", "")
		var sun: bool = Rules.SUNLIT.has(slot_id)
		var shield: bool = Rules.SHIELDED.has(slot_id)
		var marks := ""
		if sun and shield:
			marks = UI.trn("일조·차폐", "SUN/SH")
		elif sun:
			marks = UI.trn("일조", "SUN")
		elif shield:
			marks = UI.trn("차폐", "SHIELD")
		var button := _slots[slot_id]
		var contents: String = GLYPHS.get(kind, "빈 칸")
		var tint: Color = UI.FACILITY_COLORS.get(kind, UI.AMBER if sun else (UI.PURPLE if shield else UI.MUTED))
		if not kind.is_empty():
			contents = UI.name_for(kind)
		button.text = "%02d\n%s\n%s" % [slot_id + 1, contents, marks if not marks.is_empty() else "일반"]
		button.tooltip_text = marks if kind.is_empty() else UI.description(kind) + " · " + (marks if not marks.is_empty() else "일반 칸")
		button.disabled = false # Completed layouts can still be inspected.
		UI.paint_button(button, tint, _selected_slot == slot_id)
	_map_help.text = "시설을 고르고 빈 칸을 누르면 배치해요. 확정 전에는 이번 변경을 취소할 수 있어요." if planning else "칸을 골라 3D로 살펴봐요. 배치를 바꾸려면 과거 턴으로 돌아가요."
	var selected := Simulation.facility_at(state, _selected_slot)
	_remove.disabled = not planning or selected.is_empty() or selected.get("type") == "habitat"
	if not selected.is_empty() and selected.type != "habitat":
		@warning_ignore("integer_division")
		var refund: int = selected.actual_paid_cost if selected.instance_id >= _session.state.next_instance_id else int(selected.actual_paid_cost) / 2
		_remove.text = UI.trn("철거 / 취소  +%d 토큰", "Build tokens returned: %d") % refund
	else:
		_remove.text = UI.trn("선택 시설 철거", "Remove selected")
	_cancel.disabled = not planning or _session.draft.is_empty()
	if selected.get("type") == "habitat": _map_help.text = "가운데 거주실은 고정 시설이에요. 옮기거나 철거할 수 없어요."


func _refresh_event(turn: int, planning: bool, draft_state: Dictionary) -> void:
	_event_values.clear()
	var captions: Array[String] = []
	_event_title.text = "오늘의 임무"
	_event_text.text = UI.trn("시설을 놓은 뒤 ‘이번 턴 진행’을 눌러요. 승무원은 산소와 식량을 각각 6씩 써요.",
		"Confirm the layout to run a turn. The crew uses 6 oxygen and 6 food each turn.")
	if not planning:
		_event_text.text = UI.trn("아래에서 지난 턴을 골라 되감고 다른 설계를 시험해요.",
			"Choose an earlier turn below to rewind and try a different plan.")
	elif turn == 2:
		_event_values.assign(["normal", "conserve"])
		captions.assign([UI.trn("재배 유지", "Keep farms on"), UI.trn("절전", "Conserve power")])
	elif turn == 4:
		_event_values.assign(["shelter", "continue"])
		captions.assign([UI.trn("대피하기", "Take shelter"), UI.trn("대피 없이 진행", "Continue without shelter")])
	elif turn == 5:
		_event_values.assign(["acknowledge"])
		captions.assign([UI.trn("확인", "Acknowledge")])
	if planning and turn == 3:
		_event_title.text = "발전기 고장 · 이번 턴까지"
		_event_text.text = Preview.current_effect(draft_state,_choice)
	if planning and Learning.EVENTS.has(turn):
		_event_title.text = Learning.EVENTS[turn][0] + " · 훈련용 가상 사건"
		_event_text.text = Learning.EVENTS[turn][1] + "\n" + Preview.current_effect(draft_state,_choice)
	if turn == 4 and _choice == "shelter" and Simulation.count_kind(draft_state, "shelter") == 0:
		_choice = ""
	_options.visible = not _event_values.is_empty()
	for i in _event_buttons.size():
		var button := _event_buttons[i]
		button.visible = i < _event_values.size()
		if button.visible:
			button.text = captions[i]
			button.disabled = turn == 4 and i == 0 and Simulation.count_kind(draft_state, "shelter") == 0
			button.tooltip_text = UI.trn("먼저 대피소를 지어요.", "Build a shelter first.") if button.disabled else ""
			UI.paint_button(button, UI.AMBER, _choice == _event_values[i])


func _select_candidate(index: int) -> void:
	var candidates := History.candidates(_session)
	if index < candidates.size():
		_select_turn(candidates[index].turn)
		_rewind.grab_focus()
		_scroll.call_deferred("ensure_control_visible", _start_preview)

func _refresh_timeline() -> void:
	var has_record: bool = not _session.current_history.snapshots.is_empty() or not _session.previous_attempt.is_empty()
	_history_empty.visible = _session.current_history.results.is_empty() and _session.previous_attempt.get("results",{}).is_empty()
	_history_toggle.disabled = not has_record
	_history_toggle.text = "과거 기록 닫기" if _history_open and has_record else "과거 기록 · 되감기와 비교"
	_history_body.visible = has_record and _history_open
	var candidates := History.candidates(_session)
	_candidate_note.text = "저장된 시작점의 탐색 후보예요. 성공을 보장하지 않아요. 눌러서 살펴본 뒤 복원할지 골라요." if not candidates.is_empty() else "확실한 후보를 찾지 못했어요. 과거 상태를 함께 살펴봐요. 아래 턴을 눌러 직접 확인해요."
	for i in _candidate_buttons.size():
		_candidate_buttons[i].visible = i < candidates.size()
		if i < candidates.size(): _candidate_buttons[i].text = candidates[i].text
	for i in _timeline.size():
		var id := i + 1
		var archived: Dictionary = _session.previous_attempt
		var readable: bool = not _session.snapshot(id).is_empty() or archived.get("snapshots",{}).has(str(id)) or archived.get("results",{}).has(str(id)) or not _session.result_at(id).is_empty()
		_timeline[i].disabled = not readable
		UI.paint_button(_timeline[i], UI.CYAN, id == _timeline_turn)
	var start: Dictionary = _session.snapshot(_timeline_turn)
	_rewind.disabled = _locked or start.is_empty()
	_start_preview.text = "복원 대상 · T%d 시작\n%s" % [_timeline_turn,History.start_line(start)] if not start.is_empty() else "T%d는 이전 시도의 조회 전용 기록이에요. 현재 보관된 시작점이 없어 복원할 수 없어요." % _timeline_turn
	if not start.is_empty(): _start_preview.text += "\n복원하면 지금 편집 중인 배치는 버리고, 저장된 시작 상태로 돌아가요."
	_compare_title.text = "T%d / 같은 턴 비교 · 시작 상태와 실행 결과를 구분해요" % _timeline_turn
	_prior.text = History.side(_session,_timeline_turn,true)
	_current.text = History.side(_session,_timeline_turn,false)
	_delta.text = History.changes(_session,_timeline_turn)


func _result_line(result: Dictionary) -> String:
	var ending: Dictionary = result.state_after
	return UI.trn("T%d %s · 전력 %d / 산소 %d / 식량 %d", "T%d %s · P %d / O %d / F %d") % [
		result.turn_id, UI.phase_text(result.phase), ending.E, ending.O, ending.F]


func _result_text(result: Dictionary) -> String:
	if result.is_empty():
		return ""
	var text := _result_line(result)
	var before: Dictionary = _session.snapshot(int(result.turn_id)) if _session != null else {}
	text += "\n" + Preview.flow_lines(before,result)
	match result.phase:
		"failed_power":
			text += UI.trn("\n산소·재배·보급·식량 계산 전에 멈췄어요.", "\nStopped before oxygen, growth, supply, and food.")
		"failed_safety":
			text += UI.trn("\n대피소를 짓고 대피하면 계속할 수 있어요.", "\nBuild a shelter and take cover to continue.")
	return text


func _select_slot(slot: int) -> void:
	clear_notice()
	_selected_slot = slot
	var preview: Dictionary = _session.preview()
	if _session.state.phase == "planning" and Simulation.facility_at(preview.state, slot).is_empty():
		edited.emit("place", slot, _selected_kind)
	refresh(_session)


func _select_kind(kind: String) -> void:
	clear_notice()
	_selected_kind = kind
	refresh(_session)
	set_notice(UI.trn("%s 선택 · 비어 있는 칸을 눌러요.", "%s selected. Choose an empty pad.") % UI.name_for(kind))


func _choose_event(index: int) -> void:
	clear_notice()
	_choice = _event_values[index]
	refresh(_session)


func _advance_turn() -> void:
	if _locked or _session.state.phase != "planning":
		return
	_locked = true
	_advance.disabled = true
	advanced.emit(_choice)
	# A double click belongs to the turn the player saw, not the next turn.
	await get_tree().create_timer(0.42).timeout
	_locked = false
	refresh(_session)


func _select_turn(turn: int) -> void:
	_timeline_turn = turn
	_refresh_timeline()


func on_result(turn: int) -> void:
	_timeline_turn = turn
	_history_open = false
	_selected_slot = -1
	_choice = ""
	clear_notice()


func on_restore(turn: int) -> void:
	_timeline_turn = turn
	_selected_slot = -1
	_choice = ""
	_last_turn = -1


func set_notice(message: String, warning := false) -> void:
	_notice.text = message
	_notice.visible = not message.is_empty()
	_notice.add_theme_color_override("font_color", UI.ALERT if warning else UI.CYAN)


func clear_notice() -> void:
	set_notice("")


func focus_primary() -> void:
	if _outcome_card.visible:
		_close.grab_focus()
	elif not _facilities[_selected_kind].disabled:
		_facilities[_selected_kind].grab_focus()
	else:
		_close.grab_focus()
