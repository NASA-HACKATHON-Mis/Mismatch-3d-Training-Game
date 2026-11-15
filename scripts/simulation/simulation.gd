class_name LunarSimulation
extends RefCounted
## Pure draft validation and turn calculation. No scene or clock access.

const Rules = preload("res://scripts/simulation/scenario.gd")


static func facility_at(state: Dictionary, slot_id: int) -> Dictionary:
	for facility: Dictionary in state.facilities:
		if facility.slot_id == slot_id:
			return facility
	return {}


static func count_kind(state: Dictionary, kind: String) -> int:
	var count := 0
	for facility: Dictionary in state.facilities:
		if facility.type == kind:
			count += 1
	return count


static func energy_cap(state: Dictionary) -> int:
	return 20 + 20 * count_kind(state, "battery")


static func validate_draft(snapshot: Dictionary, draft: Array, pose: Dictionary = {}) -> Dictionary:
	var state := snapshot.duplicate(true)
	for raw: Variant in draft:
		if not raw is Dictionary:
			return {"error": "invalid_draft"}
		var op: Dictionary = raw
		var slot: Variant = op.get("slot_id")
		if not slot is int or slot < 0 or slot >= Rules.SLOT_COUNT:
			return {"error": "invalid_slot"}
		var existing := facility_at(state, slot)
		match op.get("action"):
			"place":
				var kind: Variant = op.get("type")
				if not kind is String or not Rules.BUILDABLE.has(kind):
					return {"error": "invalid_facility"}
				if not existing.is_empty():
					return {"error": "occupied"}
				var paid := Rules.cost(kind, slot)
				if state.budget < paid:
					return {"error": "budget"}
				if not pose.is_empty() and Rules.facility_overlaps_player(kind, slot, pose):
					return {"error": "player_overlap"}
				state.grid[slot] = state.next_instance_id
				state.facilities.append({"instance_id": state.next_instance_id, "type": kind,
					"slot_id": slot, "actual_paid_cost": paid, "growth": 0})
				state.next_instance_id += 1
				state.budget -= paid
			"remove":
				if existing.is_empty():
					return {"error": "empty"}
				if existing.type == "habitat":
					return {"error": "fixed_habitat"}
				# New placements are cancelled by removing their place operation.
				if existing.instance_id >= snapshot.next_instance_id:
					return {"error": "invalid_draft"}
				state.facilities.erase(existing)
				state.grid[slot] = null
				@warning_ignore("integer_division")
				state.budget += int(existing.actual_paid_cost) / 2
			_:
				return {"error": "invalid_draft"}
	var habitat := facility_at(state, Rules.HABITAT_SLOT)
	if habitat.is_empty() or habitat.type != "habitat" or count_kind(state, "habitat") != 1:
		return {"error": "fixed_habitat"}
	return {"state": state}


static func communication_delay(state: Dictionary) -> int:
	return int(state.get("weather", {}).get("communication_delay", 1))


static func shelter_required(state: Dictionary) -> bool:
	return bool(state.get("weather", {}).get("shelter_required", true))


static func advice_request_error(state: Dictionary) -> String:
	if state.phase != "planning": return "turn_closed"
	if int(state.turn_id) + communication_delay(state) > 7: return "advice_too_late"
	if not state.get("communication", {}).get("pending", {}).is_empty(): return "advice_pending"
	if int(state.E) < 1: return "advice_power"
	return ""


static func _advice_for(state: Dictionary) -> String:
	if state.turn_id <= 3:
		return "Stored power helps during an outage. Pause your greenhouses if power is low."
	if shelter_required(state) and count_kind(state, "shelter") == 0 and state.turn_id <= 4:
		return "Build a shelter before an alert. Greenhouses pause while the crew shelters."
	if state.F <= 24:
		return "Check your food. Greenhouses need power and three active turns before harvest."
	return "Check the next-turn preview and facility costs. Compare before and after each change."


static func simulate_turn(snapshot: Dictionary, draft: Array, event_choice: String,
		pose: Dictionary = {}, advice_request: bool = false) -> Dictionary:
	if snapshot.phase != "planning":
		return {"error": "turn_closed"}
	var turn: int = snapshot.turn_id
	var valid := validate_draft(snapshot, draft, pose)
	if valid.has("error"):
		return valid
	if advice_request:
		var request_error := advice_request_error(valid.state)
		if not request_error.is_empty(): return {"error": request_error}
	if turn == 2 and event_choice not in ["normal", "conserve"]:
		return {"error": "choose_fault"}
	if turn == 4 and event_choice not in ["shelter", "continue"]:
		return {"error": "choose_weather"}
	if turn == 5 and event_choice != "acknowledge":
		return {"error": "acknowledge_delay"}
	if turn not in [2, 4, 5] and not event_choice.is_empty():
		return {"error": "invalid_choice"}

	var state: Dictionary = valid.state
	var causes: Array[String] = []
	var applied: Array[String] = ["construction", "event"]
	var remaining: Array[String] = ["power", "oxygen", "growth", "supply", "food"]
	var cap := energy_cap(state)
	var generation := 0
	var harvest := 0
	var supply := 0
	var protection_energy := 0
	var farms: Array[Dictionary] = []
	# A larger cap never adds charge. Removing storage can spill saved power.
	if state.E > cap:
		state.E = cap
		causes.append("storage_reduced")
	# Communication is committed once with this turn, before event/power checks.
	# A failed turn may still contain a paid request or a received reply; rewind
	# restores those facts together with all resources.
	var communication: Dictionary = state.get("communication", {
		"pending": {}, "message": "", "response_turn": -1}).duplicate(true)
	var pending: Dictionary = communication.get("pending", {})
	if not pending.is_empty() and int(pending.reply_turn) <= turn:
		communication.message = _advice_for(state)
		communication.response_turn = turn
		communication.pending = {}
		causes.append("advice_received")
	if advice_request:
		state.E -= 1
		communication.pending = {"requested_turn": turn, "reply_turn": turn + communication_delay(state)}
		communication.message = ""
		communication.response_turn = -1
		causes.append("advice_requested")
	if advice_request or causes.has("advice_received"): applied.append("communication")
	state.communication = communication

	if turn == 2:
		state.fault_mode = event_choice
		state.event_applied["2"] = event_choice
	if turn == 4:
		state.event_applied["4"] = event_choice
		if (event_choice == "shelter" and count_kind(state, "shelter") == 0) or (event_choice != "shelter" and shelter_required(state)):
			state.phase = "failed_safety"
			causes.append("unsafe_weather")
			return _result(snapshot, state, event_choice, causes, applied, remaining, {})
		if event_choice == "shelter":
			causes.append("sheltered")
			protection_energy = int(state.get("weather", {}).get("protection_energy", 0))
			if protection_energy > 0: causes.append("weather_protection")
		else:
			causes.append("weather_watch_continued")
	if turn == 5:
		state.event_applied["5"] = event_choice
		causes.append("supply_delayed")

	var fault := turn == 2 or turn == 3
	var stop_farms: bool = (turn == 4 and event_choice == "shelter") or (fault and state.fault_mode == "conserve")
	if fault:
		causes.append("generators_offline")
	if stop_farms:
		causes.append("farms_paused")
	for facility: Dictionary in state.facilities:
		if facility.type == "generator" and not fault:
			generation += 18 if Rules.SUNLIT.has(facility.slot_id) else 12
		elif facility.type == "greenhouse" and not stop_farms:
			farms.append(facility)
	var demand := 6 + 4 * farms.size() + protection_energy
	var available: int = state.E + generation
	state.E = mini(cap, maxi(0, available - demand))
	applied.append("power")
	remaining.pop_front()
	var stats := {"generation": generation, "demand": demand, "harvest": 0, "supply": 0}
	if state.has("weather"): stats.protection_energy = protection_energy
	if available <= demand:
		state.phase = "failed_power"
		causes.append("power_depleted")
		return _result(snapshot, state, event_choice, causes, applied, remaining, stats)
	state.O = mini(100, state.O + 8 - 6)
	for farm: Dictionary in farms:
		farm.growth += 1
		if farm.growth == 3:
			harvest += 18
			farm.growth = 0
	if harvest > 0:
		causes.append("harvest")
	if turn == 7 and not state.supply_delivered:
		supply = 12
		state.supply_delivered = true
		causes.append("supply_arrived")
	state.F = clampi(state.F + harvest + supply - 6, 0, 100)
	applied.append_array(remaining)
	remaining.clear()
	stats.harvest = harvest
	stats.supply = supply
	if state.O <= 0 or state.F <= 0:
		state.O = maxi(0, state.O)
		state.phase = "failed_life_support"
		causes.append("life_support_depleted")
	else:
		state.mission_progress = turn
		state.phase = "completed" if turn == 7 else "turn_complete"
	return _result(snapshot, state, event_choice, causes, applied, remaining, stats)


static func _result(before: Dictionary, after: Dictionary, choice: String, causes: Array[String],
		applied: Array[String], remaining: Array[String], stats: Dictionary) -> Dictionary:
	return {
		"turn_id": before.turn_id,
		"phase": after.phase,
		"state_after": after,
		"delta": {"E": after.E - before.E, "O": after.O - before.O, "F": after.F - before.F},
		"causes": causes,
		"applied_steps": applied,
		"not_applied_steps": remaining,
		"stats": stats,
		"event_choice": choice,
		"communication_cost": 1 if causes.has("advice_requested") else 0,
		"weather_profile": after.get("weather", {}).duplicate(true),
	}
