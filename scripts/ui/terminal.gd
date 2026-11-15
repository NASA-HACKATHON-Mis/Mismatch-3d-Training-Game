extends Control

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


func _ready() -> void:
	UI.use_korean_theme(self)
	var shade := ColorRect.new()
	shade.color = Color("#06101de9")
	shade.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(shade)
	var scroll := ScrollContainer.new()
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
	_build_guidance(outer)
	_working = BoxContainer.new()
	_working.add_theme_constant_override("separation", 12)
	outer.add_child(_working)
	_build_map(_working)
	_build_controls(_working)
	_build_timeline(outer)
	_notice = UI.label(outer, "", 16, UI.CYAN)
	_notice.custom_minimum_size.y = 24
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
	grid.size_flags_vertical = SIZE_EXPAND_FILL
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
	_result = UI.label(controls, "", 18, UI.TEXT, true)
	_result.custom_minimum_size.y = 58


func _build_timeline(parent: Control) -> void:
	var panel := UI.panel(parent, Color("#0d192b"), 12)
	var content := UI.column(panel, 8)
	_history_toggle = UI.button(content, "과거 기록 · 되감기와 비교", _toggle_history, UI.CYAN)
	_history_empty = UI.label(content, "아직 끝낸 턴이 없어요. 턴을 진행하면 기록을 볼 수 있어요.", 18, UI.MUTED, true)
	_history_body = UI.column(content, 8)
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
	for kind: String in _facilities:
		var button: Button = _facilities[kind]
		UI.paint_button(button, UI.FACILITY_COLORS[kind], kind == _selected_kind)
		button.disabled = not planning
	_refresh_event(turn, planning, edit_state)
	_advance.text = UI.trn("이번 턴 진행 · T%d", "Advance this turn · T%d") % turn if planning else UI.phase_text(state.phase)
	_advance.disabled = _locked or not planning or (_event_values.size() > 0 and _choice.is_empty())
	var last: Dictionary = session.result_at(turn - 1 if planning else turn)
	_result.text = _result_text(last)
	if last.is_empty():
		_result.text = UI.trn("아직 결과가 없어요. 이번 턴을 진행하면 자원의 변화를 볼 수 있어요.",
			"No result yet. Advance this turn to see resource changes.")
	_refresh_guidance(planning, edit_state)
	_refresh_timeline()


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
		var contents: String = GLYPHS.get(kind, marks if not marks.is_empty() else "·")
		var tint: Color = UI.FACILITY_COLORS.get(kind, UI.AMBER if sun else (UI.PURPLE if shield else UI.MUTED))
		if not kind.is_empty():
			contents = UI.name_for(kind)
		button.text = "%02d\n%s" % [slot_id + 1, contents]
		button.tooltip_text = marks if kind.is_empty() else UI.description(kind)
		button.disabled = not planning
		UI.paint_button(button, tint, _selected_slot == slot_id)
	_map_help.text = UI.description(_selected_kind)
	var selected := Simulation.facility_at(state, _selected_slot)
	_remove.disabled = not planning or selected.is_empty() or selected.get("type") == "habitat"
	if not selected.is_empty() and selected.type != "habitat":
		@warning_ignore("integer_division")
		var refund: int = selected.actual_paid_cost if selected.instance_id >= _session.state.next_instance_id else int(selected.actual_paid_cost) / 2
		_remove.text = UI.trn("철거 / 취소  +%d 토큰", "Build tokens returned: %d") % refund
	else:
		_remove.text = UI.trn("선택 시설 철거", "Remove selected")
	_cancel.disabled = not planning or _session.draft.is_empty()


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
	if planning and Learning.EVENTS.has(turn):
		_event_title.text = Learning.EVENTS[turn][0] + " · 훈련용 가상 사건"
		_event_text.text = Learning.EVENTS[turn][1]
	if turn == 4 and _choice == "shelter" and Simulation.count_kind(draft_state, "shelter") == 0:
		_choice = ""
	for i in _event_buttons.size():
		var button := _event_buttons[i]
		button.visible = i < _event_values.size()
		if button.visible:
			button.text = captions[i]
			button.disabled = turn == 4 and i == 0 and Simulation.count_kind(draft_state, "shelter") == 0
			button.tooltip_text = UI.trn("먼저 대피소를 지어요.", "Build a shelter first.") if button.disabled else ""
			UI.paint_button(button, UI.AMBER, _choice == _event_values[i])


func _refresh_timeline() -> void:
	var has_result: bool = not _session.current_history.results.is_empty() or not _session.previous_attempt.get("results", {}).is_empty()
	_history_empty.visible = not has_result
	_history_toggle.disabled = not has_result
	_history_toggle.text = "과거 기록 닫기" if _history_open and has_result else "과거 기록 · 되감기와 비교"
	_history_body.visible = has_result and _history_open
	for i in _timeline.size():
		var button := _timeline[i]
		var id := i + 1
		button.disabled = _session.snapshot(id).is_empty()
		UI.paint_button(button, UI.CYAN, id == _timeline_turn)
	_rewind.disabled = _locked or _session.result_at(_timeline_turn).is_empty()
	_compare_title.text = UI.trn("T%d   /   같은 턴 비교", "T%d   /   SAME TURN COMPARISON") % _timeline_turn
	var compared: Dictionary = _session.compare_turn(_timeline_turn)
	if compared.is_empty():
		_prior.text = UI.trn("이전 시도 · 기록 없음", "Previous attempt  ·  awaiting result")
		_current.text = UI.trn("이번 시도 · 기록 없음", "Current attempt  ·  awaiting result")
		var old: Dictionary = _session.previous_attempt.get("results", {}).get(str(_timeline_turn), {})
		var latest: Dictionary = _session.result_at(_timeline_turn)
		if not old.is_empty():
			_prior.text = _result_line(old)
		if not latest.is_empty():
			_current.text = _result_line(latest)
		_delta.text = UI.trn("되감아 같은 턴을 다시 실행하면 두 결과를 비교해요.",
			"Rewind and replay this turn to compare both results.")
		return
	_prior.text = "이전 시도 / " + _result_line(compared.previous) + "\n" + Learning.attempt_note(compared.previous)
	_current.text = "이번 시도 / " + _result_line(compared.current) + "\n" + Learning.attempt_note(compared.current)
	var difference: Dictionary = compared.delta
	_delta.text = "변화   전력 %s   ·   산소 %s   ·   식량 %s" % [
		UI.signed_delta(difference.E), UI.signed_delta(difference.O), UI.signed_delta(difference.F)]
	_delta.text += "\n" + Learning.comparison_prompt(compared)


func _result_line(result: Dictionary) -> String:
	var ending: Dictionary = result.state_after
	return UI.trn("T%d %s · 전력 %d / 산소 %d / 식량 %d", "T%d %s · P %d / O %d / F %d") % [
		result.turn_id, UI.phase_text(result.phase), ending.E, ending.O, ending.F]


func _result_text(result: Dictionary) -> String:
	if result.is_empty():
		return ""
	var text := _result_line(result)
	var stats: Dictionary = result.stats
	if not stats.is_empty():
		text += "\n전력 생산 %d · 전력 소비 %d" % [stats.generation, stats.demand]
		if result.get("not_applied_steps", []).has("growth"):
			text += "\n식량 수확·보급: 계산 전 중단"
		else:
			text += "\n식량 수확 %d · 식량 보급 %d" % [stats.harvest, stats.supply]
	match result.phase:
		"failed_power":
			text += UI.trn("\n산소·재배·보급·식량 계산 전에 멈췄어요.", "\nStopped before oxygen, growth, supply, and food.")
		"failed_safety":
			text += UI.trn("\n대피소를 짓고 대피하면 계속할 수 있어요.", "\nBuild a shelter and take cover to continue.")
	return text


func _select_slot(slot: int) -> void:
	_selected_slot = slot
	var preview: Dictionary = _session.preview()
	if Simulation.facility_at(preview.state, slot).is_empty():
		edited.emit("place", slot, _selected_kind)
	_refresh_map(_session.preview().state, _session.state.phase == "planning")


func _select_kind(kind: String) -> void:
	_selected_kind = kind
	refresh(_session)
	set_notice(UI.trn("%s 선택 · 비어 있는 칸을 눌러요.", "%s selected. Choose an empty pad.") % UI.name_for(kind))


func _choose_event(index: int) -> void:
	_choice = _event_values[index]
	refresh(_session)


func _advance_turn() -> void:
	if _locked:
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
	_notice.add_theme_color_override("font_color", UI.ALERT if warning else UI.CYAN)


func clear_notice() -> void:
	set_notice("")


func focus_primary() -> void:
	if not _facilities[_selected_kind].disabled:
		_facilities[_selected_kind].grab_focus()
	else:
		_close.grab_focus()
