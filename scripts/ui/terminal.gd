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
signal advice_request_changed(enabled: bool)

const UI = preload("res://scripts/ui/ui_style.gd")
const Rules = preload("res://scripts/simulation/scenario.gd")
const Simulation = preload("res://scripts/simulation/simulation.gd")
const Preview = preload("res://scripts/simulation/turn_preview.gd")
const History = preload("res://scripts/ui/history_explanation.gd")
const Outcome = preload("res://scripts/ui/outcome_summary.gd")
const Learning = preload("res://resources/content/learning.gd")
const ResourceOverview = preload("res://scripts/ui/resource_overview.gd")
const FacilityInfoCard = preload("res://scripts/ui/facility_info_card.gd")
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
var _place: Button
var _cancel: Button
var _rewind: Button
var _summary: Label
var _resource_grid: GridContainer
var _resource_overview: ResourceOverview
var _facility_info: FacilityInfoCard
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
var _action_dock: PanelContainer
var _event_row: HBoxContainer
var _advice_toggle: Button
var _communication_label: Label
var _communication_data: Dictionary = {}
var _advice_requested := false
var _weather_label: Label
var _weather_context: Dictionary = {}
var _food_detail: Label


func _ready() -> void:
	UI.use_korean_theme(self)
	var shade := ColorRect.new()
	shade.color = Color("#06101de9")
	shade.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(shade)
	var frame := VBoxContainer.new()
	frame.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	frame.offset_left = 16
	frame.offset_right = -16
	frame.offset_top = 8
	frame.offset_bottom = -8
	frame.add_theme_constant_override("separation", 8)
	add_child(frame)
	_build_header(frame)
	_scroll = ScrollContainer.new()
	_scroll.size_flags_vertical = SIZE_EXPAND_FILL
	_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	_scroll.follow_focus = true
	frame.add_child(_scroll)
	var outer := VBoxContainer.new()
	outer.size_flags_horizontal = SIZE_EXPAND_FILL
	outer.size_flags_vertical = SIZE_EXPAND_FILL
	outer.add_theme_constant_override("separation", 10)
	_scroll.add_child(outer)
	_build_outcome(outer)
	_working = BoxContainer.new()
	_working.add_theme_constant_override("separation", 12)
	outer.add_child(_working)
	_build_map(_working)
	_build_controls(_working)
	_build_guidance(outer)
	_build_timeline(outer)
	_build_action_dock(frame)
	resized.connect(_layout)
	_layout()


func _build_header(parent: Control) -> void:
	var panel := UI.panel(parent, UI.CARD, 8)
	var contents := UI.column(panel, 4)
	_header_actions = BoxContainer.new()
	contents.add_child(_header_actions)
	var title := UI.label(_header_actions, "Base dashboard", 22)
	UI.grow(title)
	help_button = UI.button(_header_actions, "Guide  H", func(): help_requested.emit(), UI.CYAN)
	_close = UI.button(_header_actions, "Close  Esc", func(): closed.emit(), UI.MUTED)
	_summary = UI.label(contents, "", 18, UI.TEXT, true)
	_resource_overview = ResourceOverview.new()
	contents.add_child(_resource_overview)
	_resource_grid = _resource_overview
	_weather_label = UI.label(contents, "Checking space weather records · Training events occur on fixed turns", 16, UI.MUTED, true)

func _build_action_dock(parent: Control) -> void:
	_action_dock = UI.panel(parent, Color("#133047"), 8)
	var dock := UI.column(_action_dock, 5)
	_event_row = UI.row(dock, 8)
	_event_title.reparent(_event_row)
	_event_title.add_theme_font_size_override("font_size", 16)
	_event_title.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	UI.grow(_event_title)
	_options.reparent(_event_row)
	UI.grow(_options)
	var actions := UI.row(dock, 6)
	_advice_toggle = UI.button(actions, "Ask Earth · 1 power", _toggle_advice, UI.PURPLE, 42)
	_advice_toggle.toggle_mode = true
	_advice_toggle.add_theme_font_size_override("font_size", 16)
	_advice_toggle.tooltip_text = "Uses 1 power when you run this turn. The reply arrives after the next turn."
	UI.grow(_advice_toggle)
	_advance.reparent(actions)
	_advance.add_theme_font_size_override("font_size", 18)
	UI.grow(_advance)
	_advance_reason.reparent(dock)
	_advance_reason.add_theme_font_size_override("font_size", 16)
	_notice.reparent(dock)
	_notice.add_theme_font_size_override("font_size", 16)
	_notice.max_lines_visible = 2

func set_communication_state(data: Dictionary, requested: bool) -> void:
	_communication_data = data.duplicate(true)
	_advice_requested = requested
	if is_instance_valid(_advice_toggle): _refresh_communication()

func _toggle_advice() -> void:
	if _advice_toggle.disabled: return
	# This is a request signal; only the session owner may accept or mutate it.
	advice_request_changed.emit(_advice_toggle.button_pressed)
	_advice_toggle.set_pressed_no_signal(_advice_requested)

func _refresh_communication() -> void:
	var pending: bool = not _communication_data.get("pending", {}).is_empty()
	var delay := int(_training_profile().get("communication_delay", 1))
	var too_late: bool = _session != null and int(_session.state.turn_id) + delay > 7
	var unavailable: bool = _session == null or _session.state.phase != "planning" or too_late or int(_session.state.E) < 1
	_advice_toggle.disabled = _locked or pending or (unavailable and not _advice_requested)
	_advice_toggle.set_pressed_no_signal(_advice_requested)
	_advice_toggle.text = "Waiting for a reply" if pending else ("Cancel advice request" if _advice_requested else "Ask Earth · 1 power")
	var timing := "After the next turn" if delay == 1 else "After %d turns" % delay
	_advice_toggle.tooltip_text = "Confirming this turn costs 1 power · Reply %s. %s" % [timing, "CME records set this training reply delay." if delay > 1 else "This is a game delay, not a real signal travel time."]
	UI.paint_button(_advice_toggle, UI.PURPLE, _advice_requested)
	var message := str(_communication_data.get("message", ""))
	var response_turn := int(_communication_data.get("response_turn", 0))
	if pending:
		var arrival := int(_communication_data.pending.get("reply_turn", response_turn))
		_communication_label.text = "Contacting Earth · Reply arrives after T%d." % arrival
		if _session != null and _session.state.phase != "planning":
			_advice_toggle.text = "Transmission interrupted"
			_communication_label.text = "Mission stopped. Rewind to a past turn and try another plan."
	elif not message.is_empty():
		_communication_label.text = "Earth's reply · T%d\n%s" % [response_turn, message]
	elif _advice_requested:
		_communication_label.text = "Advice queued · Uses 1 power when the turn runs. Reply %s." % timing
	else:
		_communication_label.text = "Ask Earth · 1 power · Reply %s." % timing
	if delay > 1 and not pending: _communication_label.text += "\nCME records → training reply delay %d turns." % delay
	if too_late and not pending:
		_communication_label.text = "A new reply takes %d turns and would arrive after T7. You cannot request it now." % delay

func set_weather_context(data: Dictionary) -> void:
	_weather_context = data.duplicate(true)
	if not is_instance_valid(_weather_label): return
	_refresh_weather_label()
	if _session != null: refresh(_session)

func _training_profile() -> Dictionary:
	if _session != null and not _session.state.get("weather", {}).is_empty():
		return _session.state.weather
	return _weather_context.get("training_profile", {})

func _refresh_weather_label() -> void:
	var data := _weather_context
	var profile := _training_profile()
	var stamp := str(data.get("observed_at", ""))
	var class_type := str(profile.get("flare_class", data.get("class_type", "Class unavailable")))
	if data.get("records", {}).has("FLR") and data.records.FLR.is_empty():
		class_type = "No observation"
		stamp = ""
	for record: Dictionary in data.get("records", {}).get("FLR", []):
		if record.get("event_id", "") == profile.get("flare_event_id", ""):
			stamp = str(record.get("observed_at", stamp))
	var observed := stamp.left(10) if not stamp.is_empty() else "Date unavailable"
	var mode: String = str(data.get("source_label", {"live":"Fetched NASA records · not a live feed", "archive":"Embedded historical data · not live", "mixed":"Mixed: fetched + historical · not a live feed"}.get(str(data.get("mode", "archive")), "Embedded historical data · not live")))
	_weather_label.text = "NASA · %s · FLR %s · %s" % [mode, class_type, observed]
	if not profile.is_empty():
		var sep := " + SEP records" if not str(profile.get("sep_event_id", "")).is_empty() else ""
		_weather_label.text += "%s → Training T4 %s" % [sep, _alert_label(profile)]
		_weather_label.text += "\n%s · Shielding power %d · Reply delay %d turns" % ["Shelter required" if profile.get("shelter_required", true) else "Shelter optional", int(profile.get("protection_energy", 0)), int(profile.get("communication_delay", 1))]
	_weather_label.tooltip_text = str(data.get("explanation", "")) + "\nReal records select training alerts, costs and reply delays. These are game rules, not radiation or signal-delay predictions."

func _alert_label(profile: Dictionary) -> String:
	return {"watch":"Watch", "warning":"Warning", "severe":"High alert"}.get(str(profile.get("alert_level", "")), "Check records")

func _shield_instruction(profile: Dictionary) -> String:
	if profile.is_empty(): return ""
	return "T4 %s · %s\nSheltering costs %d extra power" % [_alert_label(profile), "Shelter required" if profile.get("shelter_required", true) else "Shelter optional", int(profile.get("protection_energy", 0))]

func _build_outcome(parent: Control) -> void:
	_outcome_card = UI.panel(parent, Color("#133047"), 16)
	var contents := UI.column(_outcome_card, 10)
	_outcome_title = UI.label(contents, "", 28, UI.CYAN, true)
	_outcome_reason = UI.label(contents, "", 18, UI.TEXT, true)
	_outcome_action = UI.button(contents, "Retry from history", _open_outcome_history, UI.AMBER)
	_outcome_toggle = UI.button(contents, "Show choices and resources", _toggle_outcome_details, UI.MUTED)
	_outcome_details = UI.label(contents, "", 18, UI.TEXT, true)
	_outcome_details.hide()
	_outcome_card.hide()

func _toggle_outcome_details() -> void:
	_outcome_details.visible = not _outcome_details.visible
	_outcome_toggle.text = "Hide choices and resources" if _outcome_details.visible else "Show choices and resources"

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
		_outcome_toggle.text = "Show choices and resources"
		return
	_outcome_title.text = Outcome.heading(state)
	_outcome_title.add_theme_color_override("font_color", UI.CYAN if state.phase == "completed" else UI.ALERT)
	_outcome_reason.text = Outcome.reason(_session.result_at(state.turn_id))
	_outcome_details.text = Outcome.history_lines(_session)
	_outcome_action.text = "History · Rewind and compare" if state.phase == "completed" else "Retry from history"

func _build_guidance(parent: Control) -> void:
	var card := UI.panel(parent, Color("#133047"), 12)
	var contents := UI.column(card, 6)
	var heading := UI.row(contents, 8)
	var title := UI.label(heading, "Next step", 16, UI.CYAN)
	UI.grow(title)
	_guide_toggle = UI.button(heading, "Skip tutorial", _toggle_guidance, UI.MUTED, 30)
	_guide_toggle.add_theme_font_size_override("font_size", 16)
	_guide_body = UI.column(contents, 4)
	_guide_text = UI.label(_guide_body, "", 20, UI.TEXT, true)

func _toggle_guidance() -> void:
	set_guidance(not guidance_enabled)
	guidance_changed.emit(guidance_enabled)

func set_guidance(enabled: bool) -> void:
	guidance_enabled = enabled
	_guide_body.visible = enabled
	_guide_toggle.text = "Skip tutorial" if enabled else "Replay tutorial"

func _layout() -> void:
	if not is_instance_valid(_working): return
	_working.vertical = size.x < 900
	_working.move_child(_map_card, 0)
	_header_actions.vertical = size.x < 600
	_timeline_top.vertical = size.x < 1100
	_comparison_sides.vertical = size.x < 900

func _refresh_guidance(planning: bool, edit_state: Dictionary) -> void:
	if not planning:
		_guide_text.text = "Read your results, then choose a past turn to retry."
	elif not _session.draft.is_empty():
		_guide_text.text = "Review your layout here. To change it, go to a pad and press 1."
	else:
		_guide_text.text = "Go to an empty pad and press 1 to build. Return here to check your base."
	if planning and not _event_values.is_empty():
		_guide_text.text = "2  Choose how to respond to the event." if _choice.is_empty() else "3  Ready? Select Run turn."
	elif planning and Simulation.count_kind(edit_state, "generator") > 0:
		_guide_text.text = "Ready? Select Run turn. Change facilities at their pads."


func _build_map(parent: Control) -> void:
	var card := UI.panel(parent, UI.CARD, 10)
	_map_card = card
	UI.grow(card)
	card.size_flags_stretch_ratio = 0.94
	var map := UI.column(card, 5)
	UI.label(map, "Base map · Select a pad", 16, UI.CYAN)
	UI.label(map, "North ↑ · SUN: more power · SH: shelter discount", 14, UI.MUTED, true)
	var grid := GridContainer.new()
	grid.columns = 5
	grid.size_flags_vertical = SIZE_SHRINK_BEGIN
	grid.add_theme_constant_override("h_separation", 5)
	grid.add_theme_constant_override("v_separation", 5)
	map.add_child(grid)
	for slot_id in Rules.SLOT_COUNT:
		var button := UI.button(grid, "", _select_slot.bind(slot_id), UI.TEXT, 46)
		UI.grow(button)
		button.size_flags_vertical = SIZE_EXPAND_FILL
		button.add_theme_font_size_override("font_size", 14)
		_slots.append(button)
	_map_help = UI.label(map, "", 15, UI.MUTED, true)
	var selection_actions := UI.row(map, 5)
	_inspect = UI.button(selection_actions,"3D view",_on_facility_action.bind("inspect"),UI.CYAN, 30)
	_clear_selection = UI.button(selection_actions,"Clear selection",func(): open_context(),UI.MUTED, 30)
	var buttons := UI.row(map)
	buttons.hide()
	# Compatibility controls stay inert, including manually emitted pressed signals.
	_remove = UI.button(buttons, UI.trn("Remove selected", "Remove selected"),
		func(): _on_facility_action("remove"), UI.ALERT, 36)
	_cancel = UI.button(buttons, UI.trn("Cancel this turn’s changes", "Cancel this turn’s changes"),
		_show_site_required, UI.MUTED, 36)
	_remove.disabled = true
	_cancel.disabled = true


func _build_controls(parent: Control) -> void:
	var card := UI.panel(parent)
	_controls_card = card
	UI.grow(card)
	card.size_flags_stretch_ratio = 1.06
	var controls := UI.column(card, 6)
	UI.label(controls, "Selected pad and base status", 16, UI.CYAN)
	_facility_info = FacilityInfoCard.new()
	controls.add_child(_facility_info)
	_facility_info.action_requested.connect(_on_facility_action)
	_selection_detail = UI.label(controls, "", 18, UI.TEXT, true)
	_selection_detail.hide()
	_place = UI.button(controls, "Build here", _place_selected, UI.GREEN, 38)
	_place.hide()
	_place.disabled = true
	_notice = UI.label(controls, "", 18, UI.ALERT, true)
	_notice.hide()
	_capacity = UI.label(controls, "", 18, UI.CYAN, true)
	_food_detail = UI.label(controls, "", 16, UI.GREEN, true)
	_communication_label = UI.label(controls, "", 16, UI.PURPLE, true)
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
	_preview_toggle = UI.button(controls, "Show turn forecast", _toggle_preview, UI.MUTED, 36)
	_preview_detail = UI.label(controls, "", 18, UI.TEXT, true)
	_preview_detail.hide()
	_result = UI.label(controls, "", 18, UI.TEXT, true)
	_result.custom_minimum_size.y = 58


func _build_timeline(parent: Control) -> void:
	var panel := UI.panel(parent, Color("#0d192b"), 12)
	var content := UI.column(panel, 8)
	_history_toggle = UI.button(content, "History · Rewind and compare", _toggle_history, UI.CYAN)
	_history_empty = UI.label(content, "No result yet. Open a saved starting state below.", 18, UI.MUTED, true)
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
	_rewind = UI.button(_timeline_top, "Restore turn start", func(): rewound.emit(_timeline_turn), UI.PURPLE, 40)
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
	_summary.text = "T%d / 7 · Build tokens %d · Build/remove on site: 1" % [turn, edit_state.budget]
	var has_shelter := Simulation.count_kind(edit_state, "shelter") > 0
	var shield_status := "selected" if has_shelter and turn == 4 and _choice == "shelter" else ("prepared" if has_shelter else "absent")
	_resource_overview.set_view_model({"mission_status":true, "shield_status":shield_status, "shield_detail":_shield_instruction(_training_profile()), "show_preview": not session.draft.is_empty(), "resources": [
		{"id":"energy", "current":state.E, "capacity":Simulation.energy_cap(state), "preview":edit_state.E, "preview_capacity":Simulation.energy_cap(edit_state)},
		{"id":"oxygen", "current":state.O, "capacity":100, "preview":edit_state.O, "preview_capacity":100},
		{"id":"food", "current":state.F, "capacity":100, "preview":edit_state.F, "preview_capacity":100}]})
	_refresh_map(edit_state, planning)
	_refresh_facilities(edit_state, planning)
	_refresh_event(turn, planning, edit_state)
	_advance.text = UI.trn("Run turn · T%d", "Run turn · T%d") % turn if planning else UI.phase_text(state.phase)
	_advance.disabled = _locked or not planning or (_event_values.size() > 0 and _choice.is_empty())
	var last: Dictionary = session.result_at(turn - 1 if planning else turn)
	_result.text = _result_text(last)
	if last.is_empty():
		_result.text = UI.trn("No result yet. Advance this turn to see resource changes.", "No result yet. Advance this turn to see resource changes.")
	_refresh_preview(planning, edit_state)
	_refresh_guidance(planning, edit_state)
	_refresh_timeline()
	_refresh_outcome()
	_inspect.disabled = _selected_slot < 0
	_clear_selection.disabled = _selected_slot < 0
	_refresh_info_card(edit_state, planning)
	_food_detail.text = "Stored food · Now %d/100" % state.F
	if not session.draft.is_empty(): _food_detail.text += " · After layout %d/100" % edit_state.F
	_food_detail.text += "\nUse 6 each turn. At 0, the mission stops."
	_refresh_communication()
	if not _weather_context.is_empty(): _refresh_weather_label()
	selected_slot_changed.emit(_selected_slot)


func _refresh_info_card(layout: Dictionary, _planning: bool) -> void:
	var facility: Dictionary = Simulation.facility_at(layout, _selected_slot)
	var occupied := not facility.is_empty()
	var kind: String = facility.type if occupied else "empty"
	var summaries := {"generator":"Make power from sunlight.", "battery":"Store more power.", "greenhouse":"Use power to grow food.", "shelter":"A safe place during alerts.", "habitat":"A home for the crew."}
	var title := UI.name_for(kind) if occupied else "Empty pad"
	var summary: String = summaries.get(kind, "Go to this pad and press 1 to build.")
	if _selected_slot < 0:
		title = "Explore your base"
		summary = "Select a pad for facility details and a 3D view."
	var effect := _card_effect(kind)
	if kind == "habitat": effect = "Base hub · Cannot remove"
	var effects: Array = [{"icon_id":kind,"label":"Role","value_text":effect}] if occupied else []
	_facility_info.set_view_model({"slot_id":_selected_slot, "kind":kind, "title":title,
		"summary":summary, "cost_text":"", "effects":effects,
		"details":UI.description(kind) if occupied else "", "actions":[]})

func _on_facility_action(action_id: String) -> void:
	if _session == null or not visible: return
	match action_id:
		"place", "remove": _show_site_required()
		"inspect":
			if _selected_slot >= 0 and _selected_slot < Rules.SLOT_COUNT: inspect_requested.emit()

func _card_effect(kind: String) -> String:
	match kind:
		"generator": return "Sun pad +18 power / Other +12"
		"battery": return "Storage +20 · No generation"
		"greenhouse": return "Uses 4 power · +18 food every 3 active turns"
		"shelter": return "Shelter during alerts · Shield-pad discount"
	return ""

func _cost_caption(kind: String) -> String:
	if kind == "shelter" and _selected_slot < 0: return "3~4"
	return str(Rules.cost(kind, maxi(0,_selected_slot)))

func _refresh_facilities(_layout_state: Dictionary, _planning: bool) -> void:
	for button: Button in [_place, _remove, _cancel]:
		button.hide()
		button.disabled = true

func _toggle_preview() -> void:
	_preview_open = not _preview_open
	_preview_detail.visible = _preview_open
	_preview_toggle.text = "Hide turn forecast" if _preview_open else "Show turn forecast"

func _refresh_preview(planning: bool, layout: Dictionary) -> void:
	_advance_reason.text = ""
	if not planning:
		_advance_reason.text = "Mission finished. Choose a past turn to retry."
	elif _locked: _advance_reason.text = "Running this turn."
	elif not _event_values.is_empty() and _choice.is_empty():
		_advance_reason.text = "Choose an event response first."
	_advance_reason.visible = not _advance_reason.text.is_empty()
	_preview_toggle.visible = planning
	_preview_detail.visible = planning and _preview_open
	if not planning:
		_capacity.text = "Current power %d/%d" % [_session.state.E,Simulation.energy_cap(_session.state)]
		return
	var prediction: Dictionary = Preview.inspect(_session.snapshot(_session.state.turn_id),_session.draft,_choice,{},_session.advice_requested)
	if prediction.has("error"):
		_preview_detail.text = UI.error_text(prediction.error)
		return
	_capacity.text = "Current power %d/%d · Capacity after layout %d" % [prediction.current_energy,prediction.current_capacity,prediction.layout_capacity]
	if _session.draft.is_empty():
		_capacity.text = "Current power %d/%d · Layout unchanged" % [prediction.current_energy,prediction.current_capacity]
	if prediction.spill > 0: _capacity.text += "\nConfirming this layout removes %d excess power before the turn." % prediction.spill
	var lines: Array[String] = ["Turn forecast · Your current resources have not changed yet."]
	if prediction.conditional: lines.append("Your choice matters. Compare the forecasts for each response below.")
	for outcome: Dictionary in prediction.outcomes:
		var result: Dictionary = outcome.result
		var label: String = Preview.choice_label(outcome.choice)
		if not outcome.available:
			lines.append(label + ": Build a shelter first.")
			continue
		if result.has("error"):
			lines.append(label + ": " + UI.error_text(result.error))
			continue
		lines.append(label + " · " + UI.phase_text(result.phase))
		lines.append(Preview.flow_lines(_session.state,result))
	lines.append(Preview.current_effect(layout,_choice))
	lines.append(Preview.growth_lines(layout,_choice))
	_preview_detail.text = "\n".join(lines)

func _refresh_map(state: Dictionary, _planning: bool) -> void:
	for slot_id in Rules.SLOT_COUNT:
		var facility := Simulation.facility_at(state, slot_id)
		var kind: String = facility.get("type", "")
		var sun: bool = Rules.SUNLIT.has(slot_id)
		var shield: bool = Rules.SHIELDED.has(slot_id)
		var marks := ""
		if sun and shield:
			marks = UI.trn("SUN/SH", "SUN/SH")
		elif sun:
			marks = UI.trn("SUN", "SUN")
		elif shield:
			marks = UI.trn("SHIELD", "SHIELD")
		var button := _slots[slot_id]
		var contents: String = GLYPHS.get(kind, "Empty pad")
		var tint: Color = UI.FACILITY_COLORS.get(kind, UI.AMBER if sun else (UI.PURPLE if shield else UI.MUTED))
		if not kind.is_empty():
			contents = UI.name_for(kind)
		var short_marks := "SUN/SH" if sun and shield else ("SUN" if sun else ("SH" if shield else ""))
		button.text = "%02d %s\n%s" % [slot_id + 1, short_marks, contents]
		button.tooltip_text = marks if kind.is_empty() else UI.description(kind) + " · " + (marks if not marks.is_empty() else "Normal pad")
		button.disabled = false # Completed layouts can still be inspected.
		UI.paint_button(button, tint, _selected_slot == slot_id)
	_map_help.text = "Map is read-only · Build/remove at a pad with 1"
	var selected := Simulation.facility_at(state, _selected_slot)
	if selected.get("type") == "habitat": _map_help.text = "The central habitat is fixed. It cannot be moved or removed."

func _refresh_event(turn: int, planning: bool, draft_state: Dictionary) -> void:
	_event_values.clear()
	var captions: Array[String] = []
	_event_title.text = "Your mission"
	_event_text.text = UI.trn("Confirm the layout to run a turn. The crew uses 6 oxygen and 6 food each turn.", "Confirm the layout to run a turn. The crew uses 6 oxygen and 6 food each turn.")
	if not planning:
		_event_text.text = UI.trn("Choose an earlier turn below to rewind and try a different plan.", "Choose an earlier turn below to rewind and try a different plan.")
	elif turn == 2:
		_event_values.assign(["normal", "conserve"])
		captions.assign([UI.trn("Keep farms on", "Keep farms on"), UI.trn("Conserve power", "Conserve power")])
	elif turn == 4:
		_event_values.assign(["shelter", "continue"])
		captions.assign([UI.trn("Take shelter", "Take shelter"), UI.trn("Continue without shelter", "Continue without shelter")])
	elif turn == 5:
		_event_values.assign(["acknowledge"])
		captions.assign([UI.trn("Acknowledge", "Acknowledge")])
	if planning and turn == 3:
		_event_title.text = "Solar array fault · Ends this turn"
		_event_text.text = Preview.current_effect(draft_state,_choice)
	if planning and Learning.EVENTS.has(turn):
		_event_title.text = Learning.EVENTS[turn][0] + " · Training scenario"
		_event_text.text = Learning.EVENTS[turn][1] + "\n" + Preview.current_effect(draft_state,_choice)
	if planning and turn == 4 and not _training_profile().is_empty():
		var profile := _training_profile()
		var required := bool(profile.get("shelter_required", true))
		var cost := int(profile.get("protection_energy", 0))
		_event_title.text = "T4 %s · %s" % [_alert_label(profile), "Shelter required" if required else "Shelter optional"]
		captions.assign(["Shelter · %d power" % cost, "Continue without shelter"])
		_event_text.text = "A training alert based on NASA records. Sheltering uses %d extra power and pauses farming.\n%s" % [cost, "Build a shelter and choose Shelter to continue the mission." if required else "At Watch level, you can keep farming without sheltering."]
	if turn == 4 and _choice == "shelter" and Simulation.count_kind(draft_state, "shelter") == 0:
		_choice = ""
	_options.visible = not _event_values.is_empty()
	_event_row.visible = not _event_values.is_empty()
	for i in _event_buttons.size():
		var button := _event_buttons[i]
		button.visible = i < _event_values.size()
		if button.visible:
			button.text = captions[i]
			button.disabled = turn == 4 and i == 0 and Simulation.count_kind(draft_state, "shelter") == 0
			button.tooltip_text = UI.trn("Build a shelter first.", "Build a shelter first.") if button.disabled else ""
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
	_history_toggle.text = "Close history" if _history_open and has_record else "History · Rewind and compare"
	_history_body.visible = has_record and _history_open
	var candidates := History.candidates(_session)
	_candidate_note.text = "Saved states worth exploring, not guaranteed solutions. Inspect one before restoring." if not candidates.is_empty() else "No clear candidate found. Select a past turn below to inspect its starting state."
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
	_start_preview.text = "Restore target · Start of T%d\n%s" % [_timeline_turn,History.start_line(start)] if not start.is_empty() else "T%d is a read-only record from a previous attempt. There is no saved starting state to restore." % _timeline_turn
	if not start.is_empty(): _start_preview.text += "\nRestore replaces your draft layout with this saved starting state."
	_compare_title.text = "T%d / Compare attempts · Starting states and recorded results" % _timeline_turn
	_prior.text = History.side(_session,_timeline_turn,true)
	_current.text = History.side(_session,_timeline_turn,false)
	_delta.text = History.changes(_session,_timeline_turn)


func _result_line(result: Dictionary) -> String:
	var ending: Dictionary = result.state_after
	return UI.trn("T%d %s · P %d / O %d / F %d", "T%d %s · P %d / O %d / F %d") % [
		result.turn_id, UI.phase_text(result.phase), ending.E, ending.O, ending.F]


func _result_text(result: Dictionary) -> String:
	if result.is_empty():
		return ""
	var text := _result_line(result)
	var before: Dictionary = _session.snapshot(int(result.turn_id)) if _session != null else {}
	text += "\n" + Preview.flow_lines(before,result)
	match result.phase:
		"failed_power":
			text += UI.trn("\nStopped before oxygen, growth, supply, and food.", "\nStopped before oxygen, growth, supply, and food.")
		"failed_safety":
			text += UI.trn("\nBuild a shelter and take cover to continue.", "\nBuild a shelter and take cover to continue.")
	return text


func _select_slot(slot: int) -> void:
	open_context(slot)


## Select a site without performing an edit. Call refresh(session) before opening.
func open_context(slot_id: int = -1) -> void:
	clear_notice()
	_selected_slot = slot_id if slot_id >= 0 and slot_id < Rules.SLOT_COUNT else -1
	if _session != null:
		refresh(_session)
	if is_instance_valid(_scroll): _scroll.scroll_vertical = 0


func _place_selected() -> void:
	_show_site_required()


func _select_kind(_kind: String) -> void:
	_show_site_required()


func _show_site_required() -> void:
	if is_instance_valid(_notice):
		set_notice("Go to a pad and press 1 to build or remove.")

func _choose_event(index: int) -> void:
	if index < 0 or index >= _event_values.size() or _event_buttons[index].disabled: return
	clear_notice()
	_choice = _event_values[index]
	refresh(_session)


func _advance_turn() -> void:
	if _session == null or _locked or _advance.disabled or _session.state.phase != "planning":
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
	elif not _advance.disabled:
		_advance.grab_focus()
	else:
		_close.grab_focus()
