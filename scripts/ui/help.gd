extends Control

signal closed
const UI = preload("res://scripts/ui/ui_style.gd")
const Learning = preload("res://resources/content/learning.gd")

var _scroll: ScrollContainer
var _pages: Array[VBoxContainer] = []
var _tabs: Array[Button] = []
var _controls: Label
var _weather_context: Dictionary = {}
var _weather_title: Label
var _weather_text: Label
var _weather_source: Button


func _ready() -> void:
	UI.use_korean_theme(self)
	var shade := ColorRect.new()
	shade.color = Color("#06101df2")
	shade.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(shade)

	var frame := MarginContainer.new()
	frame.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	frame.add_theme_constant_override("margin_left", 34)
	frame.add_theme_constant_override("margin_right", 34)
	frame.add_theme_constant_override("margin_top", 24)
	frame.add_theme_constant_override("margin_bottom", 24)
	add_child(frame)
	var panel := UI.panel(frame, UI.DARK, 20)
	var body := UI.column(panel, 12)
	var header := UI.row(body, 14)
	var title := UI.label(header, "달 기지 안내서", 29)
	UI.grow(title)
	var close := UI.button(header, "닫기  Esc", func(): closed.emit(), UI.MUTED)
	close.custom_minimum_size.x = 110

	var nav := UI.row(body, 8)
	var tabs := ["시설", "사건과 되감기", "실제 자료"]
	for index in tabs.size():
		var tab := UI.button(nav, tabs[index], _select_page.bind(index), UI.CYAN)
		UI.grow(tab)
		_tabs.append(tab)

	_scroll = ScrollContainer.new()
	_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	_scroll.follow_focus = true
	_scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	body.add_child(_scroll)
	var pages := UI.column(_scroll, 10)
	UI.grow(pages)
	for index in tabs.size():
		_pages.append(UI.column(pages, 10))
	_build_facilities(_pages[0])
	_build_events(_pages[1])
	_build_sources(_pages[2])
	_select_page(0)
	UI.label(body, "Tab으로 항목 이동 · Enter로 선택 · Esc로 닫기", 14, UI.MUTED)


func open(page: int) -> void:
	show()
	_select_page(clampi(page, 0, _pages.size() - 1))
	_tabs[clampi(page, 0, _tabs.size() - 1)].grab_focus()


func _select_page(index: int) -> void:
	for i in _pages.size():
		_pages[i].visible = i == index
		UI.paint_button(_tabs[i], UI.CYAN, i == index)
	_scroll.scroll_vertical = 0


func _card(parent: Control, title: String, description: String, color: Color = UI.CYAN) -> VBoxContainer:
	var card := UI.column(UI.panel(parent, UI.CARD, 14), 5)
	UI.label(card, title, 20, color, true)
	UI.label(card, description, 18, UI.TEXT, true)
	return card


func _build_facilities(parent: Control) -> void:
	UI.label(parent, "무엇을 지으면 도움이 될까요? 자원과 시간은 게임 단위예요.", 19, UI.MUTED, true)
	var controls := _card(parent, "이동과 시점 조작", "")
	_controls = controls.get_child(1) as Label
	configure_controls(false, false)
	_card(parent,"단말기로 돌아가기와 안내 로봇","단말기는 기지 남쪽 입구의 로봇 옆에 있어요. 시설 사이와 바깥 통로를 따라 돌아와 단말기를 정면으로 보고 E를 눌러요. 이동 중에는 턴이 흐르지 않아요. 로봇은 위치를 알아보는 표식이며 별도 대화·퀘스트는 제공하지 않아요. 안내서는 단말기 또는 일시 정지 화면에서 H로 열어요.")
	for kind: String in Learning.FACILITIES:
		_card(parent, UI.name_for(kind), Learning.FACILITIES[kind], UI.FACILITY_COLORS[kind])

func configure_controls(jump_enabled: bool, drag_available: bool) -> void:
	_controls.text = "WASD로 걷고 마우스로 둘러봐요. 가까운 빈 칸을 내려다보거나 건물·단말기를 보고 E로 열어요. E는 선택만 하고, ‘여기에 짓기’로 건설해요. Esc로 멈춰요."
	if jump_enabled:
		_controls.text += " Space로 점프해요. 바닥에 내려온 뒤 다시 누르면 또 점프할 수 있어요."
	if drag_available:
		_controls.text += " 마우스 잠금이 안 되면 게임 화면에서 왼쪽 버튼을 누른 채 드래그해요. 버튼을 놓으면 시점 회전이 멈춰요. 다시 잠그려면 Esc로 멈춘 뒤 재개해요."


func _build_events(parent: Control) -> void:
	UI.label(parent, "훈련용 가상 사건 · 턴과 자원은 게임 단위예요.", 18, UI.AMBER, true)
	_card(parent, "지구에 조언 요청하기", "요청은 이번 턴을 확정할 때 전력 1을 써요. 확정 전에는 취소할 수 있어요. 답장은 다음 턴을 마칠 때 도착해요. 한 번에 한 요청만 보낼 수 있고 마지막 턴에는 새 요청을 보내지 않아요. 답장은 조언이며 자원을 주지는 않아요. 한 턴 대기는 게임의 상담 처리 시간이며 실제 달의 전파 지연이 아니에요.")
	for turn: int in Learning.EVENTS:
		var event: Array = Learning.EVENTS[turn]
		_card(parent, event[0], event[1], UI.AMBER)
	_card(parent, "같은 턴 두 번 해 보기",
		"완료한 턴의 시작으로 되감아요. 시설 배치나 대처 방법을 한 가지만 바꾸고 같은 턴을 실행해요. 남은 자원과 발전·수확을 비교해 보세요.")


func _build_sources(parent: Control) -> void:
	UI.label(parent, "우주 임무에 참고하는 실제 자료예요.", 18, UI.MUTED, true)
	var current := _card(parent, "이번 훈련의 우주날씨 참고 자료", "자료를 확인하고 있어요. 기다리지 않고 시작할 수 있어요.")
	_weather_title = current.get_child(0)
	_weather_text = current.get_child(1)
	_weather_source = UI.button(current, "이번 사례 원문", _open_weather_source, UI.CYAN, 36)
	_weather_source.disabled = true
	var archived := Learning.archived_flare()
	if not archived.is_empty():
		var record: Dictionary = archived.record
		var meta: Dictionary = archived.metadata
		var title := "과거 관측 · 태양 플레어 %s" % record.classType
		var description := "태양에서 아주 큰 에너지가 갑자기 나오는 현상을 태양 플레어라고 해요. 우주 임무를 계획할 때는 이런 기록도 살펴봐요."
		var donki := _card(parent, title, description)
		UI.label(donki, "시작 %s    최대 %s    종료 %s" % [
			Learning.utc_label(record.beginTime), Learning.utc_label(record.peakTime),
			Learning.utc_label(record.endTime)], 15, UI.MUTED, true)
		UI.label(donki, "NASA Goddard CCMC / DONKI · %s\n자료 조회 %s (한국 날짜) · 기록 개정판 %d" % [
			record.flrID, str(meta.retrieved_at).left(10), int(record.versionId)], 15, UI.MUTED, true)
		UI.label(donki, "보관된 관측 1건이에요. 게임 4턴 경보는 가상 사건이며, 게임 자원과 위험 수치는 이 기록에서 계산하지 않아요.",
			15, UI.AMBER, true)
		var links := UI.row(donki, 8)
		UI.button(links, "NASA 사건 원문 ↗", _open_source.bind(str(meta.event_link)), UI.CYAN, 36)
		UI.button(links, "처음 조회한 API 주소 ↗", _open_source.bind(str(meta.request_url)), UI.CYAN, 36)
	else:
		_card(parent, "과거 관측 · NASA DONKI", "보관한 기록을 불러오지 못했어요.")
	var csa := _card(parent, "과학 읽기 · 멀리 갈수록 식량을 준비해요",
		"지구에서 멀어질수록 새 식량을 자주 받기 어려워요. 가져온 식량을 아끼고 직접 기를 방법을 준비해요. 우주 식량은 영양과 함께 무게, 부피, 보관 기간도 중요해요.", UI.GREEN)
	UI.label(csa, "출처 Canadian Space Agency · 게임 제작팀의 한국어 요약 · CSA 공식 번역 아님",
		15, UI.MUTED, true)
	UI.button(csa, "캐나다 우주국 원문 ↗", _open_source.bind(Learning.CSA_ARTICLE), UI.GREEN, 36)
	UI.label(parent, "시작 전 최근 DONKI 자료를 한 번 조회해요. 실패하거나 조회 중 시작하면 내장 자료를 사용해요. 한 판의 자료는 고정돼 되감아도 바뀌지 않아요. 아래 보관 기록과 요약은 오프라인에서도 읽을 수 있어요.", 15, UI.MUTED, true)


func set_weather_context(data: Dictionary) -> void:
	_weather_context = data.duplicate(true)
	if not is_instance_valid(_weather_title): return
	var mode := "최근 API 조회" if str(data.get("mode", "archive")) == "live" else "내장 과거 자료"
	_weather_title.text = "%s · %s %s" % [mode, str(data.get("record_type", "FLR")), str(data.get("class_type", ""))]
	_weather_text.text = "관측 %s\n조회 %s\n%s\n%s\n실제 사례를 경보 이해에 참고해요. T4와 게임 피해 수치는 교육용 고정 규칙이며 이 등급에서 계산하지 않아요." % [str(data.get("observed_at", "확인 불가")), str(data.get("fetched_at", "확인 불가")), str(data.get("explanation", "")), str(data.get("status", ""))]
	_weather_source.disabled = not str(data.get("source_url", "")).begins_with("https://ccmc.gsfc.nasa.gov/")


func _open_weather_source() -> void:
	var url := str(_weather_context.get("source_url", ""))
	if url.begins_with("https://ccmc.gsfc.nasa.gov/"): _open_source(url)


func _open_source(url: String) -> void:
	OS.shell_open(url)
