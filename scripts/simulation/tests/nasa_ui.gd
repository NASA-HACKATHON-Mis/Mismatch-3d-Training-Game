extends SceneTree
const Terminal = preload("res://scripts/ui/terminal.gd")
const UI = preload("res://scripts/ui/ui_style.gd")
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
func english_tree(node: Node) -> bool:
	var pattern := RegEx.new()
	pattern.compile("[\\x{1100}-\\x{11ff}\\x{3130}-\\x{318f}\\x{ac00}-\\x{d7af}]")
	if node is Label or node is BaseButton:
		if pattern.search(node.text) != null: return false
	if node is Control and pattern.search(node.tooltip_text) != null: return false
	for child: Node in node.get_children():
		if not english_tree(child): return false
	return true
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
		check(ui._weather_label.text.contains("Mixed: fetched + historical"), "Mixed source label")
		check(ui._weather_label.text.contains("Shielding power 6") and ui._event_title.text.contains("High alert"), "Derived profile values displayed")
		check(ui._event_buttons[0].text.contains("6 power") and ui._event_text.text.contains("pauses farming"), "Protection cost and farm pause visible")
		check(ui._resource_overview._shield_detail.text.contains("Shelter required"), "Shield tag has current condition")
		check(ui._communication_label.text.contains("2 turns") and ui._communication_label.text.contains("CME"), "CME timing explanation")
		for action in [ui._advance,ui._advice_toggle,ui._event_buttons[0],ui._event_buttons[1]]:
			check(Rect2(Vector2.ZERO,Vector2(dimensions)).encloses(action.get_global_rect()) and not ui._scroll.is_ancestor_of(action), "Pinned action fits " + action.text)
		check(english_tree(ui), "Every dashboard label, button and tooltip is English")
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
		check(ui._event_title.text.contains("Shelter optional") and ui._event_text.text.contains("keep farming"), "Watch permits continuing farms")
		check(ui._event_buttons[0].text.contains("0 power"), "Watch protection cost from profile")
		ui.hide()
		var help := Guide.new()
		view.add_child(help)
		help.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		help.set_weather_context(data)
		help.open(2)
		await settle()
		check(help._source_cards.FLR.text.text.contains("peak-X") and not help._source_cards.FLR.text.text.contains("recent-M"), "Help shows representative strongest flare")
		check(help._source_cards.FLR.text.text.contains("2 records") and help._source_cards.FLR.text.text.contains("2024-05-08 to 2024-05-13"), "Count and query window shown")
		check(help._source_cards.SEP.text.text.contains("Includes observations and models"), "SEP evidence type explicit")
		check(help._source_cards.CME.text.text.contains("cme-example"), "CME causal record shown")
		check(not help._weather_source.disabled and help._source_cards.FLR.url.ends_with("/peak"), "Main source link uses profile representative")
		check(help._weather_event_help.text.contains("6 extra power") and help._communication_help.text.contains("2 turns"), "Help matches supplied profile")
		check(english_tree(help), "Every guide label, button and tooltip is English")
		check(UI.trn("fallback", "English") == "English", "Shared translation selects English")
		var honest := data.duplicate(true)
		honest.mode = "archive"
		honest.snapshot_frozen = true
		honest.sources.FLR.mode = "archive"
		honest.sources.FLR.status = "ready"
		help.set_weather_context(honest)
		ui.set_weather_context(honest)
		check(ui._weather_label.text.contains("Embedded historical data · not live") and help._weather_title.text.contains("Embedded historical data · not live"), "Historical banner explicitly rejects live status")
		check(help._source_cards.FLR.text.text.contains("Embedded historical data · not live") and not help._source_cards.FLR.text.text.contains("Fetch failed"), "Ready archive is identified without inventing a failed fetch")
		check(help._weather_text.text.contains("Session snapshot: frozen") and help._weather_text.text.contains("rewind"), "Frozen mission records are explained")
		honest.sources.FLR.status = "no_recent_record"
		help.set_weather_context(honest)
		check(help._source_cards.FLR.text.text.contains("Recent query empty · using historical data") and help._source_cards.FLR.text.text.contains("2 records"), "Empty recent query does not hide historical records")
		honest.mode = "live"
		honest.snapshot_frozen = false
		help.set_weather_context(honest)
		ui.set_weather_context(honest)
		check(ui._weather_label.text.contains("Fetched NASA records") and help._weather_title.text.contains("Fetched NASA records"), "Successful retrieval is fetched records, not a live monitor")
		check(ui._weather_label.text.contains("not a live feed") and help._weather_title.text.contains("not a live feed"), "Fetched banner explicitly rejects a live feed")
		honest.source_label = "Fetched NASA records - not a live feed"
		help.set_weather_context(honest)
		ui.set_weather_context(honest)
		check(help._weather_title.text.ends_with(honest.source_label) and ui._weather_label.text.contains(honest.source_label), "Service provenance label is preserved")
		check(help._weather_text.text.contains("Records freeze when you start"), "Pre-start snapshot is not already frozen")
		help.set_weather_context(data)
		await capture(view,"%dx%d-sources" % [dimensions.x,dimensions.y])
		data.records.SEP[0].evidence_type = "catalogue"
		help.set_weather_context(data)
		check(help._source_cards.SEP.text.text.contains("NASA event catalogue"), "Catalogue evidence is not called a model")
		data.records.SEP = []
		help.set_weather_context(data)
		check(help._source_cards.SEP.text.text.contains("No observation") and help._source_cards.SEP.text.text.contains("does not establish"), "No record is not real safety claim")
		check(help._source_cards.SEP.link.disabled, "Missing record cannot open source")
		view.queue_free()
		await settle()
	print("NASA UI: %d checks / %d failures" % [checks,failures])
	quit(1 if failures else 0)
