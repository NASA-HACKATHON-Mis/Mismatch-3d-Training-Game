extends SceneTree
## Real input -> gaze/occlusion authority -> local panel -> session -> dashboard.
const Mission = preload("res://scenes/main.tscn")
const Rules = preload("res://scripts/simulation/scenario.gd")
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
func press(game, action: String) -> void:
	var event := InputEventAction.new()
	event.action = action
	event.pressed = true
	game._input(event)
func at_site(game, slot: int) -> void:
	game._set_mode("explore", "drag")
	var target := Rules.slot_position(slot)
	game.player.position = target + Vector3(0,0,3)
	game.player.camera.look_at(target + Vector3(0,0.02,0))
	await physics_frame
	await physics_frame
	game._physics_process(0.016)
func at_console(game) -> void:
	game._set_mode("explore", "drag")
	game.player.position = Vector3(0,0,20)
	game.player.camera.look_at(Vector3(0,1.4,18))
	await physics_frame
	await physics_frame
	press(game, "open_terminal")
func capture(view: SubViewport, label: String) -> void:
	if "--render" not in OS.get_cmdline_user_args(): return
	await settle()
	await RenderingServer.frame_post_draw
	view.get_texture().get_image().save_png("res://logs/ops-e/" + label + ".png")
func _run() -> void:
	DirAccess.make_dir_recursive_absolute("res://logs/ops-e")
	for dimensions in [Vector2i(1280,800),Vector2i(960,600)]:
		var view := SubViewport.new()
		view.size = dimensions
		view.render_target_update_mode = SubViewport.UPDATE_ALWAYS
		root.add_child(view)
		var game = Mission.instantiate()
		view.add_child(game)
		game.set_physics_process(false)
		game.player.set_physics_process(false)
		await settle()
		var ui = game.terminal
		var panel = game._site_panel
		await at_console(game)
		check(game.mode == "terminal" and ui._selected_slot == -1, "E opens console dashboard")
		ui.edited.emit("place", 0, "generator")
		ui._place.pressed.emit()
		check(game.session.draft.is_empty(), "dashboard cannot construct through forged signals or buttons")
		await at_site(game, 11)
		await capture(view, "target-%dx%d" % [dimensions.x,dimensions.y])
		press(game, "site_details")
		check(game.mode == "field" and game._active_site_slot == 11 and not game._site_edit_enabled, "2 opens local read-only details")
		panel.edited.emit("place", 11, "battery")
		check(game.session.draft.is_empty(), "details cannot edit even by forged signal")
		await at_site(game, 11)
		press(game, "site_edit")
		check(game.mode == "field" and game._site_edit_enabled and panel.visible, "1 opens local edit menu")
		check(game.session.draft.is_empty(), "shortcut itself never builds or demolishes")
		game._open_help()
		panel.edited.emit("place", 11, "battery")
		check(game.session.draft.is_empty(), "hidden local editor cannot change state while help is open")
		game._close_help()
		panel._select_kind("battery")
		await capture(view, "edit-%dx%d" % [dimensions.x,dimensions.y])
		panel.edited.emit("place", 0, "generator")
		check(game.session.draft.is_empty(), "panel cannot edit a different remote slot")
		game.player.position = Vector3(0,0,24)
		await physics_frame
		panel._place.pressed.emit()
		check(game.session.draft.is_empty(), "stale menu cannot build after leaving site")
		await at_site(game, 11)
		press(game, "site_edit")
		panel._select_kind("battery")
		var blocker := StaticBody3D.new()
		var blocker_shape := CollisionShape3D.new()
		var box := BoxShape3D.new()
		box.size = Vector3(4,4,0.3)
		blocker_shape.shape = box
		blocker.add_child(blocker_shape)
		game.add_child(blocker)
		blocker.position = Rules.slot_position(11) + Vector3(0,1,2.5)
		await physics_frame
		await physics_frame
		panel._place.pressed.emit()
		check(game.session.draft.is_empty(), "occluded site cannot be changed")
		blocker.queue_free()
		await physics_frame
		await physics_frame
		game._physics_process(0.016)
		panel._place.pressed.emit()
		check(game.session.preview().state.budget == 10 and game.session.draft.size() == 1, "local button builds actual battery draft")
		check(ui._resource_overview._cards.energy.current.text.contains("20 / 20"), "current resources remain confirmed")
		check(ui._resource_overview._cards.energy.preview.text.contains("20 / 40"), "dashboard previews local battery capacity")
		await physics_frame
		await physics_frame
		game._physics_process(0.016)
		panel._remove.pressed.emit()
		check(game.session.preview().state.budget == 12 and game.session.draft.is_empty(), "local remove cancels new construction")
		await at_site(game, 12)
		press(game, "site_edit")
		panel.edited.emit("remove", 12, "")
		check(game.session.preview().state.grid[12] != null, "permanent habitat remains protected")
		await at_site(game, 0)
		press(game, "site_edit")
		panel._place.pressed.emit()
		check(game.session.draft.size() == 1, "local generator build succeeds")
		await physics_frame
		await physics_frame
		panel.inspect_requested.emit(0)
		check(game.mode == "inspect", "local panel opens 3D view")
		panel.edited.emit("remove", 0, "")
		check(game.session.draft.size() == 1, "3D view cannot mutate site")
		game._close_inspection()
		check(game.mode == "field" and game._active_site_slot == 0, "3D view returns to original site panel")
		await at_site(game, 0)
		press(game, "site_inspect")
		check(game.mode == "inspect", "3 shortcut opens local 3D view")
		game._close_inspection()
		check(game.mode == "explore" and game.look_mode == "drag", "3D view returns to prior exploration mode")
		await at_console(game)
		ui.cancelled.emit()
		check(game.session.draft.size() == 1, "dashboard cannot cancel remote construction draft")
		ui.edited.emit("remove", 0, "")
		check(game.session.draft.size() == 1, "dashboard cannot demolish local draft")
		ui.advanced.emit("")
		check(game.session.state.turn_id == 2 and game.session.state.grid[0] != null, "dashboard commits locally prepared turn")
		await at_site(game, 0)
		press(game, "site_edit")
		panel._remove.pressed.emit()
		check(game.session.preview().state.grid[0] == null and game.session.preview().state.budget == 10, "confirmed local removal refunds half cost")
		await at_console(game)
		ui.rewound.emit(1)
		check(game.session.state.turn_id == 1 and game.session.state.budget == 12 and game.session.draft.is_empty(), "rewind restores complete starting state")
		check(not ui._resource_overview._cards.energy.preview_box.visible, "rewind clears stale preview")
		ui.open_context(12)
		await settle()
		game._inspect_selected()
		check(game.mode == "inspect", "dashboard retains read-only 3D inspection")
		game._close_inspection()
		check(game.mode == "terminal", "dashboard inspection returns to dashboard")
		ui._scroll.ensure_control_visible(ui._slots[24])
		await settle()
		check(ui._scroll.get_global_rect().encloses(ui._slots[24].get_global_rect()), "full board reachable by scrolling")
		check(Rect2(Vector2.ZERO,Vector2(dimensions)).encloses(ui._advance.get_global_rect()), "turn control stays in viewport")
		ui._scroll.scroll_vertical = 0
		await capture(view, "dashboard-%dx%d" % [dimensions.x,dimensions.y])
		view.queue_free()
		await settle()
	print("OPS-E integration: %d checks / %d failures" % [checks,failures])
	quit(1 if failures else 0)
