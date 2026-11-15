extends SceneTree
const Fixture = preload("res://scripts/simulation/tests/ui_fixture.gd")
const Mission = preload("res://scenes/main.tscn")
const Rules = preload("res://scripts/simulation/scenario.gd")
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
	for i in 5: await process_frame
func fingerprint(game) -> Array:
	return [game.session.state.duplicate(true),game.session.draft.duplicate(true),game.session.current_history.duplicate(true),game.session.previous_attempt.duplicate(true),game.session.attempt_id,game.player.pose()]
func geometry(view, ui) -> void:
	for item in ui.find_children("*","Label",true,false):
		if not item.is_visible_in_tree(): continue
		check(item.get_theme_font_size("font_size") >= 16,"Readable label")
	for item in ui.find_children("*","ScrollContainer",true,false):
		if not item.is_visible_in_tree(): continue
		check(Rect2(Vector2.ZERO,Vector2(view.size)).encloses(item.get_global_rect()),"Scroll in viewport")
		for child in item.get_children():
			if child is Control: check(child.get_combined_minimum_size().x <= item.size.x+1,"Scroll width fits")
func capture(view, name: String) -> void:
	if not render: return
	await RenderingServer.frame_post_draw
	var image: Image = view.get_texture().get_image()
	check(not image.is_empty(),name+" image")
	image.save_png("res://logs/ux16/"+name+".png")
func _run() -> void:
	DirAccess.make_dir_recursive_absolute("res://logs/ux16")
	for dimensions in [Vector2i(1920,1080),Vector2i(1280,720),Vector2i(1024,768),Vector2i(800,900)]:
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
		game.terminal._select_slot(12)
		var first_pose: Dictionary = game.player.pose()
		game._inspect_selected()
		game._close_inspection()
		check(view.get_camera_3d() == game._start_camera and game.player.pose() == first_pose,"Inspection before exploring restores initial camera and pose")
		game._set_mode("explore")
		game._set_mode("terminal")
		for slot in [0,4,20,24]: Fixture.edit(game, "place",slot,"generator")
		var original := fingerprint(game)
		var bodies: int = game.station.find_children("*","CollisionObject3D",true,false).size()
		var shapes: int = game.station.find_children("*","CollisionShape3D",true,false).size()
		var tag := "%dx%d" % [dimensions.x,dimensions.y]
		for slot in [0,4,12,20,24,1]:
			game.terminal._select_slot(slot)
			check(game.station.selected_slot == slot and game.station._selection.position == Rules.slot_position(slot),"slot mapping %d" % slot)
			check(game.station._selection_label.text.begins_with("%02d" % [slot+1]),"Selected number matches")
			check(game.station.find_children("*","CollisionObject3D",true,false).size() == bodies and game.station.find_children("*","CollisionShape3D",true,false).size() == shapes,"Highlight changes no collision")
			check(fingerprint(game) == original,"Selection of existing/blocked empty slot changes presentation only")
			game._inspect_selected()
			await settle()
			check(game.mode == "inspect" and view.get_camera_3d() == game._observation_camera,"Inspection camera active")
			check(not game.player.exploring and Input.mouse_mode == Input.MOUSE_MODE_VISIBLE,"Inspection cannot move")
			check(game.hud._inspection_label.text.contains("미확정 배치 포함"),"Draft inspection explicit")
			geometry(view,game.hud)
			if slot in [0,12,1]: await capture(view,tag+"-slot%02d" % (slot+1))
			var escape := InputEventKey.new()
			escape.keycode = KEY_ESCAPE
			escape.pressed = true
			game._input(escape)
			check(game.mode == "terminal" and view.get_camera_3d() == game.player.camera,"Esc returns to console and original camera")
			check(fingerprint(game) == original,"Inspection and escape leave pose and session unchanged")
		game._inspect_selected()
		var help_key := InputEventKey.new()
		help_key.keycode = KEY_H
		help_key.pressed = true
		game._input(help_key)
		var close_key := InputEventKey.new()
		close_key.keycode = KEY_ESCAPE
		close_key.pressed = true
		game._input(close_key)
		check(game.mode == "inspect" and view.get_camera_3d() == game._observation_camera,"Help returns to observation")
		game.get_window().focus_exited.emit()
		check(game.mode == "pause" and view.get_camera_3d() == game.player.camera and not game.player.exploring,"Focus loss exits observation safely")
		game._set_mode("terminal")
		game.terminal._clear_selection.pressed.emit()
		check(game.station.selected_slot == -1 and not game.station._selection.visible,"Explicit deselect clears highlight")
		game.terminal._select_slot(0)
		check(not game.session.draft.is_empty() and game.station._selection_label.text.contains("발전기"),
			"Cancel fixture still contains its earlier draft generator before removal")
		Fixture.cancel_draft(game)
		check(game.station._selection_label.text.contains("빈 칸"),"Cancel rebuild cannot leave old facility label")
		Fixture.edit(game, "place",0,"generator")
		game.terminal._select_slot(0)
		game._commit("")
		check(game.station.selected_slot == -1,"Commit clears selection")
		game.terminal._select_slot(0)
		Fixture.edit(game, "remove",0,"")
		check(game.station._selection_label.text.contains("빈 칸"),"Removal cannot leave stale building label")
		game._restore(1)
		check(game.station.selected_slot == -1 and not game.station._selection.visible,"Restore clears highlight")
		for kind in ["battery","greenhouse","shelter"]:
			Fixture.edit(game, "place",6,kind)
			game.terminal._select_slot(6)
			game._inspect_selected()
			await settle()
			check(game.station.selected_slot == 6 and game.station._selection_label.text.contains("3D 관찰") and game.terminal._facility_info._model.kind == kind,"Observation highlight and selected facility details stay aligned")
			await capture(view,tag+"-"+kind)
			game._close_inspection()
			Fixture.cancel_draft(game)
		for pair in [[Vector3(0,0,20),"↑"],[Vector3(0,0,10),"↓"],[Vector3(-10,0,18),"→"],[Vector3(10,0,18),"←"]]:
			game.hud.set_target(false,pair[0],Vector3.FORWARD)
			check(game.hud._wayfinding.text.contains(pair[1]),"Compact relative direction matches yaw")
		game.player.apply_pose({"position":[15.0,0.0,-10.0],"yaw":0.0,"pitch":0.0})
		game._set_mode("explore")
		game.hud.set_target(false,game.player.global_position,-game.player.global_basis.z)
		game.hud.set_site_target({"kind":"none","slot_id":-1},game.session.preview().state)
		await settle()
		check(game.hud._wayfinding.text.contains("↓") and game.hud._wayfinding.text.contains("m") and game.hud._wayfinding.is_visible_in_tree(),"Return direction and distance are concise")
		check(Rect2(Vector2.ZERO,Vector2(dimensions)).encloses(game.hud._wayfinding.get_global_rect()),"Return guidance fits HUD")
		await capture(view,tag+"-return")
		game._pause()
		game._open_help()
		await settle()
		geometry(view,game.help)
		await capture(view,tag+"-robot-help")
		game._close_help()
		game._set_mode("terminal")
		game._commit("")
		game._commit("conserve")
		game._commit("")
		game._commit("continue")
		check(game.session.state.phase.begins_with("failed_"),"Closed route for read-only inspection")
		var closed_state := fingerprint(game)
		game.terminal._select_slot(12)
		check(not game.terminal._slots[12].disabled and not game.terminal._inspect.disabled,"Ended facility still selectable for observation")
		game.terminal._select_slot(1)
		check(fingerprint(game) == closed_state,"Ended empty selection never edits")
		view.queue_free()
		await settle()
	print("UX-R06 world UI: %d checks, %d failures" % [checks,failures])
	quit(1 if failures else 0)
