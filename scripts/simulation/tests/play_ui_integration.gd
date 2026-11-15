extends SceneTree
const Fixture = preload("res://scripts/simulation/tests/ui_fixture.gd")
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
		check(terminal._resource_overview._cards.energy.current.text == "Current 20 / 20" and terminal._resource_overview._cards.oxygen.current.text == "Oxygen 60 / 100" and terminal._food_detail.text.contains("36/100"), "Terminal current values")
		Fixture.edit(game, "place", 11, "battery")
		check(terminal._resource_overview._cards.energy.current.text == "Current 20 / 20" and "40" in terminal._capacity.text, "Current meter separate from draft capacity")
		check(game.session.state == original, "Meters and previews do not commit draft")
		Fixture.cancel_draft(game)
		check(terminal._resource_overview._cards.energy.current_bar.value == 1.0 and game.session.draft.is_empty(), "Cancel preserves current ratio")
		Fixture.edit(game, "place", 0, "generator")
		Fixture.edit(game, "place", 11, "battery")
		game._commit("")
		check(terminal._resource_overview._cards.energy.current.text == "Current %d / 40" % game.session.state.E and game.hud._energy.caption.text == "Power %d/40" % game.session.state.E, "Commit synchronizes terminal and HUD")
		game._restore(1)
		check(terminal._resource_overview._cards.energy.current.text == "Current 20 / 20" and is_equal_approx(terminal._resource_overview._cards.food.current_bar.value,0.36), "Rewind synchronizes terminal")
		await settle()
		for id in ["energy", "oxygen"]:
			var meter: Dictionary = terminal._resource_overview._cards[id]
			check(Rect2(Vector2.ZERO,Vector2(dimensions)).encloses(meter.current.get_global_rect()) and not terminal._scroll.is_ancestor_of(meter.current), "Meter pinned inside viewport")
			check(meter.current.size.x >= meter.current.get_minimum_size().x, "No clipped meter text")
		await capture(view, "%dx%d-terminal" % [dimensions.x,dimensions.y])
		game.hud.configure_controls(false, false)
		game.help.configure_controls(false, false)
		check(not "Space" in game.hud._controls.text and not "drag" in game.help._controls.text, "Unavailable controls not advertised")
		game.hud.configure_controls(true, true)
		game.help.configure_controls(true, true)
		check("Space" in game.hud._controls.text and "drag" in game.help._controls.text, "Available controls explained")
		game._set_mode("explore", "drag")
		game.hud.set_target(false,game.player.global_position,-game.player.global_basis.z)
		game.hud.set_site_target({"kind":"none","slot_id":-1},game.session.preview().state)
		await settle()
		check("drag" in game.hud._controls.text and game.player.look_mode == "drag", "Drag fallback is explained and applied to player")
		check(game.hud._wayfinding.is_visible_in_tree(), "Exploration retains compact terminal directions")
		check(Rect2(Vector2.ZERO, Vector2(dimensions)).encloses(game.hud._wayfinding.get_global_rect()), "Compact directions fit actual viewport")
		await capture(view, "%dx%d-drag-guidance" % [dimensions.x,dimensions.y])
		game._set_mode("explore", "captured")
		game.hud.set_target(true)
		check(game.player.look_mode == "captured" and not "drag" in game.hud._hint.text, "Capture restores player mode without a long hint banner")
		game._pause()
		await settle()
		check(not game.hud._header.get_global_rect().intersects(game.hud._intro.get_global_rect()), "Expanded instructions do not overlap meters")
		view.queue_free()
		await settle()
	print("PE-05 UI integration: %d checks, %d failures" % [checks, failures])
	quit(1 if failures else 0)
