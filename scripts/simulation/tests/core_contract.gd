extends SceneTree
## Replays the v0.1 arithmetic plus the scene's interaction/restore boundaries.

const Scenario = preload("res://resources/scenarios/lunar_training.tres")
const Rules = preload("res://scripts/simulation/scenario.gd")
const Simulation = preload("res://scripts/simulation/simulation.gd")
const Session = preload("res://scripts/simulation/snapshot_store.gd")
const Mission = preload("res://scenes/main.tscn")
const POSE := {"position": [0.0, 0.0, 20.0], "yaw": 0.0, "pitch": 0.0}
var _checks := 0
var _failures := 0


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	_normal_path()
	_rewind_path()
	_draft_edges()
	await _scene_path()
	print("HH-001: %d checks, %d failures" % [_checks, _failures])
	quit(1 if _failures else 0)


func _check(ok: bool, context: String) -> void:
	_checks += 1
	if not ok:
		_failures += 1
		push_error(context)


func _command(session, choice := "", id := 1) -> Dictionary:
	return {"attempt_id": session.attempt_id, "turn_id": session.state.turn_id,
		"command_id": id, "draft": session.draft.duplicate(true), "event_choice": choice}


func _commit(session, choice := "", pose: Dictionary = POSE) -> Dictionary:
	return session.commit_turn(_command(session, choice), pose, "terminal")


func _layout(session, battery: bool) -> void:
	_check(session.edit("place", 0, "generator", POSE).has("state"), "sunlit generator")
	if battery:
		_check(session.edit("place", 11, "battery", POSE).has("state"), "battery")
	_check(session.edit("place", 13, "greenhouse", POSE).has("state"), "greenhouse")
	_check(session.edit("place", 24, "shelter", POSE).has("state"), "shelter")


func _numbers(result: Dictionary, expected: Array, context: String) -> void:
	_check(result.has("state_after"), context + ": result accepted")
	if not result.has("state_after"):
		return
	var end: Dictionary = result.state_after
	var farm := Simulation.facility_at(end, 13)
	_check([end.E, end.O, end.F, farm.get("growth", -1)] == expected,
		"%s: expected E/O/F/growth %s, got %s" % [context, expected, [end.E, end.O, end.F, farm.get("growth", -1)]])


func _normal_path() -> void:
	var session = Session.new(Scenario)
	_check(session.state.grid.size() == 25 and session.state.grid[12] == 1, "25 slots with fixed habitat")
	_check(Rules.slot_position(0) == Vector3(-12, 0, -12) and Rules.slot_position(24) == Vector3(12, 0, 12),
		"north-west/south-east slot coordinates")
	_layout(session, true)
	var expected := [[28, 62, 30, 1], [18, 64, 24, 2], [8, 66, 36, 0], [20, 68, 30, 0],
		[28, 70, 24, 1], [36, 72, 18, 2], [40, 74, 42, 0]]
	var choices := ["", "normal", "", "shelter", "acknowledge", "", ""]
	var archived: Dictionary
	for i in 7:
		var cmd := _command(session, choices[i])
		var result: Dictionary = session.commit_turn(cmd, POSE, "terminal")
		_numbers(result, expected[i], "normal T%d" % (i + 1))
		var state_copy: Dictionary = session.state.duplicate(true)
		_check(session.commit_turn(cmd, POSE, "terminal") == result and session.state == state_copy,
			"duplicate T%d commit returns stored result only" % (i + 1))
		archived = result
	_check(archived.get("phase") == "completed" and session.state.mission_progress == 7, "7 turns completed")
	_check(session.state.supply_delivered and archived.stats.supply == 12, "T7 supply exactly once")
	_check(not session.result_at(5).state_after.supply_delivered and session.result_at(5).stats.supply == 0,
		"no T5 supply")
	_check(session.snapshot(1).facilities.size() == 1 and session.snapshot(1).budget == 12, "T1 snapshot immutable")


func _rewind_path() -> void:
	var session = Session.new(Scenario)
	_layout(session, false)
	var saved := {"position": [0.45, 0.0, 19.2], "yaw": 0.22, "pitch": -0.16}
	_numbers(_commit(session, "", saved), [20, 62, 30, 1], "no battery T1")
	var no_choice := _command(session)
	_check(session.commit_turn(no_choice, POSE, "terminal").get("error") == "choose_fault", "T2 requires choice")
	_numbers(_commit(session, "normal"), [10, 64, 24, 2], "no battery T2")
	var failed_cmd := _command(session)
	var failed: Dictionary = session.commit_turn(failed_cmd, POSE, "terminal")
	_numbers(failed, [0, 64, 24, 2], "no battery T3")
	_check(failed.phase == "failed_power" and failed.not_applied_steps == ["oxygen", "growth", "supply", "food"],
		"equal supply/demand fails power and skips later phases")
	var start: Dictionary = session.snapshot(2)
	var restored: Dictionary = session.restore_turn(2).state
	_check(restored.player == saved and restored.budget == 2 and restored.input_mode == "terminal",
		"restored pose/yaw/pitch, budget, locked input")
	_check(restored == start, "entire T2 start restored")
	_check(session.commit_turn(failed_cmd, POSE, "terminal").get("error") == "old_attempt" and session.state == restored,
		"old attempt rejected without mutation")
	var wrong := _command(session, "conserve")
	wrong.turn_id = 3
	_check(session.commit_turn(wrong, POSE, "terminal").get("error") == "wrong_turn", "future turn rejected")
	wrong.turn_id = 1
	_check(session.commit_turn(wrong, POSE, "terminal").get("error") == "wrong_turn", "stale nonduplicate turn rejected")
	_check(session.compare_turn(3).is_empty(), "comparison waits for both results")
	var expected := [[14, 64, 24, 1], [8, 66, 18, 1], [20, 68, 12, 1], [20, 70, 6, 2],
		[20, 72, 18, 0], [20, 74, 24, 1]]
	var choices := ["conserve", "", "shelter", "acknowledge", "", ""]
	for i in 6:
		_numbers(_commit(session, choices[i]), expected[i], "rewound T%d" % (i + 2))
	var compared: Dictionary = session.compare_turn(3)
	_check(compared.delta == {"E": 8, "O": 2, "F": -6} and compared.previous.phase == "failed_power"
		and compared.current.phase == "turn_complete", "same-turn failure vs completion comparison")
	_check(session.compare_turn(7).is_empty(), "no fabricated T7 comparison with earlier failure")
	var latest_attempt: int = session.attempt_id
	session.restore_turn(2)
	_check(session.previous_attempt.attempt_id == latest_attempt and not session.state.supply_delivered
		and session.result_at(7).is_empty() and session.snapshot(3).is_empty(),
		"repeated rewind archives one attempt and removes future progress")
	_commit(session, "normal")
	var replay: Dictionary = _commit(session)
	_check(replay.state_after == failed.state_after and replay.causes == failed.causes,
		"identical state and decisions reproduce identical failure")


func _draft_edges() -> void:
	var session = Session.new(Scenario)
	var saved: Dictionary = session.state.duplicate(true)
	_check(session.edit("remove", 12, "", POSE).get("error") == "fixed_habitat", "habitat cannot be removed")
	_check(session.edit("place", 25, "generator", POSE).get("error") == "invalid_slot", "reject reserved/non-slot build")
	var overlap := {"position": [-12.0, 0.0, -12.0], "yaw": 0.0, "pitch": 0.0}
	_check(session.edit("place", 0, "generator", overlap).get("error") == "player_overlap", "player overlap rejected")
	_check(session.draft.is_empty() and session.state == saved, "invalid edits do not mutate state")
	var discount: Dictionary = session.edit("place", 20, "shelter", POSE)
	_check(discount.state.budget == 9, "shielded shelter charges 3")
	_check(session.edit("remove", 20, "", POSE).state == saved, "new shelter cancel refunds 100%")
	_layout(session, true)
	_check(session.edit("place", 3, "battery", POSE).get("error") == "budget", "overspending rejected")
	_commit(session)
	var t2: Dictionary = session.snapshot(2)
	_check(session.edit("remove", 11, "", POSE).state.budget == 1, "confirmed battery refunds half")
	session.cancel_draft()
	_check(session.preview().state == t2 and t2.E == 28, "draft reset restores layout, budget and power exactly")
	session.edit("remove", 11, "", POSE)
	var t2_end := _commit(session, "normal")
	_numbers(t2_end, [10, 64, 24, 2], "battery removal clamps before use")
	_check("storage_reduced" in t2_end.causes, "storage clamp recorded")
	session.restore_turn(2)
	_check(session.state.E == 28 and Simulation.energy_cap(session.state) == 40, "rewind restores uncapped original power")
	var unsafe = Session.new(Scenario)
	unsafe.edit("place", 0, "generator", POSE)
	unsafe.edit("place", 11, "battery", POSE)
	_commit(unsafe)
	_commit(unsafe, "conserve")
	_commit(unsafe)
	var pre_alert: Dictionary = unsafe.snapshot(4)
	var safety := _commit(unsafe, "shelter")
	_check(safety.phase == "failed_safety" and safety.state_after.E == pre_alert.E and safety.state_after.O == pre_alert.O,
		"missing shelter stops before resource calculation")


func _scene_path() -> void:
	var game = Mission.instantiate()
	root.add_child(game)
	await physics_frame
	await physics_frame
	_check(game.player.sees_console(game.station.console), "console visible from 2 m spawn")
	var initial: Dictionary = game.session.state.duplicate(true)
	game._set_mode("explore")
	await physics_frame
	_check(game.session.state == initial, "walking clock does not advance logical state")
	game._set_mode("terminal")
	var t = game.terminal
	var p = game.player
	var first_pose := {"position": [0.43, 0.0, 19.8], "yaw": 0.15, "pitch": -0.11}
	p.apply_pose(first_pose)
	t._select_slot(0)
	t._place_selected()
	_check(game.station.get_node("FacilityWrappers/Slot00_generator") != null, "draft appears on matching 3D pad")
	t._advance_turn()
	t._advance_turn()
	_check(game.session.state.turn_id == 2 and game.session.result_at(2).is_empty(), "rapid duplicate UI advance counts once")
	await create_timer(0.44).timeout
	t._choose_event(0)
	t._advance_turn()
	await create_timer(0.44).timeout
	t._advance_turn()
	t._advance_turn()
	_check(game.session.state.turn_id == 4 and game.session.result_at(4).is_empty(),
		"rapid advance cannot skip a following turn")
	p.apply_pose(POSE)
	p.velocity = Vector3(3, 0, 0)
	game._restore(2)
	_check(p.global_position.is_equal_approx(Vector3(0.43, 0, 19.8)) and is_equal_approx(p.rotation.y, 0.15)
		and is_equal_approx(p.camera.rotation.x, -0.11), "scene restores original location and look")
	_check(p.velocity == Vector3.ZERO and not p.exploring and game.mode == "terminal" and t.visible,
		"restore zeros speed and keeps terminal input lock")
	game.session.current_history.snapshots["1"].player = {"position": [0.0, 0.0, 0.0], "yaw": 0.0, "pitch": 0.0}
	game._restore(1)
	_check(p.global_position == Rules.SPAWN and game.mode == "terminal", "colliding restored pose goes to safe spawn")
	game.queue_free()
	await process_frame
