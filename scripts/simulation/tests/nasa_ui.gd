extends SceneTree
const Terminal = preload("res://scripts/ui/terminal.gd")
const Guide = preload("res://scripts/ui/help.gd")
const Session = preload("res://scripts/simulation/snapshot_store.gd")
const Scenario = preload("res://resources/scenarios/lunar_training.tres")
var checks := 0
var failures := 0

func _initialize() -> void: call_deferred("_run")
func check(ok: bool, label: String) -> void:
	checks += 1
	if not ok:
		failures += 1
		push_error(label)
func settle() -> void:
	for i in 8: await process_frame
func capture(view: SubViewport, name: String) -> void:
	if "--render" not in OS.get_cmdline_user_args(): return
	await RenderingServer.frame_post_draw
	view.get_texture().get_image().save_png("res://logs/nasa-ui/" + name + ".png")
func context() -> Dictionary:
	return {"mode":"mixed", "class_type":"M1.1", "observed_at":"2024-05-13T10:00Z", "records":{
		"FLR":[{"event_id":"recent-M", "observed_at":"2024-05-13T10:00Z", "class_type":"M1.1", "source_url":"https://ccmc.gsfc.nasa.gov/donki/view/FLR/recent"}, {"event_id":"peak-X", "observed_at":"2024-05-10T10:00Z", "class_type":"X3.9", "source_url":"https://ccmc.gsfc.nasa.gov/donki/view/FLR/peak"}],
		"SEP":[{"event_id":"sep-observed", "observed_at":"2024-05-11T10:00Z", "evidence_type":"mixed", "source_url":"https://ccmc.gsfc.nasa.gov/donki/view/SEP/example"}],
		"CME":[{"event_id":"cme-example", "observed_at":"2024-05-12T10:00Z", "source_url":"https://ccmc.gsfc.nasa.gov/donki/view/CME/example"}]},
		"sources":{"FLR":{"mode":"live", "status":"recent", "fetched_at":"2026-11-15T10:00Z", "request_url":"https://api.nasa.gov/DONKI/FLR?startDate=2024-05-08&endDate=2024-05-13"}, "SEP":{"mode":"archive", "status":"frozen_archive", "fetched_at":"2026-11-15T10:00Z"}, "CME":{"mode":"archive", "status":"frozen_archive", "fetched_at":"2026-11-15T10:00Z"}}}
func profile() -> Dictionary:
	return {"mapping_version":"donki-training-v1", "alert_level":"severe", "shelter_required":true, "protection_energy":6, "communication_delay":2, "flare_class":"X3.9", "flare_event_id":"peak-X", "sep_event_id":"sep-observed", "cme_event_id":"cme-example"}
func _run() -> void:
	DirAccess.make_dir_recursive_absolute("res://logs/nasa-ui")
	for dimensions in [Vector2i(960,600),Vector2i(1280,800)]:
		var view := SubViewport.new()
		view.size = dimensions
		view.render_target_update_mode = SubViewport.UPDATE_ALWAYS
		root.add_child(view)
		var ui := Terminal.new()
		view.add_child(ui)
		ui.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		var session := Session.new(Scenario)
		session.state.weather = profile()
		session.state.turn_id = 4
		session.current_history.snapshots["4"] = session.state.duplicate(true)
		ui.refresh(session)
		var data := context()
		data.training_profile = profile()
		ui.set_weather_context(data)
		ui.set_communication_state({},false)
		await settle()
		check(ui._weather_label.text.contains("X3.9") and ui._weather_label.text.contains("2024-05-10"), "Header uses profile cause, not latest flare")
		check(ui._weather_label.text.contains("혼합"), "Mixed source label")
		check(ui._weather_label.text.contains("보호 전력 6") and ui._event_title.text.contains("심각"), "Derived profile values displayed")
		check(ui._event_buttons[0].text.contains("전력 6") and ui._event_text.text.contains("재배는 쉬어요"), "Protection cost and farm pause visible")
		check(ui._resource_overview._shield_detail.text.contains("대피 필수"), "Shield tag has current condition")
		check(ui._communication_label.text.contains("2턴") and ui._communication_label.text.contains("CME"), "CME timing explanation")
		for action in [ui._advance,ui._advice_toggle,ui._event_buttons[0],ui._event_buttons[1]]:
			check(Rect2(Vector2.ZERO,Vector2(dimensions)).encloses(action.get_global_rect()) and not ui._scroll.is_ancestor_of(action), "Pinned action fits " + action.text)
		await capture(view,"%dx%d-severe" % [dimensions.x,dimensions.y])
		session.state.turn_id = 6
		session.current_history.snapshots["6"] = session.state.duplicate(true)
		ui.refresh(session)
		check(ui._advice_toggle.disabled and ui._communication_label.text.contains("T7"), "Delay two blocks T6 request")
		session.state.weather.communication_delay = 1
		ui.refresh(session)
		check(not ui._advice_toggle.disabled, "Delay one permits T6 request")
		session.state.turn_id = 4
		session.state.weather.alert_level = "watch"
		session.state.weather.shelter_required = false
		session.state.weather.protection_energy = 0
		ui.refresh(session)
		check(ui._event_title.text.contains("대피 선택") and ui._event_text.text.contains("재배를 계속"), "Watch permits continuing farms")
		check(ui._event_buttons[0].text.contains("전력 0"), "Watch protection cost from profile")
		ui.hide()
		var help := Guide.new()
		view.add_child(help)
		help.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		help.set_weather_context(data)
		help.open(2)
		await settle()
		check(help._source_cards.FLR.text.text.contains("peak-X") and not help._source_cards.FLR.text.text.contains("recent-M"), "Help shows representative strongest flare")
		check(help._source_cards.FLR.text.text.contains("2건") and help._source_cards.FLR.text.text.contains("2024-05-08 ~ 2024-05-13"), "Count and query window shown")
		check(help._source_cards.SEP.text.text.contains("관측·모델 포함"), "SEP evidence type explicit")
		check(help._source_cards.CME.text.text.contains("cme-example"), "CME causal record shown")
		check(not help._weather_source.disabled and help._source_cards.FLR.url.ends_with("/peak"), "Main source link uses profile representative")
		check(help._weather_event_help.text.contains("보호 전력 6") and help._communication_help.text.contains("2턴"), "Help matches supplied profile")
		await capture(view,"%dx%d-sources" % [dimensions.x,dimensions.y])
		data.records.SEP[0].evidence_type = "catalogue"
		help.set_weather_context(data)
		check(help._source_cards.SEP.text.text.contains("사건 목록 기록"), "Catalogue evidence is not called a model")
		data.records.SEP = []
		help.set_weather_context(data)
		check(help._source_cards.SEP.text.text.contains("미관측") and help._source_cards.SEP.text.text.contains("확정된 뜻은 아니"), "No record is not real safety claim")
		check(help._source_cards.SEP.link.disabled, "Missing record cannot open source")
		view.queue_free()
		await settle()
	print("NASA UI: %d checks / %d failures" % [checks,failures])
	quit(1 if failures else 0)
