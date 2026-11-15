extends SceneTree
const Mission = preload("res://scenes/main.tscn")
var checks := 0
var failures := 0
var render := false
func _initialize() -> void:
	render = "--render" in OS.get_cmdline_user_args()
	call_deferred("_run")
func check(ok: bool, message: String) -> void:
	checks += 1
	if not ok:
		failures += 1
		push_error(message)
func settle() -> void:
	for i in 6: await process_frame
func capture(view: SubViewport, name: String) -> void:
	if not render: return
	await RenderingServer.frame_post_draw
	view.get_texture().get_image().save_png("res://logs/pe05/" + name + ".png")
func _run() -> void:
	DirAccess.make_dir_recursive_absolute("res://logs/pe05")
	for dimensions in [Vector2i(1280,800), Vector2i(960,600)]:
		var view := SubViewport.new()
		view.size = dimensions
		view.render_target_update_mode = SubViewport.UPDATE_ALWAYS
		root.add_child(view)
		var game = Mission.instantiate()
		view.add_child(game)
		game.set_physics_process(false)
		game.player.set_physics_process(false)
		game._set_mode("terminal")
		await settle()
		var terminal = game.terminal
		var original: Dictionary = game.session.state.duplicate(true)
		check(terminal._energy.caption.text == "전력 20/20" and terminal._oxygen.caption.text == "산소 60/100" and terminal._food.caption.text == "식량 36/100", "Terminal current values")
		game._edit("place", 11, "battery")
		check(terminal._energy.caption.text == "전력 20/20" and "40" in terminal._capacity.text, "Current meter separate from draft capacity")
		check(game.session.state == original, "Meters and previews do not commit draft")
		game._cancel_draft()
		check(terminal._energy.bar.value == 1.0 and game.session.draft.is_empty(), "Cancel preserves current ratio")
		game._edit("place", 0, "generator")
		game._edit("place", 11, "battery")
		game._commit("")
		check(terminal._energy.caption.text == game.hud._energy.caption.text and terminal._energy.caption.text.ends_with("/40"), "Commit synchronizes terminal and HUD")
		game._restore(1)
		check(terminal._energy.caption.text == "전력 20/20" and is_equal_approx(terminal._food.bar.value,0.36), "Rewind synchronizes terminal")
		await settle()
		for meter in [terminal._energy, terminal._oxygen, terminal._food]:
			check(terminal._scroll.get_global_rect().encloses(meter.get_global_rect()), "Meter inside terminal scroll viewport")
			check(meter.caption.size.x >= meter.caption.get_minimum_size().x, "No clipped meter text")
		await capture(view, "%dx%d-terminal" % [dimensions.x,dimensions.y])
		game.hud.configure_controls(false, false)
		game.help.configure_controls(false, false)
		check(not "Space" in game.hud._controls.text and not "드래그" in game.help._controls.text, "Unavailable controls not advertised")
		game.hud.configure_controls(true, true)
		game.help.configure_controls(true, true)
		check("Space" in game.hud._controls.text and "드래그" in game.help._controls.text, "Available controls explained")
		game._set_mode("explore")
		game.look_mode_changed.emit("drag")
		game.hud.set_target(false,game.player.global_position,-game.player.global_basis.z)
		await settle()
		check("드래그" in game.hud._hint.text and game.hud._hint.is_visible_in_tree(), "Drag notice remains visible while exploring")
		check(game.hud._status_box.get_global_rect().encloses(game.hud._hint.get_global_rect()), "Drag guidance fits panel")
		check(Rect2(Vector2.ZERO, Vector2(dimensions)).encloses(game.hud._hint.get_global_rect()), "Drag guidance fits actual viewport")
		await capture(view, "%dx%d-drag-guidance" % [dimensions.x,dimensions.y])
		game.look_mode_changed.emit("captured")
		game.hud.set_target(true)
		check(not "드래그" in game.hud._hint.text, "Capture clears stale drag notice")
		game._pause()
		await settle()
		check(not game.hud._header.get_global_rect().intersects(game.hud._intro.get_global_rect()), "Expanded instructions do not overlap meters")
		view.queue_free()
		await settle()
	print("PE-05 UI integration: %d checks, %d failures" % [checks, failures])
	quit(1 if failures else 0)
