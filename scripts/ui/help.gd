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
var _source_cards: Dictionary = {}
var _communication_help: Label
var _weather_event_help: Label


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
	_card(parent,"대시보드와 안내 로봇","기지 남쪽 입구의 로봇 옆 단말기를 보고 E 또는 2를 눌러요. 대시보드에서는 자원·기지 지도·사건·과거 기록을 확인하고 턴을 진행해요. 설치·철거는 해당 위치에서만 할 수 있어요. 이동 중에는 턴이 흐르지 않아요. 로봇은 위치 표식이에요. 안내서는 대시보드 또는 일시 정지 화면에서 H로 열어요.")
	for kind: String in Learning.FACILITIES:
		_card(parent, UI.name_for(kind), Learning.FACILITIES[kind], UI.FACILITY_COLORS[kind])

func configure_controls(jump_enabled: bool, drag_available: bool) -> void:
	_controls.text = "WASD로 걷고 마우스로 둘러봐요. 가까운 빈 칸·건물의 테두리를 확인해요. 1은 설치·철거 메뉴, 2 또는 E는 상세 정보, 3은 3D 관찰이에요. 1을 눌러도 바로 철거되지 않아요. 중앙 단말기는 E 또는 2로 대시보드를 열어요. Esc로 닫거나 멈춰요."
	if jump_enabled:
		_controls.text += " Space로 점프해요. 바닥에 내려온 뒤 다시 누르면 또 점프할 수 있어요."
	if drag_available:
		_controls.text += " 마우스 잠금이 안 되면 게임 화면에서 왼쪽 버튼을 누른 채 드래그해요. 버튼을 놓으면 시점 회전이 멈춰요. 다시 잠그려면 Esc로 멈춘 뒤 재개해요."


func _build_events(parent: Control) -> void:
	UI.label(parent, "훈련용 가상 사건 · 턴과 자원은 게임 단위예요.", 18, UI.AMBER, true)
	_communication_help = _card(parent, "지구에 조언 요청하기", "요청을 확정할 때 전력 1을 써요. 확정 전에는 취소할 수 있어요. NASA CME 기록을 반영해 답장은 1~2턴 뒤 도착해요. T7 안에 답장을 받을 수 있을 때만 요청해요. 한 번에 한 요청만 보내요. 답장은 조언이며 자원을 주지 않아요. 대기 시간은 교육용 규칙이며 실제 달의 전파 지연이 아니에요.").get_child(1)
	for turn: int in Learning.EVENTS:
		var event: Array = Learning.EVENTS[turn]
		var event_card := _card(parent, event[0], event[1], UI.AMBER)
		if turn == 4: _weather_event_help = event_card.get_child(1)
	_card(parent, "같은 턴 두 번 해 보기",
		"완료한 턴의 시작으로 되감아요. 시설 배치나 대처 방법을 한 가지만 바꾸고 같은 턴을 실행해요. 남은 자원과 발전·수확을 비교해 보세요.")


func _build_sources(parent: Control) -> void:
	UI.label(parent, "우주 임무에 참고하는 실제 자료예요.", 18, UI.MUTED, true)
	var current := _card(parent, "이번 훈련의 우주날씨 참고 자료", "자료를 확인하고 있어요. 기다리지 않고 시작할 수 있어요.")
	_weather_title = current.get_child(0)
	_weather_text = current.get_child(1)
	_weather_source = UI.button(current, "FLR 대표 근거 원문", _open_weather_source, UI.CYAN, 36)
	_weather_source.disabled = true
	for kind: String in ["FLR", "SEP", "CME"]:
		var source_card := _card(parent, {"FLR":"FLR · 태양 플레어", "SEP":"SEP · 태양 고에너지 입자", "CME":"CME · 코로나 질량 방출"}[kind], "NASA 사건 기록을 확인하고 있어요.")
		var link := UI.button(source_card, "대표 기록 원문 ↗", _open_record_source.bind(kind), UI.CYAN, 36)
		link.disabled = true
		_source_cards[kind] = {"text":source_card.get_child(1), "link":link, "url":""}
	var archived := Learning.archived_flare()
	if not archived.is_empty():
		var record: Dictionary = archived.record
		var meta: Dictionary = archived.metadata
		var title := "학습용 보관 이력 · 2016년 태양 플레어 %s" % record.classType
		var description := "태양에서 아주 큰 에너지가 갑자기 나오는 현상을 태양 플레어라고 해요. 우주 임무를 계획할 때는 이런 기록도 살펴봐요."
		var donki := _card(parent, title, description)
		UI.label(donki, "시작 %s    최대 %s    종료 %s" % [
			Learning.utc_label(record.beginTime), Learning.utc_label(record.peakTime),
			Learning.utc_label(record.endTime)], 15, UI.MUTED, true)
		UI.label(donki, "NASA Goddard CCMC / DONKI · %s\n자료 조회 %s (한국 날짜) · 기록 개정판 %d" % [
			record.flrID, str(meta.retrieved_at).left(10), int(record.versionId)], 15, UI.MUTED, true)
		UI.label(donki, "학습용 이력 1건이에요. 이번 플레이 자료는 위의 대표 기록을 확인해요. 게임 4턴 경보는 가상 사건이며 NASA 기록을 교육용 조건 선택에 활용해요. 실제 피폭량 예측은 아니에요.",
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
	UI.label(parent, "시작 전 FLR·SEP·CME를 조회하고 실패한 종류는 내장 자료로 채워요. 한 판의 자료와 교육용 변환 규칙은 고정돼 되감아도 바뀌지 않아요. 최근 조회 성공은 오늘 발생했거나 지금 안전하다는 뜻이 아니에요.", 15, UI.MUTED, true)


func set_weather_context(data: Dictionary) -> void:
	_weather_context = data.duplicate(true)
	if not is_instance_valid(_weather_title): return
	var mode: String = {"live":"최근 API 조회", "archive":"내장 보관 자료", "mixed":"최근 조회·보관 자료 혼합"}.get(str(data.get("mode", "archive")), "내장 보관 자료")
	_weather_title.text = "이번 플레이 · NASA 사건 기록 · " + mode
	var observed := str(data.get("observed_at", ""))
	var fetched := str(data.get("fetched_at", ""))
	var profile: Dictionary = data.get("training_profile", {})
	_weather_text.text = "자료 시각 %s · 조회 %s\n실제 NASA 기록 → 게임 경보·비용·통신 조건. 아래 숫자는 교육용 변환이며 실제 피폭량·전파 지연 예측이 아니에요." % [observed if not observed.is_empty() else "종류별 대표 기록 참고", fetched if not fetched.is_empty() else "종류별 조회 기록 참고"]
	if not profile.is_empty():
		var level: String = {"watch":"관심", "warning":"경계", "severe":"심각"}.get(str(profile.get("alert_level", "")), "확인 중")
		var shelter := "대피 필수" if profile.get("shelter_required", true) else "대피 선택"
		_weather_text.text += "\n이번 게임 T4 %s · %s · 보호 전력 %d · 통신 %d턴" % [level, shelter, int(profile.get("protection_energy", 0)), int(profile.get("communication_delay", 1))]
		_weather_event_help.text = "이번 자료 → T4 %s · %s. 대피하면 보호 전력 %d를 더 쓰고 재배는 쉬어요. %s\nNASA 등급·입자 기록은 게임 조건을 고르는 근거예요. 실제 우주인의 피폭량을 계산하지 않아요." % [level, shelter, int(profile.get("protection_energy", 0)), "대피하지 않으면 훈련이 중단돼요." if profile.get("shelter_required", true) else "대피 없이 재배를 계속할 수 있어요."]
		_communication_help.text = "질문 확정 때 전력 1 사용 · %d턴 뒤 진행 후 답변. CME 기록을 반영한 교육용 대기 시간이에요. 실제 전파 지연 예측은 아니에요. T7 안에 답장을 받을 수 있을 때만 요청해요. 확정 전 취소 가능 · 한 번에 한 요청 · 자원 보너스 없음." % int(profile.get("communication_delay", 1))
	for kind: String in _source_cards: _refresh_source_card(kind, data, profile)
	_weather_source.disabled = _source_cards.FLR.link.disabled

func _refresh_source_card(kind: String, data: Dictionary, profile: Dictionary) -> void:
	var records: Array = data.get("records", {}).get(kind, [])
	if not data.has("records") and kind == "FLR" and not str(data.get("event_id", "")).is_empty(): records = [data]
	var source: Dictionary = data.get("sources", {}).get(kind, data if kind == "FLR" else {})
	var id_key: String = {"FLR":"flare_event_id", "SEP":"sep_event_id", "CME":"cme_event_id"}[kind]
	var representative: Dictionary = records[0] if not records.is_empty() else {}
	for record: Dictionary in records:
		if record.get("event_id", "") == profile.get(id_key, ""): representative = record
	var mode: String = {"live":"최근 조회", "archive":"보관 자료", "mixed":"혼합"}.get(str(source.get("mode", "archive")), "보관 자료")
	var status := "조회 상태 확인 필요"
	match str(source.get("status", "")):
		"recent", "ok", "success": status = "조회 완료"
		"loading": status = "조회 중"
		"archive", "frozen_archive", "offline", "": status = "보관 자료 사용"
		"no_recent_record", "empty": status = "조회 완료 · 기록 없음"
		_: status = "최근 조회 실패 · 보관 자료 사용" if source.get("mode", "archive") == "archive" else "조회 상태 확인 필요"
	var description := "%d건 · %s · %s" % [records.size(), mode, status]
	var request_url := str(source.get("request_url", ""))
	var dates: Array[String] = []
	for key in ["startDate=", "endDate="]:
		if request_url.contains(key): dates.append(request_url.split(key)[1].split("&")[0])
	if dates.size() == 2: description += "\n조회 범위 %s ~ %s" % dates
	description += "\n조회 시각 " + str(source.get("fetched_at", "확인 불가"))
	if representative.is_empty():
		description += "\n미관측 · 이 자료에 기록이 없어요. 실제 안전이 확정된 뜻은 아니에요."
	else:
		description += "\n대표 %s · %s\n%s" % [str(representative.get("class_type", kind)), str(representative.get("observed_at", "날짜 확인 불가")), str(representative.get("event_id", ""))]
		if kind == "SEP":
			var evidence: String = {"model":"모델 기록", "observation":"관측 포함 기록", "mixed":"관측·모델 포함 기록", "catalogue":"NASA 사건 목록 기록"}.get(str(representative.get("evidence_type", "")), "NASA 사건 기록")
			description += "\n" + evidence + " · 실제 달 피폭량 측정값이 아니에요."
	var card: Dictionary = _source_cards[kind]
	card.text.text = description
	card.url = str(representative.get("source_url", ""))
	card.link.disabled = not card.url.begins_with("https://ccmc.gsfc.nasa.gov/")

func _open_record_source(kind: String) -> void:
	var url := str(_source_cards[kind].url)
	if url.begins_with("https://ccmc.gsfc.nasa.gov/"): _open_source(url)


func _open_weather_source() -> void:
	_open_record_source("FLR")


func _open_source(url: String) -> void:
	OS.shell_open(url)
