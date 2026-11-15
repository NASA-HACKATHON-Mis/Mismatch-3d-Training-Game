extends SceneTree
const Mission = preload("res://scenes/main.tscn")
const Rules = preload("res://scripts/simulation/scenario.gd")
const Fixture = preload("res://scripts/simulation/tests/ui_fixture.gd")
var checks := 0
var failures := 0
func _initialize() -> void: call_deferred("_run")
func check(ok: bool, label: String) -> void:
	checks += 1
	if not ok:
		failures += 1
		push_error(label)
func settle() -> void:
	for i in 6: await process_frame
func key(game, action: String) -> void:
	var event := InputEventAction.new()
	event.action = action
	event.pressed = true
	game._input(event)
func esc(game) -> void:
	var event := InputEventKey.new()
	event.keycode = KEY_ESCAPE
	event.pressed = true
	game._input(event)
func face(game, position: Vector3, target: Vector3) -> void:
	game._set_mode("explore", "drag")
	game.player.position = position
	game.player.camera.look_at(target)
	await physics_frame
	await physics_frame
func capture(view, label: String) -> void:
	if "--render" not in OS.get_cmdline_user_args(): return
	await settle()
	await RenderingServer.frame_post_draw
	view.get_texture().get_image().save_png("res://logs/map/"+label+".png")
func _run() -> void:
	DirAccess.make_dir_recursive_absolute("res://logs/map")
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
		check(game.hud._intro.visible and game.hud._controls.visible, "first launch keeps onboarding")
		await face(game, Vector3(-6,0,3), Vector3(-6,0.02,0))
		for attempt in 3:
			key(game, "site_details")
			check(game.mode == "field", "2 opens physical details")
			var pose: Dictionary = game.player.pose().duplicate(true)
			esc(game)
			check(game.mode == "explore" and game.look_mode == "drag" and game.player.pose() == pose, "Esc resumes previous exploration immediately")
			check(not game.hud._intro.visible and not game.hud._controls.visible, "closing never repeats onboarding")
		key(game, "site_edit")
		game._open_help()
		check(game.help.visible and not game._site_panel.visible, "help opens over site panel")
		esc(game)
		check(game.mode == "field" and game._site_panel.visible and not game.help.visible, "help Esc restores site panel")
		game._site_panel.closed.emit()
		check(game.mode == "explore", "site close button resumes exploration")
		await face(game,Vector3(0,0,20),Vector3(0,1.4,18))
		key(game,"open_terminal")
		check(game.mode == "terminal", "central console still opens operational dashboard")
		game.terminal.closed.emit()
		check(game.mode == "explore" and not game.hud._intro.visible, "dashboard close button directly resumes")
		for entry in [[0,"generator"],[11,"battery"],[13,"greenhouse"],[24,"shelter"]]:
			Fixture.edit(game,"place",entry[0],entry[1])
		game._set_mode("terminal")
		game._commit("")
		Fixture.edit(game,"remove",24,"")
		await face(game,Rules.slot_position(11),Rules.slot_position(11)+Vector3(0,0,-1))
		key(game,"base_map")
		check(game.mode == "grid" and game._grid_view.visible and not game.terminal.visible, "4 opens dedicated read-only map anywhere")
		var map = game._grid_view
		check(map._slots.size() == 25 and map._slots[0].text.contains("발전기") and map._slots[12].text.contains("거주실"), "map shows all 25 cells and installed facilities")
		check(map._slots[24].text.contains("−") and map._slots[24].text.contains("빈 부지"), "map distinguishes pending removal from empty")
		check(map._slots[11].text.contains("●") and map._summary.text.contains("변경 예정"), "current location and pending layout are marked")
		map._select(0)
		var before: Dictionary = game.session.state.duplicate(true)
		var draft: Array = game.session.draft.duplicate(true)
		game.terminal.advanced.emit("normal")
		game.terminal.rewound.emit(1)
		game.terminal.advice_request_changed.emit(true)
		game.terminal.cancelled.emit()
		game._edit("place",1,"generator")
		check(game.session.state == before and game.session.draft == draft and not game.session.advice_requested, "remote map cannot turn, rewind, request or edit even via hidden signals")
		game._open_help()
		esc(game)
		check(game.mode == "grid" and map.visible and not game.help.visible, "map help returns to map")
		await settle()
		for widget: Control in [map._panel,map._slots[24],map._inspect,map._close]:
			check(Rect2(Vector2.ZERO,Vector2(dimensions)).encloses(widget.get_global_rect()), "map controls fit viewport %s %s %s" % [dimensions,widget.name,widget.get_global_rect()])
		await capture(view,"grid-%dx%d"%[dimensions.x,dimensions.y])
		map._inspect.pressed.emit()
		check(game.mode == "inspect", "read-only map can inspect selected slot")
		game.terminal.advanced.emit("normal")
		game.terminal.rewound.emit(1)
		check(game.session.state == before, "map 3D view also forbids remote operations")
		esc(game)
		check(game.mode == "grid" and map._selected_slot == 0, "inspection Esc restores selected map")
		esc(game)
		check(game.mode == "explore" and game.look_mode == "drag" and not game.hud._intro.visible, "map Esc directly resumes")
		esc(game)
		check(game.mode == "pause" and game.hud._intro.visible and not game.hud._controls.visible and not game.hud._first_step.visible, "exploration Esc shows compact pause without repeated tutorial")
		await capture(view,"pause-%dx%d"%[dimensions.x,dimensions.y])
		esc(game)
		check(game.mode == "explore", "second Esc resumes compact pause")
		game.get_window().focus_exited.emit()
		check(game.mode == "pause" and not game.player.exploring, "focus loss safely pauses without automatic capture")
		game._set_mode("explore","captured")
		key(game,"base_map")
		esc(game)
		check(game.mode == "capturing" and not game.hud._intro.visible, "captured mode requests lock from close gesture without onboarding")
		game._update_capture(2.1,false)
		check(game.mode == "explore" and game.look_mode == "drag", "failed close capture falls back to drag")
		game._set_mode("explore","captured")
		key(game,"base_map")
		map.closed.emit()
		game._update_capture(0.016,true)
		check(game.mode == "explore" and game.look_mode == "captured", "successful close capture restores mouse look")
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		game._physics_process(0.016)
		check(game.mode == "explore" and game.look_mode == "drag" and not game.hud._intro.visible, "late Web-style release after close falls back without pause popup")
		game._pause()
		view.queue_free()
		await settle()
	print("Map and resume: %d checks / %d failures"%[checks,failures])
	quit(1 if failures else 0)

