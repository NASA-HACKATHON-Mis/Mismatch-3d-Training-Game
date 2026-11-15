extends SceneTree
const Mission = preload("res://scenes/main.tscn")
const Meter = preload("res://scripts/ui/resource_meter.gd")
const Simulation = preload("res://scripts/simulation/simulation.gd")
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

func _run() -> void:
	var meter := Meter.new()
	root.add_child(meter)
	for pair in [[0, 100], [50, 100], [100, 100], [10, 20], [10, 40], [-5, 100], [120, 100]]:
		meter.set_values("자원", pair[0], pair[1])
		check(is_equal_approx(meter.bar.value, clampf(float(pair[0]) / pair[1], 0, 1)), "Boundary ratio " + str(pair))
		check(meter.caption.text == "자원 %d/%d" % pair, "Unclamped numeric value " + str(pair))
	for invalid in [0, -10]:
		meter.set_values("자원", 10, invalid)
		check(meter.bar.value == 0 and "10 / 확인 불가" in meter.caption.text, "Invalid cap is explicit")
	meter.queue_free()
	await settle()
	DirAccess.make_dir_recursive_absolute("res://logs/pe01")
	for dimensions in [Vector2i(1280, 800), Vector2i(960, 600), Vector2i(480, 800)]:
		var view := SubViewport.new()
		view.size = dimensions
		view.render_target_update_mode = SubViewport.UPDATE_ALWAYS
		root.add_child(view)
		var game = Mission.instantiate()
		view.add_child(game)
		game.set_physics_process(false)
		game.player.set_physics_process(false)
		await settle()
		var hud = game.hud
		var initial: Dictionary = game.session.state.duplicate(true)
		check(hud._energy.caption.text == "전력 20/20" and hud._oxygen.caption.text == "생명 유지 · 산소 60/100" and hud._food.caption.text == "식량 36/100", "Initial resources")
		game._edit("place", 11, "battery")
		check(hud._energy.caption.text == "전력 20/20", "Unconfirmed battery does not change HUD")
		game._edit("place", 0, "generator")
		var expected: Dictionary = Simulation.simulate_turn(initial, game.session.draft, "", game.player.pose())
		hud.refresh(game.session.state)
		check(game.session.state == initial, "HUD does not mutate state")
		game._commit("")
		check(game.session.state.E == expected.state_after.E and game.session.state.O == expected.state_after.O and game.session.state.F == expected.state_after.F, "Rendering preserves turn simulation")
		check(hud._energy.caption.text == "전력 %d/40" % game.session.state.E and is_equal_approx(hud._energy.bar.value, game.session.state.E / 40.0), "Commit refreshes cap and charge")
		game._restore(1)
		check(hud._energy.caption.text == "전력 20/20" and is_equal_approx(hud._oxygen.bar.value, 0.6) and is_equal_approx(hud._food.bar.value, 0.36), "Rewind refreshes all meters")
		game._set_mode("pause")
		await settle()
		var area := Rect2(Vector2.ZERO, Vector2(dimensions))
		check(not hud._header.get_global_rect().intersects(hud._intro.get_global_rect()), "Header and start card do not overlap " + str(dimensions))
		for resource in [hud._energy, hud._oxygen, hud._food]:
			check(area.encloses(resource.get_global_rect()), "Meter fits viewport")
			check(hud._header.get_global_rect().encloses(resource.get_global_rect()), "Meter fits header")
			check(resource.caption.size.x >= resource.caption.get_minimum_size().x, "Caption fits without clipping")
		for mode in ["pause", "explore"]:
			game._set_mode(mode)
			await settle()
			if render:
				await RenderingServer.frame_post_draw
				var screenshot := view.get_texture().get_image()
				check(not screenshot.is_empty(), "Real viewport image")
				screenshot.save_png("res://logs/pe01/%dx%d-%s.png" % [dimensions.x, dimensions.y, mode])
		view.queue_free()
		await settle()
	print("Resource gauges: %d checks, %d failures" % [checks, failures])
	quit(1 if failures else 0)
