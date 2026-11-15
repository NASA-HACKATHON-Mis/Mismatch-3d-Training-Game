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
	var title := UI.label(header, "Moon base guide", 29)
	UI.grow(title)
	var close := UI.button(header, "Close  Esc", func(): closed.emit(), UI.MUTED)
	close.custom_minimum_size.x = 110

	var nav := UI.row(body, 8)
	var tabs := ["Facilities", "Events and rewind", "Real data"]
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
	UI.label(body, "Tab to move · Enter to select · Esc to close", 14, UI.MUTED)


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
	UI.label(parent, "What could help your base? Resources and time use game units.", 19, UI.MUTED, true)
	var controls := _card(parent, "Move and look", "")
	_controls = controls.get_child(1) as Label
	configure_controls(false, false)
	_card(parent,"Dashboard and guide robot","At the south entrance, face the terminal beside the guide robot and press E or 2. Check resources, the map, events and history, then run a turn. Build or remove only at a pad. Walking does not advance time. Press H from the dashboard or pause menu for this guide.")
	for kind: String in Learning.FACILITIES:
		_card(parent, UI.name_for(kind), Learning.FACILITIES[kind], UI.FACILITY_COLORS[kind])

func configure_controls(jump_enabled: bool, drag_available: bool) -> void:
	_controls.text = "Move with WASD and look with the mouse. At a pad: 1 build/remove, 2 or E details, 3 inspect in 3D. Press 4 anywhere for the read-only base map. Face the terminal and press E or 2 for the dashboard. Esc closes a menu; during exploration it pauses."
	if jump_enabled:
		_controls.text += " Press Space to jump. Land before jumping again."
	if drag_available:
		_controls.text += " If mouse capture is unavailable, hold the left mouse button and drag to look. Release to stop. Pause with Esc, then resume to capture again."


func _build_events(parent: Control) -> void:
	UI.label(parent, "Training scenario · Turns and resources use game units.", 18, UI.AMBER, true)
	_communication_help = _card(parent, "Ask Earth for advice", "A confirmed request costs 1 power. Cancel before confirming. NASA CME records set a 1–2 turn reply delay. Request only if the reply can arrive by T7. One request at a time. Advice gives no resources. This is a training delay, not real lunar signal travel time.").get_child(1)
	for turn: int in Learning.EVENTS:
		var event: Array = Learning.EVENTS[turn]
		var event_card := _card(parent, event[0], event[1], UI.AMBER)
		if turn == 4: _weather_event_help = event_card.get_child(1)
	_card(parent, "Try the same turn twice",
		"Rewind to the start of a completed turn. Change one part of your layout or response, then run the same turn. Compare remaining resources, power generated and food harvested.")


func _build_sources(parent: Control) -> void:
	UI.label(parent, "Real records used to learn about space missions.", 18, UI.MUTED, true)
	var current := _card(parent, "Space weather records for this mission", "Checking records. You may start with historical data without waiting.")
	_weather_title = current.get_child(0)
	_weather_text = current.get_child(1)
	_weather_source = UI.button(current, "FLR source record", _open_weather_source, UI.CYAN, 36)
	_weather_source.disabled = true
	for kind: String in ["FLR", "SEP", "CME"]:
		var source_card := _card(parent, {"FLR":"FLR · Solar flares", "SEP":"SEP · Solar energetic particles", "CME":"CME · Coronal mass ejections"}[kind], "Checking NASA event records.")
		var link := UI.button(source_card, "Example source record ↗", _open_record_source.bind(kind), UI.CYAN, 36)
		link.disabled = true
		_source_cards[kind] = {"text":source_card.get_child(1), "link":link, "url":""}
	var archived := Learning.archived_flare()
	if not archived.is_empty():
		var record: Dictionary = archived.record
		var meta: Dictionary = archived.metadata
		var title := "Learning archive · 2016 solar flare %s" % record.classType
		var description := "A solar flare is a sudden release of energy from the Sun. Space mission planners study these records."
		var donki := _card(parent, title, description)
		UI.label(donki, "Start %s    Peak %s    End %s" % [
			Learning.utc_label(record.beginTime), Learning.utc_label(record.peakTime),
			Learning.utc_label(record.endTime)], 15, UI.MUTED, true)
		UI.label(donki, "NASA Goddard CCMC / DONKI · %s\nRetrieved %s (as recorded) · Archive revision %d" % [
			record.flrID, str(meta.retrieved_at).left(10), int(record.versionId)], 15, UI.MUTED, true)
		UI.label(donki, "One historical learning example. See the records above for this mission's inputs. T4 is a training scenario informed by NASA records, not a real radiation forecast.",
			15, UI.AMBER, true)
		var links := UI.row(donki, 8)
		UI.button(links, "NASA source record ↗", _open_source.bind(str(meta.event_link)), UI.CYAN, 36)
		UI.button(links, "Original API request ↗", _open_source.bind(str(meta.request_url)), UI.CYAN, 36)
	else:
		_card(parent, "Historical observation · NASA DONKI", "Could not load the archived record.")
	var csa := _card(parent, "Science reading · Food for long journeys",
		"Far from Earth, fresh deliveries are harder to get. Save your food and prepare to grow more. Space food must balance nutrition, weight, volume and storage life.", UI.GREEN)
	UI.label(csa, "Source: Canadian Space Agency · Summary by the game team, not an official CSA publication",
		15, UI.MUTED, true)
	UI.button(csa, "Canadian Space Agency article ↗", _open_source.bind(Learning.CSA_ARTICLE), UI.GREEN, 36)
	UI.label(parent, "Before play, request FLR, SEP and CME records once. Failed products use embedded historical data. Records and training rules freeze when the mission starts, including rewind. Fetched records are not a live feed or proof of today's safety.", 15, UI.MUTED, true)


func set_weather_context(data: Dictionary) -> void:
	_weather_context = data.duplicate(true)
	if not is_instance_valid(_weather_title): return
	var mode: String = {"live":"Fetched NASA records", "archive":"Embedded historical data · not live", "mixed":"Mixed: fetched + historical"}.get(str(data.get("mode", "archive")), "Embedded historical data · not live")
	_weather_title.text = "Mission records · NASA DONKI · " + mode
	var observed := str(data.get("observed_at", ""))
	var fetched := str(data.get("fetched_at", ""))
	var profile: Dictionary = data.get("training_profile", {})
	_weather_text.text = "Observation %s · Retrieved %s\nReal NASA records select training alerts, costs and reply delays. Values below are game rules, not radiation or signal-delay predictions." % [observed if not observed.is_empty() else "See each product's example record", fetched if not fetched.is_empty() else "See each product's retrieval record"]
	_weather_text.text += "\nSession snapshot: frozen for play and rewind." if data.get("snapshot_frozen", false) else "\nRecords freeze when you start; rewinding keeps the same records."
	if not profile.is_empty():
		var level: String = {"watch":"Watch", "warning":"Warning", "severe":"High alert"}.get(str(profile.get("alert_level", "")), "Checking")
		var shelter := "Shelter required" if profile.get("shelter_required", true) else "Shelter optional"
		_weather_text.text += "\nThis mission: T4 %s · %s · Shielding power %d · Reply delay %d turns" % [level, shelter, int(profile.get("protection_energy", 0)), int(profile.get("communication_delay", 1))]
		_weather_event_help.text = "These records → T4 %s · %s. Sheltering uses %d extra power and pauses farming. %s\nNASA classes and particle records select game conditions, not an astronaut's radiation dose." % [level, shelter, int(profile.get("protection_energy", 0)), "Without sheltering, the mission stops." if profile.get("shelter_required", true) else "You may keep farming without sheltering."]
		_communication_help.text = "A confirmed request costs 1 power · Reply after %d turns. CME records set this training delay, not a real signal-delay prediction. Reply must arrive by T7. Cancel before confirming · One request at a time · No resource bonus." % int(profile.get("communication_delay", 1))
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
	var mode: String = {"live":"Fetched NASA records", "archive":"Embedded historical data · not live", "mixed":"Mixed: fetched + historical"}.get(str(source.get("mode", "archive")), "Historical data")
	var status := "Check retrieval status"
	match str(source.get("status", "")):
		"recent", "ok", "success": status = "Fetched NASA records"
		"loading": status = "Fetching records"
		"archive", "frozen_archive", "offline", "ready", "": status = "Using historical data"
		"no_recent_record", "empty": status = "Fetched NASA records · No records"
		_: status = "Fetch failed · Embedded historical data · not live" if source.get("mode", "archive") == "archive" else "Check retrieval status"
	var description := "%d records · %s\n%s" % [records.size(), mode, status]
	var request_url := str(source.get("request_url", ""))
	var dates: Array[String] = []
	for key in ["startDate=", "endDate="]:
		if request_url.contains(key): dates.append(request_url.split(key)[1].split("&")[0])
	if dates.size() == 2: description += "\nRecord window %s to %s" % dates
	description += "\nRetrieved " + str(source.get("fetched_at", "Unknown"))
	if representative.is_empty():
		description += "\nNo observation in these records. This does not establish real-world safety."
	else:
		description += "\nExample %s · %s\n%s" % [str(representative.get("class_type", kind)), str(representative.get("observed_at", "Date unavailable")), str(representative.get("event_id", ""))]
		if kind == "SEP":
			var evidence: String = {"model":"Model records", "observation":"Includes observations", "mixed":"Includes observations and models", "catalogue":"NASA event catalogue"}.get(str(representative.get("evidence_type", "")), "NASA event records")
			description += "\n" + evidence + " · Not a measured lunar radiation dose."
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
