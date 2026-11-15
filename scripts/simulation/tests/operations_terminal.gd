extends SceneTree
const Mission = preload("res://scenes/main.tscn")
var checks := 0
var failures := 0
var edits := 0

func _initialize() -> void:
	call_deferred("_run")

func check(ok: bool, label: String) -> void:
	checks += 1
	if not ok:
		failures += 1
		push_error(label)

func settle() -> void:
	for i in 8: await process_frame

func _run() -> void:
	DirAccess.make_dir_recursive_absolute("res://logs/ops-b")
	for dimensions in [Vector2i(1280,800), Vector2i(960,600)]:
		var view := SubViewport.new()
		view.size = dimensions
		view.render_target_update_mode = SubViewport.UPDATE_ALWAYS
		root.add_child(view)
		var game = Mission.instantiate()
		view.add_child(game)
		game.set_physics_process(false)
		game.player.set_physics_process(false)
		await settle()
		game._set_mode("terminal")
		var ui = game.terminal
		ui.edited.connect(func(_a, _s, _k): edits += 1)
		var before: Dictionary = game.session.state.duplicate(true)
		ui.open_context(0)
		check(ui._selected_slot == 0 and edits == 0 and game.session.draft.is_empty(), "context selects without building")
		ui._select_slot(1)
		check(ui._selected_slot == 1 and edits == 0, "board click only selects")
		check(game.session.state == before, "selection leaves committed resources untouched")
		ui.open_context(999)
		check(ui._selected_slot == -1 and ui._place.disabled, "invalid selection disabled")
		ui.open_context(12)
		check(ui._remove.disabled and ui._place.disabled, "fixed habitat cannot be built over or removed")
		ui._place_selected()
		check(edits == 0, "guard rejects direct placement over habitat")
		ui.open_context(0)
		ui._place.pressed.emit()
		check(edits == 1 and not game.session.draft.is_empty(), "explicit button adds a real draft")
		check(game.session.state == before, "draft preserves committed state")
		ui._place_selected()
		check(edits == 1, "duplicate placement rejected")
		game._cancel_draft()
		ui.open_context()
		game._set_mode("terminal")
		await settle()
		check(ui.visible and game.mode == "terminal", "terminal visible during geometry/capture")
		check(not ui._working.vertical, "board and controls side by side")
		for node in [ui._resource_grid, ui._slots[0], ui._advance]:
			var rect: Rect2 = node.get_global_rect()
			check(rect.position.x >= 0 and rect.end.x <= dimensions.x and rect.position.y >= 0 and rect.end.y <= dimensions.y, "resource and board visible " + str(dimensions) + " " + str(rect))
		ui._scroll.ensure_control_visible(ui._slots[24])
		await settle()
		check(ui._scroll.get_global_rect().encloses(ui._slots[24].get_global_rect()), "Last board row reachable by scrolling")
		check(Rect2(Vector2.ZERO,Vector2(dimensions)).encloses(ui._advance.get_global_rect()), "Advance remains visible after scrolling board")
		ui._scroll.scroll_vertical = 0
		await settle()
		if "--render" in OS.get_cmdline_user_args():
			await RenderingServer.frame_post_draw
			var file := "res://logs/ops-b/terminal-%dx%d.png" % [dimensions.x,dimensions.y]
			view.get_texture().get_image().save_png(file)
		view.queue_free()
		await settle()
		edits = 0
	print("OPS-B %d checks / %d failures" % [checks, failures])
	quit(1 if failures > 0 else 0)
