extends SceneTree
## Commit-only communication, delayed advice, previews and rewind invariants.

const Scenario = preload("res://resources/scenarios/lunar_training.tres")
const Simulation = preload("res://scripts/simulation/simulation.gd")
const Session = preload("res://scripts/simulation/snapshot_store.gd")
const Preview = preload("res://scripts/simulation/turn_preview.gd")
const POSE := {"position": [0.0, 0.0, 20.0], "yaw": 0.0, "pitch": 0.0}
var _checks := 0
var _failures := 0


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	_request_and_rewind()
	_guards_and_failures()
	_preview_and_final_turn()
	print("FEED-COMMS: %d checks, %d failures" % [_checks, _failures])
	quit(1 if _failures else 0)


func _check(ok: bool, context: String) -> void:
	_checks += 1
	if not ok:
		_failures += 1
		push_error(context)


func _command(session, choice := "", id := 1) -> Dictionary:
	return {"attempt_id": session.attempt_id, "turn_id": session.state.turn_id,
		"command_id": id, "draft": session.draft.duplicate(true), "event_choice": choice}


func _request_and_rewind() -> void:
	var session = Session.new(Scenario)
	var original: Dictionary = session.state.duplicate(true)
	_check(original.rule_version == "0.3", "communication uses rule version 0.3")
	_check(original.communication == {"pending": {}, "message": "", "response_turn": -1}, "empty initial communication")
	_check(session.set_advice_request(true) == {"requested": true}, "request can be selected")
	_check(session.set_advice_request(true) == {"requested": true}, "selecting twice remains one request")
	_check(session.state == original and session.snapshot(1) == original, "selecting costs nothing and keeps snapshot immutable")
	_check(session.set_advice_request(false) == {"requested": false}, "request can be cancelled")
	_check(session.state.E == 20 and not session.advice_requested, "cancel costs nothing")
	session.set_advice_request(true)
	session.edit("place", 0, "generator", POSE)
	session.cancel_draft()
	_check(not session.advice_requested and session.draft.is_empty() and session.state == original, "cancel draft also cancels request")
	session.set_advice_request(true)
	var command := _command(session)
	var requested: Dictionary = session.commit_turn(command, POSE, "terminal")
	_check(requested.communication_cost == 1 and requested.state_after.E == 13, "commit deducts request 1 and normal demand 6")
	_check(requested.state_after.communication.pending == {"requested_turn": 1, "reply_turn": 2}, "reply is scheduled for next turn")
	_check(requested.state_after.communication.message.is_empty(), "no immediate reply")
	_check(not session.advice_requested, "successful commit clears draft toggle")
	var current: Dictionary = session.state.duplicate(true)
	_check(session.commit_turn(command, POSE, "terminal") == requested and session.state == current, "duplicate request commit cannot charge twice")
	_check(session.set_advice_request(true).get("error") == "advice_pending", "only one pending request")
	var rejected := _command(session, "conserve")
	rejected.advice_request = true
	_check(session.commit_turn(rejected, POSE, "terminal").get("error") == "advice_pending" and session.state == current, "direct command cannot bypass pending guard")
	var response_command := _command(session, "conserve")
	var response: Dictionary = session.commit_turn(response_command, POSE, "terminal")
	_check(response.state_after.E == 7 and response.state_after.O == 64 and response.state_after.F == 24, "reply adds no free resources or extra cost")
	_check(response.communication_cost == 0 and response.causes.has("advice_received"), "next commit delivers reply")
	_check(response.state_after.communication.pending.is_empty() and response.state_after.communication.response_turn == 2
		and not response.state_after.communication.message.is_empty(), "reply has message and turn with no pending request")
	current = session.state.duplicate(true)
	_check(session.commit_turn(response_command, POSE, "terminal") == response and session.state == current, "duplicate response commit changes nothing")
	var response_text: String = current.communication.message
	var next: Dictionary = session.commit_turn(_command(session), POSE, "terminal")
	_check(not next.causes.has("advice_received") and next.state_after.communication.message == response_text, "reply persists without repeated delivery")
	session.restore_turn(2)
	_check(session.state.communication.pending == {"requested_turn": 1, "reply_turn": 2}
		and session.state.communication.message.is_empty() and not session.advice_requested, "rewind restores pending request")
	var replay: Dictionary = session.commit_turn(_command(session, "conserve"), POSE, "terminal")
	_check(replay.state_after == response.state_after and replay.causes == response.causes, "same replay delivers identical advice and resources")
	session.set_advice_request(true)
	session.restore_turn(1)
	_check(session.state.communication == original.communication and session.state.E == 20 and not session.advice_requested, "rewind before request removes its cost, reply and draft toggle")
	var explicit_no := _command(session)
	session.set_advice_request(true)
	explicit_no.advice_request = false
	var no_request: Dictionary = session.commit_turn(explicit_no, POSE, "terminal")
	_check(no_request.communication_cost == 0 and no_request.state_after.E == 14, "explicit command false overrides session toggle")


func _guards_and_failures() -> void:
	var session = Session.new(Scenario)
	var invalid := _command(session)
	invalid.advice_request = "yes"
	_check(session.commit_turn(invalid, POSE, "terminal").get("error") == "invalid_advice_request", "non-boolean request is rejected")
	_check(session.state.E == 20 and session.current_history.results.is_empty(), "invalid request leaves resources and history intact")
	var source: Dictionary = Scenario.initial_state()
	source.E = 0
	_check(Simulation.simulate_turn(source, [], "", POSE, true).get("error") == "advice_power", "request requires one stored energy")
	source.E = 1
	var last_energy := Simulation.simulate_turn(source, [], "", POSE, true)
	_check(last_energy.phase == "failed_power" and last_energy.state_after.E == 0 and last_energy.communication_cost == 1, "spending last energy uses normal power failure")
	_check(last_energy.state_after.O == source.O and last_energy.state_after.F == source.F, "failed power skips later resource steps")
	_check(source.E == 1 and source.communication.pending.is_empty(), "pure simulation does not mutate source")
	source.turn_id = 4
	source.E = 20
	var unsafe := Simulation.simulate_turn(source, [], "continue", POSE, true)
	_check(unsafe.phase == "failed_safety" and unsafe.state_after.E == 19 and unsafe.communication_cost == 1, "request is committed once even if safety fails before normal power use")
	_check(Simulation.advice_request_error(unsafe.state_after) == "turn_closed", "failed turn cannot request more advice")
	source.turn_id = 2
	_check(Simulation.simulate_turn(source, [], "", POSE, true).get("error") == "choose_fault" and source.E == 20, "invalid turn choice never charges request")


func _preview_and_final_turn() -> void:
	var source: Dictionary = Scenario.initial_state()
	var saved := source.duplicate(true)
	var baseline := Preview.inspect(source, [], "", POSE)
	var preview := Preview.inspect(source, [], "", POSE, true)
	var actual := Simulation.simulate_turn(source, [], "", POSE, true)
	_check(preview.outcomes[0].result == actual and source == saved, "preview includes exact communication cost without mutation")
	_check(baseline.outcomes[0].result.state_after.E - actual.state_after.E == 1, "request projection reflects one energy")
	_check(Preview.flow_lines(source, actual).contains("조언 요청 전력 1"), "calculation explanation includes communication cost")
	source.turn_id = 2
	var conditional := Preview.inspect(source, [], "", POSE, true)
	_check(conditional.conditional and conditional.outcomes.size() == 2, "request supports conditional event preview")
	for outcome: Dictionary in conditional.outcomes:
		_check(outcome.result == Simulation.simulate_turn(source, [], outcome.choice, POSE, true), "every conditional outcome includes request cost")
	source.turn_id = 6
	var late := Simulation.simulate_turn(source, [], "", POSE, true)
	var last: Dictionary = late.state_after.duplicate(true)
	last.turn_id = 7
	last.phase = "planning"
	var final := Simulation.simulate_turn(last, [], "", POSE)
	_check(final.phase == "completed" and final.causes.has("advice_received") and final.state_after.communication.response_turn == 7, "T6 request is received on T7 completion")
	_check(final.communication_cost == 0 and final.stats.supply == 12, "T7 reply adds no extra power cost or supply")
	last.communication.pending = {}
	_check(Simulation.simulate_turn(last, [], "", POSE, true).get("error") == "advice_too_late", "T7 cannot start a request beyond scenario")
	var late_session = Session.new(Scenario)
	late_session.state = last
	late_session.current_history.snapshots["7"] = last.duplicate(true)
	_check(late_session.set_advice_request(true).get("error") == "advice_too_late" and not late_session.advice_requested, "session blocks T7 request toggle")
