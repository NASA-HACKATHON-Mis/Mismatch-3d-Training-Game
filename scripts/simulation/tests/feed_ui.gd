extends SceneTree
const Terminal = preload("res://scripts/ui/terminal.gd")
const Session = preload("res://scripts/simulation/snapshot_store.gd")
const Scenario = preload("res://resources/scenarios/lunar_training.tres")
const Simulation = preload("res://scripts/simulation/simulation.gd")
var checks := 0
var failures := 0
var requests: Array[bool] = []

func _initialize() -> void: call_deferred("_run")
func check(ok: bool, message: String) -> void:
	checks += 1
	if not ok:
		failures += 1
		push_error(message)
func settle() -> void:
	for i in 10: await process_frame
func visible_action(ui, action: Control, dimensions: Vector2i, label: String) -> void:
	check(action.is_visible_in_tree(), label + " visible")
	check(Rect2(Vector2.ZERO, Vector2(dimensions)).encloses(action.get_global_rect()), label + " fits viewport")
	check(not ui._scroll.is_ancestor_of(action), label + " outside scroll")
func capture(view: SubViewport, name: String) -> void:
	if "--render" not in OS.get_cmdline_user_args(): return
	await RenderingServer.frame_post_draw
	var shot := view.get_texture().get_image()
	check(not shot.is_empty(), "Actual renderer image")
	shot.save_png("res://logs/feed-ui/" + name + ".png")

func _run() -> void:
	DirAccess.make_dir_recursive_absolute("res://logs/feed-ui")
	for dimensions in [Vector2i(960,600), Vector2i(1280,800)]:
		var view := SubViewport.new()
		view.size = dimensions
		view.render_target_update_mode = SubViewport.UPDATE_ALWAYS
		root.add_child(view)
		var ui := Terminal.new()
		view.add_child(ui)
		ui.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		var session := Session.new(Scenario)
		ui.refresh(session)
		ui.open_context(0)
		ui.set_weather_context({"mode":"archive", "observed_at":"2016-07-23T02:11Z", "class_type":"M5.0", "explanation":"Historical solar flare records · not live"})
		ui.advice_request_changed.connect(func(enabled: bool): requests.append(enabled))
		await settle()
		for action in [ui._advance, ui._advice_toggle]:
			visible_action(ui, action, dimensions, "T1 " + action.text)
		check(ui._resource_overview._cards.oxygen.title.text == "Life support", "Life support main area")
		check(not ui._resource_overview._cards.food.panel.visible, "Food removed as standalone main gauge")
		check(ui._food_detail.text.contains("36/100"), "Food values remain in details")
		check(ui._resource_overview._shield_label.text == "No shelter", "Absent shelter is honest")
		check(ui._facility_info._action_buttons.is_empty(), "No duplicate build controls")
		check(ui._weather_label.text.contains("2016-07-23") and ui._weather_label.text.contains("Embedded historical data · not live"), "Weather preserves source date and archive mode")
		var before := session.state.duplicate(true)
		ui._advice_toggle.set_pressed_no_signal(true)
		ui._toggle_advice()
		check(requests.back() and session.state == before, "Advice toggle emits request without changing state")
		ui.set_communication_state({}, true)
		check(ui._advice_toggle.button_pressed and ui._communication_label.text.contains("After the next turn"), "Reserved request shows timing")
		check(ui._cancel.disabled and not ui._cancel.is_visible_in_tree(), "Remote draft cancellation is unavailable")
		check(not ui._advice_toggle.disabled and ui._advice_toggle.text.contains("Cancel"), "Advice reservation can be cancelled independently")
		ui.set_communication_state({"pending":{"requested_turn":1,"reply_turn":2}}, false)
		check(ui._advice_toggle.disabled and ui._communication_label.text.contains("T2"), "Waiting prevents duplicate requests")
		ui.set_communication_state({"pending":{},"message":"Prepare a shelter.","response_turn":2}, false)
		check(ui._communication_label.text.contains("Prepare a shelter"), "Advice response readable")
		ui.set_communication_state({}, false)
		await capture(view, "%dx%d-t1" % [dimensions.x,dimensions.y])
		session.draft = [{"action":"place","slot_id":0,"type":"generator"}]
		ui.refresh(session)
		ui._toggle_preview()
		await settle()
		check(ui._remove.disabled and not ui._remove.is_visible_in_tree(), "Draft removal stays local to its site")
		visible_action(ui, ui._advance, dimensions, "Expanded preview advance")
		await capture(view, "%dx%d-preview" % [dimensions.x,dimensions.y])
		session.state.turn_id = 2
		session.current_history.snapshots["2"] = session.state.duplicate(true)
		ui.refresh(session)
		await settle()
		for action in ui._event_buttons: visible_action(ui, action, dimensions, "T2 choice")
		check(ui._advance.disabled, "Required event choice gates advance")
		ui._choose_event(0)
		check(not ui._advance.disabled, "Choosing event enables advance")
		ui._scroll.scroll_vertical = 500
		await settle()
		for action in [ui._advance, ui._event_buttons[0], ui._event_buttons[1]]:
			visible_action(ui, action, dimensions, "Scrolled content action")
		await capture(view, "%dx%d-t2-scrolled" % [dimensions.x,dimensions.y])
		session.draft.clear()
		session.state = Simulation.validate_draft(session.state,[{"action":"place","slot_id":20,"type":"shelter"}]).state
		session.state.turn_id = 4
		session.state.F = 0
		session.current_history.snapshots["4"] = session.state.duplicate(true)
		ui.refresh(session)
		check(ui._resource_overview._shield_label.text == "Shelter ready", "Prepared shelter")
		check(ui._resource_overview._life_food.text.contains("Empty!"), "Food zero risk is in top area")
		ui._choose_event(0)
		check(ui._resource_overview._shield_label.text == "Shelter selected", "Selected shelter has discrete status")
		ui._scroll.scroll_vertical = 0
		await settle()
		await capture(view, "%dx%d-t4-risk" % [dimensions.x,dimensions.y])
		session.draft = [{"action":"remove","slot_id":20}]
		ui.refresh(session)
		check(ui._resource_overview._shield_label.text == "No shelter" and ui._choice.is_empty(), "Removing shelter clears selected state immediately")
		session.draft.clear()
		session.state.turn_id = 7
		session.current_history.snapshots["7"] = session.state.duplicate(true)
		ui.refresh(session)
		check(ui._advice_toggle.disabled, "Last turn prevents unanswered request")
		view.queue_free()
		await settle()
	print("Feed UI: %d checks / %d failures" % [checks,failures])
	quit(1 if failures else 0)
