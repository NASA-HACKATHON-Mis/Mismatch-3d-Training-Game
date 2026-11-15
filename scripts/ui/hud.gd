extends Control

signal inspection_closed
signal result_requested
signal started
signal help_requested
signal guidance_changed(enabled: bool)

const UI = preload("res://scripts/ui/ui_style.gd")
const Simulation = preload("res://scripts/simulation/simulation.gd")
const ResourceMeter = preload("res://scripts/ui/resource_meter.gd")
var _inspection: PanelContainer
var _inspection_label: Label
var _inspection_back: Button
var _mission: Label
var _meters: GridContainer
var _energy: ResourceMeter
var _oxygen: ResourceMeter
var _food: ResourceMeter
var _hint: Label
var _status_box: PanelContainer
var _intro: PanelContainer
var _reticle: Label
var _footnote: Label
var help_button: Button
var _start: Button
var _input_notice: Label
var _guide_toggle: Button
var _first_step: Label
var _heading: Label
var _header: PanelContainer
var _intro_scroll: ScrollContainer
var guidance_enabled := true
var has_started := false
var _ended := false
var _outcome_heading := ""
var _result_button: Button
var _training_copy: Array[Control] = []
var _controls: Label
var _jump_enabled := false
var _drag_available := false
var _look_mode := "disabled"
const Outcome = preload("res://scripts/ui/outcome_summary.gd")

func _ready() -> void:
	UI.use_korean_theme(self)
	_header = UI.panel(self, Color("#0b1728f5"), 14)
	var heading := UI.column(_header, 3)
	UI.label(heading, "달 표면 훈련 기지", 16, UI.CYAN)
	_mission = UI.label(heading, "달기지 리와인드", 26)
	_meters = GridContainer.new()
	_meters.columns = 3
	_meters.add_theme_constant_override("h_separation", 14)
	_meters.add_theme_constant_override("v_separation", 8)
	heading.add_child(_meters)
	_energy = ResourceMeter.new()
	_oxygen = ResourceMeter.new()
	_food = ResourceMeter.new()
	for meter in [_energy, _oxygen, _food]:
		_meters.add_child(meter)
	_energy.set_color(UI.AMBER)
	_oxygen.set_color(UI.CYAN)
	_food.set_color(UI.GREEN)
	_header.minimum_size_changed.connect(_layout)
	_reticle = UI.label(self, "+", 31, UI.CYAN)
	_reticle.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	_reticle.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_reticle.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_reticle.offset_left = -22
	_reticle.offset_top = -24
	_reticle.offset_right = 22
	_reticle.offset_bottom = 24
	_status_box = UI.panel(self, Color("#0b1728f5"), 12)
	_hint = UI.label(_status_box, "", 18, UI.TEXT, true)
	_hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_status_box.minimum_size_changed.connect(_layout)
	_footnote = UI.label(self, "교육용 가상 훈련 · 수치는 게임 단위", 16, UI.MUTED)
	_intro = UI.panel(self, Color("#0b182cf8"), 22)
	_intro_scroll = ScrollContainer.new()
	_intro_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	_intro_scroll.follow_focus = true
	_intro.add_child(_intro_scroll)
	var text := UI.column(_intro_scroll, 12)
	UI.grow(text)
	UI.label(text, "훈련 01 / 달 표면 기지", 16, UI.CYAN)
	_heading = UI.label(text, "달 기지를 지켜요", 32, UI.TEXT, true)
	_training_copy.append(UI.label(text, "시설을 짓고 7턴 동안 전력·산소·식량을 지켜요.", 20, UI.TEXT, true))
	_training_copy.append(UI.label(text, "키보드와 마우스가 있는 PC에서 시작해요.", 18, UI.AMBER, true))
	_controls = UI.label(text, "", 18, UI.MUTED, true)
	configure_controls(false, false)
	_first_step = UI.label(text, "1  단말기 가까이 가서 E를 눌러요.", 20, UI.CYAN, true)
	_guide_toggle = UI.button(text, "첫 안내 건너뛰기", _toggle_guidance, UI.MUTED)
	_input_notice = UI.label(text, "", 18, UI.AMBER, true)
	_input_notice.hide()
	_start = UI.button(text, "훈련 시작", func(): started.emit(), UI.CYAN, 46)
	_result_button = UI.button(text, "결과 다시 보기", func(): result_requested.emit(), UI.CYAN)
	_result_button.hide()
	help_button = UI.button(text, "안내서  H", func(): help_requested.emit(), UI.MUTED)
	_inspection = UI.panel(self,Color("#0b182cf8"),16)
	var observation := UI.column(_inspection,8)
	_inspection_label = UI.label(observation,"",18,UI.TEXT,true)
	_inspection_back = UI.button(observation,"단말기로 돌아가기 · Esc",func(): inspection_closed.emit(),UI.CYAN)
	_inspection.hide()
	resized.connect(_layout)
	_layout()

func _layout() -> void:
	if not is_instance_valid(_intro): return
	var narrow := size.x < 960
	_header.position = Vector2(20, 18)
	_meters.columns = 1 if size.x < 520 else 3
	_header.size = Vector2(minf(size.x - 40, 490), 0)
	var width := minf(560, size.x - 40) if narrow else minf(560, size.x * 0.47)
	var height := minf(440, size.y - 170) if narrow else minf(540, size.y - 174)
	# Keep the start/pause card below the actual resource header at short heights.
	height = minf(height, maxf(80, size.y - _header.get_combined_minimum_size().y - 72))
	_intro.position = Vector2((size.x - width) / 2 if narrow else 28, size.y - height - 38)
	_intro.size = Vector2(width, height)
	_status_box.size = Vector2(maxf(1, size.x - 40), maxf(108, _status_box.get_combined_minimum_size().y))
	_status_box.position = Vector2(20, size.y - _status_box.size.y - 42)
	_footnote.position = Vector2(20, size.y - 30)
	_inspection.position = Vector2(20,size.y-180)
	_inspection.size = Vector2(maxf(1,size.x-40),140)

func _toggle_guidance() -> void:
	set_guidance(not guidance_enabled)
	guidance_changed.emit(guidance_enabled)

func set_guidance(enabled: bool) -> void:
	guidance_enabled = enabled
	_first_step.visible = enabled and not _ended
	_guide_toggle.text = "첫 안내 건너뛰기" if enabled else "첫 안내 다시 보기"

func show_mode(mode: String) -> void:
	visible = mode != "terminal"
	_intro.visible = mode in ["pause", "capturing"]
	_inspection.visible = mode == "inspect"
	if mode == "inspect": _inspection_back.grab_focus()
	_start.disabled = mode == "capturing"
	help_button.disabled = mode == "capturing"
	_guide_toggle.disabled = mode == "capturing"
	_reticle.visible = mode == "explore"
	_status_box.visible = mode == "explore"
	if mode == "explore": has_started = true
	_heading.text = _outcome_heading if _ended else ("계속 기지를 살펴봐요" if has_started else "달 기지를 지켜요")
	for item in _training_copy: item.visible = not _ended
	_first_step.visible = guidance_enabled and not _ended
	_guide_toggle.visible = not _ended
	_result_button.visible = _ended
	_result_button.disabled = mode == "capturing"
	_start.text = "기지 둘러보기" if _ended else ("계속 탐색하기" if has_started else "훈련 시작")
	if mode == "pause": _start.grab_focus()

func set_input_notice(message: String) -> void:
	_input_notice.text = message
	_input_notice.visible = not message.is_empty()

func configure_controls(jump_enabled: bool, drag_available: bool) -> void:
	_jump_enabled = jump_enabled
	_drag_available = drag_available
	_controls.text = "WASD 이동" + (" · Space 점프" if _jump_enabled else "")
	_controls.text += " · 마우스로 둘러보기\n단말기를 보고 E · Esc 일시 정지"
	if _drag_available:
		_controls.text += "\n마우스 잠금이 안 되면 왼쪽 버튼 드래그로 둘러봐요."

func set_look_mode(value: String) -> void:
	_look_mode = value

func refresh(state: Dictionary) -> void:
	_ended = Outcome.ended(state)
	_outcome_heading = Outcome.heading(state) if _ended else ""
	_mission.text = "달기지 리와인드 / T%d" % state.turn_id
	_energy.set_values("전력", state.E, Simulation.energy_cap(state))
	_oxygen.set_values("산소", state.O, 100)
	_food.set_values("식량", state.F, 100)

func show_inspection(caption: String) -> void:
	_inspection_label.text = caption + "\n관찰 화면이에요. 이동하거나 턴을 진행하지 않아요."

func _direction(vector: Vector3) -> String:
	if absf(vector.x) > absf(vector.z): return "동쪽" if vector.x > 0 else "서쪽"
	return "남쪽" if vector.z > 0 else "북쪽"

func set_target(active: bool, position_3d: Vector3 = Vector3.ZERO, facing: Vector3 = Vector3.FORWARD, prompt: String = "") -> void:
	_reticle.modulate = UI.CYAN if active else UI.MUTED
	var target := preload("res://scripts/simulation/scenario.gd").CONSOLE - position_3d
	var angle := Vector2(facing.x,facing.z).angle_to(Vector2(target.x,target.z))
	var relative := "앞쪽" if absf(angle) < PI/4 else ("뒤쪽" if absf(angle) > 3*PI/4 else "오른쪽" if angle > 0 else "왼쪽")
	_hint.text = "[ E ] 단말기를 열어요" if active else "단말기 %s(%s) · 약 %dm. 시설 사이·바깥 통로를 따라 남쪽 입구 로봇 옆으로 돌아와 정면을 바라봐요." % [relative,_direction(target),roundi(Vector2(target.x,target.z).length())]
	if active and not prompt.is_empty(): _hint.text = prompt
	_hint.text += "\n이동 중에는 턴·자원이 바뀌지 않아요."
	if _look_mode == "drag":
		_hint.text = "마우스 잠금 대신 왼쪽 버튼 드래그로 둘러봐요.\n" + _hint.text
