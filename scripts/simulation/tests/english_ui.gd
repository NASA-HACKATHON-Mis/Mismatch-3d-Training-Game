extends SceneTree
## Audit text instantiated by the real offline game, including hidden controls.
const Mission = preload("res://scenes/main.tscn")
const Fixture = preload("res://scripts/simulation/tests/ui_fixture.gd")
var checks := 0
var failures := 0
var examined := 0
var stages := 0
var kinds: Dictionary = {}
var unique_text: Dictionary = {}
var reported_hangul: Dictionary = {}

func _initialize() -> void:
	OS.set_environment("LUNAR_OFFLINE", "1")
	call_deferred("_run")

func check(ok: bool, message: String) -> void:
	checks += 1
	if not ok:
		failures += 1
		push_error(message)

func has_hangul(value: String) -> bool:
	for index in value.length():
		var code := value.unicode_at(index)
		if (code >= 0x1100 and code <= 0x11ff) or (code >= 0x3130 and code <= 0x318f) or (code >= 0xac00 and code <= 0xd7af) or (code >= 0xa960 and code <= 0xa97f) or (code >= 0xd7b0 and code <= 0xd7ff):
			return true
	return false

func inspect_text(value: String, node: Node, field: String, stage: String) -> void:
	if value.strip_edges().is_empty(): return
	examined += 1
	var kind := "tooltip" if field == "tooltip_text" else node.get_class()
	kinds[kind] = int(kinds.get(kind, 0)) + 1
	unique_text[value] = true
	checks += 1
	if has_hangul(value):
		failures += 1
		var signature := kind + ":" + value
		if not reported_hangul.has(signature):
			reported_hangul[signature] = true
			push_error("%s: Hangul in %s.%s: %s" % [stage, node.get_path(), field, value])

func walk(node: Node, stage: String) -> int:
	var visible_strings := 0
	if node is Label or node is Button or node is RichTextLabel or node is Label3D:
		inspect_text(node.text, node, "text", stage)
		if not node.text.strip_edges().is_empty() and node.is_visible_in_tree(): visible_strings += 1
	if node is Control: inspect_text(node.tooltip_text, node, "tooltip_text", stage)
	for child in node.get_children(): visible_strings += walk(child, stage)
	return visible_strings

func audit(game: Node, stage: String) -> void:
	stages += 1
	var before := examined
	var visible_count := walk(game, stage)
	check(examined > before, stage + ": nonempty text was examined")
	check(visible_count > 0, stage + ": visible game text was examined")

func settle() -> void:
	for frame in 3: await process_frame

func new_game() -> Node:
	var game = Mission.instantiate()
	root.add_child(game)
	game.set_physics_process(false)
	game.player.set_physics_process(false)
	await settle()
	return game

func prepare(game, route: String) -> void:
	game._set_mode("terminal")
	Fixture.edit(game, "place", 0, "generator")
	Fixture.edit(game, "place", 11, "greenhouse" if route == "power" else "battery")
	if route != "life": Fixture.edit(game, "place", 13, "greenhouse")
	Fixture.edit(game, "place", 20, "shelter")

func _run() -> void:
	check(has_hangul(String.chr(0xd55c)) and has_hangul(String.chr(0x3131)) and has_hangul(String.chr(0x1100)), "Hangul detector covers syllables and jamo")
	check(not has_hangul("Power 20/40 · NASA → T4"), "English and symbols remain valid")
	var game = await new_game()
	audit(game, "startup")
	game._open_help()
	check(game.help._pages.size() == 3, "All three guide pages exist")
	for page in game.help._pages.size():
		game.help._select_page(page)
		check(game.help._pages[page].is_visible_in_tree(), "Requested guide page is visible")
		audit(game, "guide page %d" % page)
	game._close_help()
	game._set_mode("explore", "drag")
	game.player.position = Vector3(-6, 0, 3)
	game.player.camera.look_at(Vector3(-6, 0.02, 0))
	await physics_frame
	await physics_frame
	game._site_action("edit")
	check(game.mode == "field", "Physical pad opens field menu")
	for kind in ["generator", "battery", "greenhouse", "shelter"]:
		game._site_panel._select_kind(kind)
		audit(game, "empty field choice " + kind)
	game._site_panel.set_access_allowed(false)
	audit(game, "field access denied")
	game._set_mode("explore", "drag")
	game._site_action("details")
	check(game.mode == "field", "Physical pad opens details")
	audit(game, "field details")
	prepare(game, "success")
	for slot in [0, 11, 12, 13, 20]:
		game.terminal._select_slot(slot)
		audit(game, "dashboard facility %d" % slot)
	game._set_mode("explore", "drag")
	game._open_grid()
	check(game.mode == "grid", "Dedicated base map opened")
	game._grid_view._select(0)
	audit(game, "map with planned layout")
	game._inspect_grid(0)
	check(game.mode == "inspect", "Map opens 3D inspection")
	audit(game, "3D inspection")
	game._close_inspection()
	game._pause()
	audit(game, "pause")
	game.free()
	await settle()

	for route in ["success", "power", "life", "safety"]:
		game = await new_game()
		prepare(game, route)
		game.terminal._toggle_preview()
		if route == "success": game._set_advice_request(true)
		var guard := 0
		while game.session.state.phase == "planning" and guard < 8:
			guard += 1
			var turn: int = game.session.state.turn_id
			audit(game, "%s T%d conditional forecast" % [route, turn])
			for option in game.terminal._event_values.size():
				game.terminal._choose_event(option)
				audit(game, "%s T%d response %d forecast" % [route, turn, option])
			var choice := ""
			if turn == 2: choice = "normal" if route == "power" else "conserve"
			if turn == 4: choice = "continue" if route == "safety" else "shelter"
			if turn == 5: choice = "acknowledge"
			game._commit(choice)
			audit(game, "%s T%d result" % [route, turn])
		var expected := {"success":"completed", "power":"failed_power", "life":"failed_life_support", "safety":"failed_safety"}
		check(game.session.state.phase == expected[route], route + ": actual expected outcome reached")
		check(game.terminal._outcome_card.visible and not game.terminal._outcome_title.text.is_empty(), route + ": outcome text exists")
		game.terminal._toggle_outcome_details()
		game.terminal._open_outcome_history()
		for turn in game.session.current_history.results:
			game.terminal._select_turn(int(turn))
			audit(game, "%s history T%s" % [route, turn])
		game._pause()
		audit(game, route + " outcome pause")
		game._set_mode("terminal")
		game._restore(2)
		audit(game, route + " restored timeline")
		game._commit("conserve")
		game.terminal._open_outcome_history()
		game.terminal._select_turn(2)
		check(not game.session.compare_turn(2).is_empty(), route + ": previous/current attempt comparison exists")
		audit(game, route + " two-attempt comparison")
		game.free()
		await settle()
	check(stages >= 50 and examined >= 1000 and unique_text.size() >= 100, "Audit examined substantial dynamic UI content")
	for kind in ["Label", "Button", "Label3D", "tooltip"]:
		check(int(kinds.get(kind, 0)) > 0, "Examined actual " + kind + " strings")
	print("English runtime UI: %d checks, %d failures; %d stages, %d strings, %d unique; types=%s" % [checks, failures, stages, examined, unique_text.size(), kinds])
	quit(1 if failures else 0)
