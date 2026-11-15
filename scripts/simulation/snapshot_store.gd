class_name LunarSession
extends RefCounted
## One current attempt and one archived comparison attempt.

const Simulation = preload("res://scripts/simulation/simulation.gd")

var attempt_id := 1
var current_history := {"snapshots": {}, "results": {}}
var previous_attempt := {}
var committed_command_ids := {}
var draft: Array = []
var advice_requested := false
var state: Dictionary
var _committing := false


func _init(scenario: Resource) -> void:
	state = scenario.initial_state()
	_save_snapshot()


func _save_snapshot() -> void:
	current_history.snapshots[str(state.turn_id)] = state.duplicate(true)


func snapshot(turn_id: int) -> Dictionary:
	return current_history.snapshots.get(str(turn_id), {}).duplicate(true)


func result_at(turn_id: int) -> Dictionary:
	return current_history.results.get(str(turn_id), {}).duplicate(true)


func preview(pose: Dictionary = {}) -> Dictionary:
	if state.phase != "planning":
		return {"state": state.duplicate(true)}
	return Simulation.validate_draft(snapshot(state.turn_id), draft, pose)


func edit(action: String, slot_id: int, kind: String, pose: Dictionary) -> Dictionary:
	if state.phase != "planning" or _committing:
		return {"error": "turn_closed"}
	var candidate := draft.duplicate(true)
	var cancelled := false
	if action == "remove":
		for i in range(candidate.size() - 1, -1, -1):
			var op: Dictionary = candidate[i]
			if op.action == "place" and op.slot_id == slot_id:
				candidate.remove_at(i)
				cancelled = true
				break
	if not cancelled:
		candidate.append({"action": action, "slot_id": slot_id, "type": kind})
	var validated := Simulation.validate_draft(snapshot(state.turn_id), candidate, pose)
	if not validated.has("error"):
		draft = candidate
	return validated


func cancel_draft() -> void:
	if state.phase == "planning" and not _committing:
		draft.clear()
		advice_requested = false


func set_advice_request(enabled: bool) -> Dictionary:
	if _committing or state.phase != "planning": return {"error": "turn_closed"}
	if enabled:
		var request_error := Simulation.advice_request_error(state)
		if not request_error.is_empty(): return {"error": request_error}
	advice_requested = enabled
	return {"requested": advice_requested}


func commit_turn(command: Dictionary, pose: Dictionary, input_mode: String) -> Dictionary:
	if command.get("attempt_id") != attempt_id:
		return {"error": "old_attempt"}
	if not command.get("command_id") is int or command.command_id < 1 or not command.get("turn_id") is int:
		return {"error": "invalid_command"}
	var key := str(command.get("turn_id")) + ":" + str(command.get("command_id"))
	if committed_command_ids.has(key):
		return committed_command_ids[key].duplicate(true)
	if command.get("turn_id") != state.turn_id:
		return {"error": "wrong_turn"}
	if _committing or state.phase != "planning":
		return {"error": "turn_closed"}
	if not command.get("draft") is Array or not command.get("event_choice") is String:
		return {"error": "invalid_draft"}
	var request: Variant = command.get("advice_request", advice_requested)
	if not request is bool: return {"error": "invalid_advice_request"}
	_committing = true
	var result := Simulation.simulate_turn(snapshot(state.turn_id), command.draft, command.event_choice, pose, request)
	if result.has("error"):
		_committing = false
		return result
	result.command_id = command.command_id
	result.state_after.player = pose.duplicate(true)
	result.state_after.input_mode = input_mode
	current_history.results[str(state.turn_id)] = result.duplicate(true)
	committed_command_ids[key] = result.duplicate(true)
	state = result.state_after.duplicate(true)
	draft.clear()
	advice_requested = false
	if state.phase == "turn_complete":
		state.turn_id += 1
		state.phase = "planning"
		_save_snapshot()
	_committing = false
	return result.duplicate(true)


func restore_turn(turn_id: int) -> Dictionary:
	if _committing:
		return {"error": "turn_closed"}
	var start := snapshot(turn_id)
	if start.is_empty():
		return {"error": "unknown_turn"}
	previous_attempt = current_history.duplicate(true)
	previous_attempt.attempt_id = attempt_id
	attempt_id += 1
	committed_command_ids.clear()
	draft.clear()
	advice_requested = false
	state = start.duplicate(true)
	state.input_mode = "terminal"
	# Earlier turns form the common history. Only this turn and later are replayed.
	for key: String in current_history.snapshots.keys():
		if int(key) > turn_id:
			current_history.snapshots.erase(key)
	for key: String in current_history.results.keys():
		if int(key) >= turn_id:
			current_history.results.erase(key)
	return {"state": state.duplicate(true)}


func compare_turn(turn_id: int) -> Dictionary:
	var current := result_at(turn_id)
	var old: Dictionary = previous_attempt.get("results", {}).get(str(turn_id), {})
	if current.is_empty() or old.is_empty():
		return {}
	return {"turn_id": turn_id, "previous": old.duplicate(true), "current": current,
		"delta": {"E": current.state_after.E - old.state_after.E,
			"O": current.state_after.O - old.state_after.O,
			"F": current.state_after.F - old.state_after.F}}
