extends Control
## Read-only pocket map. No construction, turn or rewind signals exist here.
signal closed
signal inspect_requested(slot_id: int)
const UI = preload("res://scripts/ui/ui_style.gd")
const Rules = preload("res://scripts/simulation/scenario.gd")
const Simulation = preload("res://scripts/simulation/simulation.gd")
var _panel: PanelContainer
var _summary: Label
var _legend: Label
var _detail: Label
var _board: GridContainer
var _slots: Array[Button] = []
var _inspect: Button
var _close: Button
var _selected_slot := -1
var _state: Dictionary = {}
var _confirmed: Dictionary = {}
var _player_slot := -1

func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	UI.use_korean_theme(self)
	var shade := ColorRect.new()
	shade.color = Color(0.01,0.025,0.045,0.78)
	shade.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(shade)
	_panel = UI.panel(self, UI.DARK, 14)
	var column := UI.column(_panel, 6)
	var heading := UI.row(column, 10)
	UI.grow(UI.label(heading, "기지 지도", 28, UI.TEXT))
	_close = UI.button(heading, "돌아가기  Esc", func(): closed.emit(), UI.CYAN, 42)
	_summary = UI.label(column, "", 18, UI.CYAN, true)
	_legend = UI.label(column, "북쪽 ↑     ● 내 위치     + 설치 예정     − 철거 예정", 16, UI.MUTED, true)
	_board = GridContainer.new()
	_board.columns = 5
	_board.add_theme_constant_override("h_separation", 5)
	_board.add_theme_constant_override("v_separation", 4)
	_board.size_flags_vertical = Control.SIZE_EXPAND_FILL
	column.add_child(_board)
	for slot in Rules.SLOT_COUNT:
		var button := UI.button(_board, "", _select.bind(slot), UI.MUTED, 54)
		button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		button.size_flags_vertical = Control.SIZE_EXPAND_FILL
		button.add_theme_font_size_override("font_size", 17)
		_slots.append(button)
	_detail = UI.label(column, "", 18, UI.TEXT, true)
	var footer := UI.row(column, 12)
	UI.grow(UI.label(footer, "설치·철거는 현장에서 1", 16, UI.MUTED))
	_inspect = UI.button(footer, "선택 칸 3D 보기", _request_inspect, UI.CYAN, 40)
	_panel.minimum_size_changed.connect(_layout)
	resized.connect(_layout)
	_layout()
	hide()

func _layout() -> void:
	if not is_instance_valid(_panel): return
	var width := minf(840, size.x - 32)
	var height := minf(670, size.y - 32)
	_panel.position = Vector2((size.x-width)*0.5,(size.y-height)*0.5)
	_panel.size = Vector2(width,height)

func open_map(session, player_position: Vector3, selected_slot: int = -1) -> void:
	_selected_slot = selected_slot
	refresh(session, player_position)
	show()
	_close.grab_focus()

func refresh(session, player_position: Vector3) -> void:
	_state = session.preview().state.duplicate(true)
	_confirmed = session.state.duplicate(true)
	_player_slot = -1
	for slot in Rules.SLOT_COUNT:
		var center := Rules.slot_position(slot)
		if absf(player_position.x-center.x) <= 2.4 and absf(player_position.z-center.z) <= 2.4:
			_player_slot = slot
			break
	if _selected_slot < 0 or _selected_slot >= Rules.SLOT_COUNT:
		_selected_slot = _player_slot if _player_slot >= 0 else 12
	var occupied: int = _state.facilities.size()
	_summary.text = "시설 %d개 · 빈 부지 %d칸 · 남은 건설 토큰 %d" % [occupied, Rules.SLOT_COUNT-occupied, _state.budget]
	if not session.draft.is_empty(): _summary.text += " · 변경 예정 포함"
	_redraw()

func _redraw() -> void:
	for slot in Rules.SLOT_COUNT:
		var facility := Simulation.facility_at(_state, slot)
		var prior := Simulation.facility_at(_confirmed, slot)
		var prefix := "● " if slot == _player_slot else ""
		var name := "빈 부지" if facility.is_empty() else UI.name_for(facility.type)
		var pending := ""
		if prior.is_empty() and not facility.is_empty(): pending = "+ "
		elif not prior.is_empty() and facility.is_empty(): pending = "− "
		elif not prior.is_empty() and not facility.is_empty() and prior.instance_id != facility.instance_id: pending = "+ "
		_slots[slot].text = "%s%02d\n%s%s" % [prefix, slot+1, pending, name]
		var color: Color = UI.MUTED if facility.is_empty() else UI.FACILITY_COLORS.get(facility.type, UI.CYAN)
		UI.paint_button(_slots[slot], color, slot == _selected_slot)
		_slots[slot].tooltip_text = "%02d번 %s" % [slot+1, name]
	var selected := Simulation.facility_at(_state, _selected_slot)
	_detail.text = "%02d번 · %s" % [_selected_slot+1, "빈 부지" if selected.is_empty() else UI.name_for(selected.type)]
	if _selected_slot in Rules.SUNLIT: _detail.text += " · 햇빛이 잘 들어요"
	if _selected_slot in Rules.SHIELDED: _detail.text += " · 차폐 지형"
	if not selected.is_empty() and selected.type == "habitat": _detail.text += " · 고정 시설"

func _select(slot: int) -> void:
	if slot < 0 or slot >= Rules.SLOT_COUNT: return
	_selected_slot = slot
	_redraw()

func _request_inspect() -> void:
	if visible and _selected_slot >= 0: inspect_requested.emit(_selected_slot)
