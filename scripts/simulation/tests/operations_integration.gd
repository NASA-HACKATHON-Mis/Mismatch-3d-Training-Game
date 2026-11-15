extends SceneTree
const Mission = preload("res://scenes/main.tscn")
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
func press_e(game) -> void:
	var event := InputEventAction.new()
	event.action = "open_terminal"
	event.pressed = true
	game._input(event)
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
		game._set_mode("explore","drag")
		game.player.position = Vector3(-6,0,3)
		game.player.camera.look_at(Vector3(-6,0.02,1))
		await physics_frame
		await physics_frame
		game._physics_process(0.016)
		check(game.hud._hint.text.contains("여기 짓기"),"site HUD prompt")
		press_e(game)
		var ui = game.terminal
		check(game.mode == "terminal" and ui._selected_slot == 11,"E opens correct empty site")
		check(game.session.draft.is_empty(),"E does not build")
		ui._select_kind("battery")
		ui._facility_info.action_requested.emit("place")
		check(game.session.preview().state.budget == 10,"card builds through Session")
		check(ui._resource_overview._cards.energy.current.text.contains("20 / 20"),"current remains confirmed")
		check(ui._resource_overview._cards.energy.preview.text.contains("20 / 40"),"preview uses new capacity")
		check(ui._facility_info._model.kind == "battery","occupied site card reflects actual building")
		ui._facility_info.action_requested.emit("remove")
		check(game.session.preview().state.budget == 12,"card removes draft through Session")
		ui.open_context(12)
		ui._facility_info.action_requested.emit("remove")
		check(game.session.preview().state.grid[12] != null,"habitat protected from forged remove")
		ui.open_context(0)
		ui._select_kind("generator")
		ui._facility_info.action_requested.emit("place")
		game._commit("")
		check(game.session.state.turn_id == 2,"turn advances after card build")
		game._restore(1)
		check(game.session.state.turn_id == 1 and game.session.state.budget == 12 and game.session.draft.is_empty(),"rewind restores state")
		check(not ui._resource_overview._cards.energy.preview_box.visible,"rewind clears stale preview")
		game._pause()
		game._start_exploring()
		game._update_capture(0.016,true)
		check(game.mode == "explore" and game.player.exploring,"pause and capture resume")
		game.player.position = Vector3(0,0,20)
		game.player.camera.look_at(Vector3(0,1.4,18))
		await physics_frame
		await physics_frame
		press_e(game)
		check(game.mode == "terminal" and ui._selected_slot == -1,"central console opens overview")
		ui.open_context(0)
		await settle()
		check(ui._facility_info.is_visible_in_tree() and ui._resource_overview.is_visible_in_tree(),"new components mounted")
		check(ui._slots[24].get_global_rect().end.y <= dimensions.y,"full board visible")
		if "--render" in OS.get_cmdline_user_args():
			await RenderingServer.frame_post_draw
			view.get_texture().get_image().save_png("res://logs/ops-e/terminal-%dx%d.png" % [dimensions.x,dimensions.y])
		view.queue_free()
		await settle()
	print("OPS-E integration: %d checks / %d failures" % [checks,failures])
	quit(1 if failures else 0)
