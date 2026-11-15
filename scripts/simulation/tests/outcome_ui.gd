extends SceneTree
const Fixture = preload("res://scripts/simulation/tests/ui_fixture.gd")
const Mission = preload("res://scenes/main.tscn")
const Outcome = preload("res://scripts/ui/outcome_summary.gd")
var checks := 0
var failures := 0
var render := false
func _initialize() -> void:
	render = "--render" in OS.get_cmdline_user_args()
	call_deferred("_run")
func check(value: bool, message: String) -> void:
	checks += 1
	if not value:
		failures += 1
		push_error(message)
func settle() -> void:
	for i in 5: await process_frame
func fingerprint(game) -> Array:
	return [game.session.state.duplicate(true),game.session.draft.duplicate(true),game.session.current_history.duplicate(true),game.session.previous_attempt.duplicate(true),game.session.attempt_id,game.session.committed_command_ids.duplicate(true),game._command_serial]
func prepare(game, route: String) -> void:
	game._set_mode("terminal")
	Fixture.edit(game, "place",0,"generator")
	Fixture.edit(game, "place",11,"greenhouse" if route == "power" else "battery")
	if route != "life": Fixture.edit(game, "place",13,"greenhouse")
	Fixture.edit(game, "place",20,"shelter")
func finish(game, route: String) -> void:
	while game.session.state.phase == "planning":
		var turn: int = game.session.state.turn_id
		var choice := ""
		if turn == 2: choice = "normal" if route == "power" else "conserve"
		if turn == 4: choice = "continue" if route == "safety" else "shelter"
		if turn == 5: choice = "acknowledge"
		game._commit(choice)
func geometry(view, ui, label: String) -> void:
	for item in ui.find_children("*","ScrollContainer",true,false):
		if not item.is_visible_in_tree(): continue
		check(Rect2(Vector2.ZERO,Vector2(view.size)).encloses(item.get_global_rect()),label+" frame fits")
		for child in item.get_children():
			if child is Control: check(child.get_combined_minimum_size().x <= item.size.x + 1,label+" content fits")
	for item in ui.find_children("*","Label",true,false):
		if item.is_visible_in_tree(): check(item.get_theme_font_size("font_size") >= 16,label+" readable size")
func capture(view, name: String) -> void:
	if not render: return
	await RenderingServer.frame_post_draw
	var image: Image = view.get_texture().get_image()
	check(not image.is_empty(),name+" rendered")
	image.save_png("res://logs/ux14/"+name+".png")
func _run() -> void:
	DirAccess.make_dir_recursive_absolute("res://logs/ux14")
	for dimensions in [Vector2i(1920,1080),Vector2i(1280,720),Vector2i(1024,768),Vector2i(800,900)]:
		for route in ["success","power","life","safety"]:
			var view := SubViewport.new()
			view.size = dimensions
			view.render_target_update_mode = SubViewport.UPDATE_ALWAYS
			root.add_child(view)
			var game = Mission.instantiate()
			view.add_child(game)
			game.set_physics_process(false)
			game.player.set_physics_process(false)
			# Mouse capture is tested separately; keep this UI fixture deterministic.
			game._menu_look_mode = "drag"
			await settle()
			prepare(game,route)
			finish(game,route)
			await settle()
			var expected := {"success":"completed","power":"failed_power","life":"failed_life_support","safety":"failed_safety"}
			check(game.session.state.phase == expected[route],route+" reachable route")
			var turn: int = game.session.state.turn_id
			check(game.terminal._outcome_card.visible,"Outcome visible")
			check(not game.terminal._outcome_details.visible,"Long history starts collapsed")
			if route == "success": check(game.terminal._outcome_title.text == "7-turn mission complete!","Success celebration")
			else: check(game.terminal._outcome_title.text.contains("T%d" % turn),"Failure turn explicit")
			var reason: String = game.terminal._outcome_reason.text
			if route == "power": check(reason.contains("needed") and reason.contains("were not calculated"),"Power need and skipped steps")
			if route == "life": check(reason.begins_with("Food reached 0") and not reason.contains("Oxygen"),"Only depleted food named")
			if route == "safety": check(reason.contains("Shelter") and reason.contains("power, oxygen"),"Safety prerequisite before resources")
			var tag := "%dx%d-%s" % [dimensions.x,dimensions.y,route]
			geometry(view,game.terminal,tag)
			await capture(view,tag)
			var original := fingerprint(game)
			game.terminal._toggle_outcome_details()
			await settle()
			geometry(view,game.terminal,tag+" details")
			var summary: String = game.terminal._outcome_details.text
			check(summary.split("\n").size() == game.session.current_history.results.size(),"Exactly current branch history")
			game.session.previous_attempt = {"results":{"99":{"phase":"completed"}}}
			check(Outcome.history_lines(game.session) == summary,"Previous attempt excluded")
			game.session.previous_attempt = original[3].duplicate(true)
			game.terminal.closed.emit()
			await settle()
			check(game.mode == "explore" and game.hud._heading.text == Outcome.heading(game.session.state),"Close returns to exploration and preserves outcome heading")
			check(not game.hud._intro.visible, "Closing a result does not show a pause popup")
			game._pause()
			check(not game.hud._first_step.visible and not game.hud._guide_toggle.visible,"No first intro on outcome")
			check(game.hud._start.text == "Explore the base" and game.hud._result_button.visible,"Explore and reopen actions")
			geometry(view,game.hud,tag+" pause")
			await capture(view,tag+"-closed")
			game._open_help()
			game._close_help()
			check(game.hud._heading.text == Outcome.heading(game.session.state),"Help preserves outcome")
			game._set_mode("explore", "drag")
			game._pause()
			game.hud.result_requested.emit()
			check(game.mode == "terminal" and game.terminal._outcome_card.visible,"Reopen after exploring")
			game.terminal._advance_turn()
			game.terminal._advance_turn()
			check(fingerprint(game) == original,"Closed result cannot commit; UI only unchanged")
			game.terminal._select_slot(12)
			game._inspect_selected()
			await settle()
			check(game.mode == "inspect" and game.hud._inspection_label.text.contains("confirmed layout"),"Ended observation uses confirmed layout")
			if render:
				await RenderingServer.frame_post_draw
				view.get_texture().get_image().save_png("res://logs/ux16/"+tag+"-ended-inspection.png")
			game._close_inspection()
			game.terminal._select_slot(1)
			check(fingerprint(game) == original,"All ended phases allow read-only map selection")
			check(game.terminal._advance.disabled,"Ended inspection never re-enables advancing")
			var escape := InputEventKey.new()
			escape.keycode = KEY_ESCAPE
			escape.pressed = true
			game._input(escape)
			check(game.mode == "explore" and fingerprint(game) == original,"Escape returns to exploration without state change")
			game._pause()
			game._reopen_result()
			game._open_help()
			game._input(escape)
			check(not game.help.visible and game.mode == "terminal" and fingerprint(game) == original,"Escape returns from help to result")
			game.terminal._open_outcome_history()
			await settle()
			check(game.terminal._history_toggle.has_focus() and game.terminal._scroll.scroll_vertical > 0,"Retry scrolls to focused history")
			check(game.terminal._history_body.visible,"Retry exposes history")
			game._restore(1)
			check(not game.terminal._outcome_card.visible and game.session.state.phase == "planning","Rewind clears old outcome")
			game._pause()
			check(not game.hud._ended and not game.hud._result_button.visible,"Rewind clears HUD outcome")
			game._set_mode("terminal")
			prepare(game,route)
			game.terminal._advance_turn()
			game.terminal._advance_turn()
			check(game.session.current_history.results.size() == 1 and game.session.state.turn_id == 2,"Double UI advance commits one turn")
			await create_timer(0.45).timeout
			finish(game,route)
			check(game.session.state.phase == expected[route],"Replayed outcome restored")
			view.queue_free()
			await settle()
	# Equality is also a power failure; no fabricated available/consumed quantity.
	var equal_result := {"phase":"failed_power","state_after":{},"stats":{"demand":6}}
	check(Outcome.reason(equal_result).contains("reaching 0"),"Power equality boundary explanation")
	print("UX-R04 outcome UI: %d checks, %d failures" % [checks,failures])
	quit(1 if failures else 0)
