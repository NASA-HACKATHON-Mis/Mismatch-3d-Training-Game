extends SceneTree
const Mission = preload("res://scenes/main.tscn")
const History = preload("res://scripts/ui/history_explanation.gd")
const Session = preload("res://scripts/simulation/snapshot_store.gd")
const Simulation = preload("res://scripts/simulation/simulation.gd")
const Scenario = preload("res://resources/scenarios/lunar_training.tres")
var checks := 0
var failures := 0
var render := false
func _initialize() -> void:
	render = "--render" in OS.get_cmdline_user_args()
	call_deferred("_run")
func check(ok: bool, text: String) -> void:
	checks += 1
	if not ok:
		failures += 1
		push_error(text)
func settle() -> void:
	for i in 5: await process_frame
func fingerprint(session) -> Array:
	return [session.state.duplicate(true),session.draft.duplicate(true),session.current_history.duplicate(true),session.previous_attempt.duplicate(true),session.attempt_id,session.committed_command_ids.duplicate(true)]
func capture(view, name: String) -> void:
	if not render: return
	await RenderingServer.frame_post_draw
	var image: Image = view.get_texture().get_image()
	check(not image.is_empty(),name+" rendered")
	image.save_png("res://logs/ux15/"+name+".png")
func geometry(view, ui) -> void:
	check(ui._scroll.get_child(0).get_combined_minimum_size().x <= ui._scroll.size.x + 1,"History fits width")
	check(Rect2(Vector2.ZERO,Vector2(view.size)).encloses(ui._scroll.get_global_rect()),"Scroll frame fits")
	for item in ui.find_children("*","Label",true,false):
		if item.is_visible_in_tree(): check(item.get_theme_font_size("font_size") >= 16,"Readable history label")
func layout(game, battery := false) -> void:
	game._edit("place",0,"generator")
	if battery: game._edit("place",11,"battery")
	game._edit("place",13,"greenhouse")
	game._edit("place",24,"shelter")
func _run() -> void:
	DirAccess.make_dir_recursive_absolute("res://logs/ux15")
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
		var ui = game.terminal
		ui._open_outcome_history()
		await settle()
		check(ui._candidate_note.text.contains("확실한 후보"),"Initial T1 fallback")
		check(not ui._timeline[0].disabled and not ui._rewind.disabled,"Stored initial T1 manually viewable/restorable")
		check(ui._prior.text.contains("이전 시도") and ui._current.text.contains("이번 시도") and ui._current.text.contains("T1"),"Missing sides retain labels")
		var tag := "%dx%d" % [dimensions.x,dimensions.y]
		geometry(view,ui)
		await capture(view,tag+"-initial")
		layout(game)
		check(ui._slots[0].text.contains("일조·차폐") and ui._slots[0].text.contains("발전기"),"Occupied zone remains visible")
		game._commit("")
		game._commit("normal")
		game._commit("")
		check(game.session.state.phase == "failed_power" and game.session.state.E == 0,"Contract T3 failed")
		var original := fingerprint(game.session)
		var candidates := History.candidates(game.session)
		check(candidates.size() > 0 and candidates.size() <= 2,"Relevant bounded candidates")
		for candidate in candidates:
			var stored: Dictionary = game.session.snapshot(candidate.turn)
			check(not stored.is_empty() and candidate.text.contains(History.start_line(stored)),"Candidate facts match actual stored start")
			var fork = Session.new(Scenario)
			fork.current_history = game.session.current_history.duplicate(true)
			check(not fork.restore_turn(candidate.turn).has("error"),"Candidate really restorable")
		ui._open_outcome_history()
		ui._select_candidate(0)
		await settle()
		check(fingerprint(game.session) == original,"Candidate selection is read only")
		check(ui._candidate_note.text.contains("성공을 보장하지"),"No invented success claim")
		check(ui._start_preview.text.contains("편집"),"Draft vs stored start distinguished")
		geometry(view,ui)
		await capture(view,tag+"-candidates")
		ui._scroll.ensure_control_visible(ui._candidate_buttons[1])
		await settle()
		await capture(view,tag+"-candidate2")
		game._restore(2)
		var old_command := {"attempt_id":1,"turn_id":2,"command_id":999,"draft":[],"event_choice":"normal"}
		check(game.session.commit_turn(old_command,{},"terminal").get("error") == "old_attempt","Old attempt rejected")
		game._commit("conserve")
		game._commit("")
		ui._open_outcome_history()
		ui._select_turn(3)
		await settle()
		check(game.session.compare_turn(3).delta == {"E":8,"O":2,"F":-6},"Contract T3 delta exact")
		check(ui._prior.text.contains("이전 시도 · 시도 1 · T3") and ui._current.text.contains("이번 시도 · 시도 2 · T3"),"Attempt and turn identity")
		check(ui._prior.text.contains("계산 전 중단") and ui._current.text.contains("산소 생산 8"),"Interrupted calculation is not zero")
		check(ui._delta.text.contains("재배 유지 → 절전") and ui._delta.text.contains("시작 상태 차이") and ui._delta.text.contains("시작 재배"),"Actual choice/start/growth differences")
		geometry(view,ui)
		ui._scroll.ensure_control_visible(ui._compare_title)
		await settle()
		await capture(view,tag+"-comparison")
		# Read-only explanation remains detached and handles simultaneous layout changes.
		var before := fingerprint(game.session)
		History.changes(game.session,3)
		History.side(game.session,3,true)
		check(before == fingerprint(game.session),"Explanation leaves session immutable")
		game.session.current_history.results["3"].state_after.facilities[1].slot_id = 1
		check(History.changes(game.session,3).contains("실행 배치 차이") and History.changes(game.session,3).contains("단정하지"),"Multiple changes do not assert one cause")
		game.session.current_history = before[2].duplicate(true)
		game._commit("shelter")
		game._commit("acknowledge")
		game._commit("")
		game._commit("")
		game._restore(2)
		ui._open_outcome_history()
		ui._select_turn(7)
		await settle()
		check(not ui._timeline[6].disabled and ui._rewind.disabled,"Archived future is readable but not restorable")
		check(ui._prior.text.contains("훈련 완료") and ui._current.text.contains("결과 없음") and ui._start_preview.text.contains("조회 전용"),"No invented unreached current result")
		geometry(view,ui)
		ui._scroll.ensure_control_visible(ui._compare_title)
		await settle()
		await capture(view,tag+"-archived")
		ui._scroll.ensure_control_visible(ui._delta)
		await settle()
		await capture(view,tag+"-archived-end")
		game._restore(1)
		game._restore(1)
		check(game.session.state.turn_id == 1 and game.session.draft.is_empty(),"Repeated restore preserves contract")
		check(History.candidates(game.session).is_empty(),"No candidates from archived future")
		view.queue_free()
		await settle()
	var sparse = Session.new(Scenario)
	sparse.state.phase = "failed_power"
	sparse.current_history.snapshots.clear()
	check(History.candidates(sparse).is_empty(),"Missing records fallback")
	for route in ["life","safety"]:
		var session = Session.new(Scenario)
		session.edit("place",0,"generator",{})
		session.edit("place",11,"battery",{})
		session.edit("place",24,"shelter",{})
		while session.state.phase == "planning":
			var turn: int = session.state.turn_id
			var choice: String = "conserve" if turn == 2 else ("continue" if route == "safety" else "shelter") if turn == 4 else "acknowledge" if turn == 5 else ""
			session.commit_turn({"attempt_id":session.attempt_id,"turn_id":turn,"command_id":turn,"draft":session.draft.duplicate(true),"event_choice":choice},{},"terminal")
		var original := fingerprint(session)
		var found := History.candidates(session)
		check(not found.is_empty(),route+" has factual candidate")
		for candidate in found:
			check(candidate.text.contains(History.start_line(session.snapshot(candidate.turn))),route+" facts match snapshot")
			check(candidate.text.contains("재배실 비용") if route == "life" else candidate.text.contains("대피소"),route+" relevant evidence")
			check(candidate.turn > 1,"Candidate is not always T1")
		check(fingerprint(session) == original,"Candidate lookup immutable")
	# Clamp explanation uses each branch's real starting oxygen, not a guessed +2.
	var capped = Session.new(Scenario)
	var start: Dictionary = capped.snapshot(1)
	start.O = 99
	var current := Simulation.simulate_turn(start,[],"",{})
	var old_start := start.duplicate(true)
	old_start.O = 100
	var old := Simulation.simulate_turn(old_start,[],"",{})
	capped.current_history = {"snapshots":{"1":start},"results":{"1":current}}
	capped.previous_attempt = {"attempt_id":1,"snapshots":{"1":old_start},"results":{"1":old}}
	check(History.side(capped,1,false).contains("변화 +1") and History.side(capped,1,true).contains("변화 +0"),"Each side uses actual capped oxygen change")
	check(History.changes(capped,1).contains("산소 100 → 99"),"Starting oxygen difference explicit")
	print("UX-R05 rewind UI: %d checks, %d failures" % [checks,failures])
	quit(1 if failures else 0)
