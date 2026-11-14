extends Control

const UI = preload("res://scripts/ui/ui_style.gd")
const Simulation = preload("res://scripts/simulation/simulation.gd")
var _mission: Label
var _meters: Label
var _hint: Label
var _status_box: PanelContainer
var _intro: CenterContainer
var _reticle: Label
var _footnote: Label


func _ready() -> void:
	var header := UI.panel(self, Color("#0b1728e8"), 14)
	header.position = Vector2(24, 22)
	var heading := UI.column(header, 1)
	UI.label(heading, "SELENE   /   TRAINING STATION 01", 13, UI.CYAN)
	_mission = UI.label(heading, UI.trn("달기지 리와인드", "Lunar Base Rewind"), 27)
	_meters = UI.label(heading, "", 17, UI.MUTED)

	_reticle = UI.label(self, "+", 31, UI.CYAN)
	_reticle.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	_reticle.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_reticle.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_reticle.offset_left = -22
	_reticle.offset_top = -24
	_reticle.offset_right = 22
	_reticle.offset_bottom = 24

	_status_box = UI.panel(self, Color("#0b1728ef"), 12)
	_status_box.anchor_left = 0.5
	_status_box.anchor_right = 0.5
	_status_box.anchor_top = 1.0
	_status_box.anchor_bottom = 1.0
	_status_box.offset_left = -280
	_status_box.offset_right = 280
	_status_box.offset_top = -80
	_status_box.offset_bottom = -28
	_hint = UI.label(_status_box, "", 18)
	_hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_footnote = UI.label(self, UI.trn("교육용 가상 훈련 · 수치는 게임 단위", "Fictional training  /  values are game units"), 13, UI.MUTED)
	_footnote.anchor_top = 1.0
	_footnote.anchor_bottom = 1.0
	_footnote.offset_left = 25
	_footnote.offset_top = -31

	_intro = CenterContainer.new()
	_intro.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_intro.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_intro)
	var splash := UI.panel(_intro, Color("#0b182ced"), 22)
	splash.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var text := UI.column(splash, 11)
	text.mouse_filter = Control.MOUSE_FILTER_IGNORE
	UI.label(text, UI.trn("훈련 01   /   달 표면 기지", "EXERCISE 01   /   LUNAR SURFACE"), 14, UI.CYAN)
	UI.label(text, UI.trn("달 기지를 지켜요", "Keep the Moon base running"), 38)
	UI.label(text, UI.trn("시설을 짓고 7턴 동안 전력·산소·식량을 지켜요.",
		"Build modules and keep power, oxygen, and food for 7 turns."), 20, UI.MUTED)
	UI.label(text, UI.trn("실패해도 되감아 다른 선택을 시험할 수 있어요.",
		"You can rewind a turn and try a different plan."), 17, UI.MUTED)
	UI.label(text, UI.trn("화면 클릭으로 시작 · 앞 단말기를 보고 E", "Click to start  /  Look at the console and press E"), 18, UI.CYAN)
	UI.label(text, "W A S D   /   " + UI.trn("이동     마우스 / 둘러보기", "WALK     MOUSE / LOOK"), 14, UI.MUTED)


func show_mode(mode: String) -> void:
	visible = mode != "terminal"
	_intro.visible = mode == "pause"
	_reticle.visible = mode == "explore"
	_status_box.visible = mode == "explore"


func refresh(state: Dictionary) -> void:
	_mission.text = UI.trn("달기지 리와인드", "Lunar Base Rewind") + "  /  T%d" % state.turn_id
	_meters.text = UI.trn("전력 %d/%d   ·   산소 %d   ·   식량 %d", "POWER %d/%d   ·   OXYGEN %d   ·   FOOD %d") % [
		state.E, Simulation.energy_cap(state), state.O, state.F]


func set_target(active: bool) -> void:
	_reticle.modulate = UI.CYAN if active else Color("#a5b6cdaa")
	_hint.text = UI.trn("[ E ]  임무 단말기 열기", "[ E ]  Open mission console") if active else UI.trn(
		"WASD 이동   ·   단말기를 조준하고 E   ·   Esc 일시 정지", "WASD walk   ·   Aim at the console + E   ·   Esc pause")
