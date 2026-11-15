extends SceneTree
const Terminal = preload("res://scripts/ui/terminal.gd")
const Guide = preload("res://scripts/ui/help.gd")
const Session = preload("res://scripts/simulation/snapshot_store.gd")
const Scenario = preload("res://resources/scenarios/lunar_training.tres")
var checks := 0
var failures := 0
var edits := 0
var cancels := 0
var inspections := 0
var advances: Array[String] = []
var rewinds: Array[int] = []
var advice: Array[bool] = []

func _initialize() -> void: call_deferred("_run")
func check(ok: bool, message: String) -> void:
	checks += 1
	if not ok:
		failures += 1
		push_error(message)
func settle() -> void:
	for i in 10: await process_frame
func capture(view: SubViewport, name: String) -> void:
	if "--render" not in OS.get_cmdline_user_args(): return
	await RenderingServer.frame_post_draw
	view.get_texture().get_image().save_png("res://logs/dashboard/" + name + ".png")

func _run() -> void:
	DirAccess.make_dir_recursive_absolute("res://logs/dashboard")
	for dimensions in [Vector2i(960,600), Vector2i(1280,800)]:
		var view := SubViewport.new()
		view.size = dimensions
		view.render_target_update_mode = SubViewport.UPDATE_ALWAYS
		root.add_child(view)
		var ui := Terminal.new()
		view.add_child(ui)
		ui.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		var session := Session.new(Scenario)
		ui.edited.connect(func(_a, _s, _k): edits += 1)
		ui.cancelled.connect(func(): cancels += 1)
		ui.inspect_requested.connect(func(): inspections += 1)
		ui.advanced.connect(func(choice): advances.append(choice))
		ui.rewound.connect(func(turn): rewinds.append(turn))
		ui.advice_request_changed.connect(func(enabled): advice.append(enabled))
		ui.refresh(session)
		var committed: Dictionary = session.state.duplicate(true)
		for slot in [-1,0,12,24,999]:
			ui.open_context(slot)
			ui._place_selected()
			ui._on_facility_action("place")
			ui._on_facility_action("remove")
			ui._place.pressed.emit()
			ui._remove.pressed.emit()
			ui._cancel.pressed.emit()
			ui._select_kind("generator")
			check(edits == 0 and cancels == 0 and session.draft.is_empty(), "Dashboard mutation routes rejected for slot " + str(slot))
		check(session.state == committed, "Dashboard attempts preserve committed state")
		check(ui._facilities.is_empty(), "No build-kind picker is created")
		ui.open_context(0)
		check(ui._facility_info._model.kind == "empty", "Empty tile is not a fictitious generator")
		ui.open_context(12)
		check(ui._facility_info._model.kind == "habitat", "Existing facility details match selected tile")
		ui._inspect.pressed.emit()
		check(inspections > 0, "Read-only 3D observation remains available")
		session.draft = [{"action":"place","slot_id":0,"type":"generator"}]
		ui.open_context(0)
		var draft: Array = session.draft.duplicate(true)
		ui._remove.pressed.emit()
		ui._cancel.pressed.emit()
		ui._facility_info.action_requested.emit("remove")
		ui.set_communication_state({}, true)
		check(session.draft == draft and edits == 0 and cancels == 0, "Remote demolition/cancel cannot erase a site draft")
		for button: Button in [ui._place,ui._remove,ui._cancel]:
			check(button.disabled and not button.is_visible_in_tree(), "Construction controls stay disabled and absent")
		check(ui._facility_info._action_buttons.is_empty(), "Details contain no mutation actions")
		ui._advice_toggle.set_pressed_no_signal(false)
		ui._toggle_advice()
		check(not advice.back(), "Advice-only cancellation remains available")
		ui.set_communication_state({}, false)
		ui.clear_notice()
		ui.open_context()
		ui.focus_primary()
		await settle()
		for node: Control in [ui._resource_overview,ui._slots[0],ui._advance,ui._advice_toggle]:
			check(Rect2(Vector2.ZERO,Vector2(dimensions)).encloses(node.get_global_rect()), "Primary dashboard content fits " + str(dimensions))
		await capture(view, "%dx%d-overview" % [dimensions.x, dimensions.y])
		session.state.turn_id = 2
		session.current_history.snapshots["2"] = session.state.duplicate(true)
		ui.refresh(session)
		check(ui._advance.disabled, "Required event response gates the turn")
		var advanced_before := advances.size()
		ui._advance.pressed.emit()
		check(advances.size() == advanced_before, "Programmatic press cannot bypass required event")
		ui._choose_event(0)
		check(not ui._advance.disabled, "Event choice enables turn advance")
		ui._advance.pressed.emit()
		check(advances.size() == advanced_before + 1 and advances.back() == ui._choice, "Dashboard retains turn operation")
		await create_timer(0.45).timeout
		ui._select_turn(1)
		ui._rewind.pressed.emit()
		check(rewinds.back() == 1, "History rewind remains available")
		ui._scroll.scroll_vertical = 500
		await settle()
		for node: Control in [ui._advance,ui._event_buttons[0],ui._event_buttons[1]]:
			check(node.is_visible_in_tree() and Rect2(Vector2.ZERO,Vector2(dimensions)).encloses(node.get_global_rect()), "Turn/event controls remain pinned while scrolling")
		await capture(view, "%dx%d-event" % [dimensions.x, dimensions.y])
		var guide := Guide.new()
		view.add_child(guide)
		guide.configure_controls(true, false)
		check(guide._controls.text.contains("1 build/remove") and guide._controls.text.contains("3 inspect in 3D"), "Help matches field menu keys")
		view.queue_free()
		await settle()
	print("Dashboard read-only: %d checks / %d failures" % [checks,failures])
	quit(1 if failures else 0)
