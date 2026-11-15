extends RefCounted
## Reads stored snapshots/results only. Does not simulate or restore.
const UI = preload("res://scripts/ui/ui_style.gd")
const Rules = preload("res://scripts/simulation/scenario.gd")
const Simulation = preload("res://scripts/simulation/simulation.gd")
const Preview = preload("res://scripts/simulation/turn_preview.gd")

static func start_line(state: Dictionary) -> String:
	if state.is_empty(): return "No saved starting state"
	var farms: Array[String] = []
	for facility: Dictionary in state.get("facilities",[]):
		if facility.type == "greenhouse": farms.append("Pad %02d growth %d/3" % [facility.slot_id+1,facility.growth])
	var growth := "No greenhouse" if farms.is_empty() else "Growth " + ", ".join(farms)
	return "Saved turn start: Power %d/%d · Oxygen %d · Food %d · Tokens %d\n%s" % [state.E,Simulation.energy_cap(state),state.O,state.F,state.budget,growth]

static func candidates(session) -> Array[Dictionary]:
	var found: Array[Dictionary] = []
	var phase: String = session.state.phase
	if not phase.begins_with("failed_"): return found
	for turn in range(int(session.state.turn_id),0,-1):
		var start: Dictionary = session.snapshot(turn)
		if start.is_empty(): continue
		var evidence := ""
		if phase == "failed_power":
			if turn == 2: evidence = "You can choose a different fault response from this state."
			elif start.E > session.state.E: evidence = "This starting state has more stored power than the stopped result."
		elif phase == "failed_life_support":
			if start.F <= session.state.F: continue
			var farms := Simulation.count_kind(start,"greenhouse")
			var remaining := 3
			var growing_slot := -1
			for facility: Dictionary in start.facilities:
				if facility.type == "greenhouse" and (growing_slot < 0 or 3-int(facility.growth) < remaining):
					remaining = 3-int(facility.growth)
					growing_slot = facility.slot_id
			# Preparation margin only, not a simulation of future harvest/survival.
			if start.F < remaining * 6: continue
			if farms > 0: evidence = "The most mature greenhouse, pad %02d, needs %d more active turns to harvest." % [growing_slot+1,remaining]
			elif start.budget >= Rules.cost("greenhouse",0): evidence = "You can afford a greenhouse. It needs 3 active turns to harvest. Check for a free pad."
			if not evidence.is_empty(): evidence += "\nFood %d / use 6 per turn · Compared with %d meals as a search guide. Pauses or power loss may need more food; check earlier turns too." % [start.F,remaining]
		elif phase == "failed_safety":
			if Simulation.count_kind(start,"shelter") > 0: evidence = "This starting state has a shelter. Check your event response too."
			else:
				for slot in Rules.SLOT_COUNT:
					if Simulation.facility_at(start,slot).is_empty() and start.budget >= Rules.cost("shelter",slot):
						evidence = "This starting state has a free pad and enough tokens for a shelter."
						break
		if evidence.is_empty(): continue
		found.append({"turn":turn,"text":"Inspect start of T%d\n%s\n%s" % [turn,evidence,start_line(start)]})
		if found.size() == 2: break
	return found

static func side(session, turn: int, previous: bool) -> String:
	var history: Dictionary = session.previous_attempt if previous else session.current_history
	var attempt: String = str(session.previous_attempt.get("attempt_id","None")) if previous else str(session.attempt_id)
	var title := "%s · Attempt %s · T%d" % ["Previous attempt" if previous else "Current attempt",attempt,turn]
	var result: Dictionary = history.get("results",{}).get(str(turn),{})
	var start: Dictionary = history.get("snapshots",{}).get(str(turn),{})
	if result.is_empty(): return title + " · No result\n" + start_line(start) + "\nThis turn has no recorded result yet."
	var choice: String = result.event_choice
	if turn == 3: choice = result.state_after.get("fault_mode","")
	var decision := Preview.choice_label(choice) if not choice.is_empty() else "No event choice"
	var decision_title := "T2 choice (continues this turn): " if turn == 3 else "Recorded choice: "
	var after: Dictionary = result.state_after
	var ending := "Recorded end: Power %d/%d · Oxygen %d · Food %d" % [after.E,Simulation.energy_cap(after),after.O,after.F]
	return title + " · " + UI.phase_text(result.phase) + "\n" + start_line(start) + "\n" + decision_title + decision + "\n" + ending + "\nActions: " + Preview.flow_lines(start,result)

static func slots(state: Dictionary) -> Dictionary:
	var result := {}
	for facility: Dictionary in state.get("facilities",[]): result[int(facility.slot_id)] = str(facility.type)
	return result

static func changes(session, turn: int) -> String:
	var compared: Dictionary = session.compare_turn(turn)
	if compared.is_empty(): return "Both attempts need a recorded result for this turn. Missing results are not replaced with forecasts."
	var old: Dictionary = compared.previous
	var current: Dictionary = compared.current
	var before: Dictionary = session.previous_attempt.get("snapshots",{}).get(str(turn),{})
	var now: Dictionary = session.snapshot(turn)
	var lines: Array[String] = ["Recorded change (current − previous): Power %s · Oxygen %s · Food %s" % [UI.signed_delta(compared.delta.E),UI.signed_delta(compared.delta.O),UI.signed_delta(compared.delta.F)]]
	var old_choice: String = old.state_after.get("fault_mode","") if turn == 3 else old.event_choice
	var new_choice: String = current.state_after.get("fault_mode","") if turn == 3 else current.event_choice
	if old_choice != new_choice: lines.append("Choice changed: %s → %s" % [Preview.choice_label(old_choice),Preview.choice_label(new_choice)])
	var old_slots := slots(old.state_after)
	var new_slots := slots(current.state_after)
	var layout: Array[String] = []
	for slot in Rules.SLOT_COUNT:
		if old_slots.get(slot,"") != new_slots.get(slot,""):
			layout.append("Pad %02d: %s → %s" % [slot+1, UI.name_for(old_slots[slot]) if old_slots.has(slot) else "Empty pad",UI.name_for(new_slots[slot]) if new_slots.has(slot) else "Empty pad"])
	if not layout.is_empty(): lines.append("Layout changed: " + ", ".join(layout))
	if not before.is_empty() and not now.is_empty():
		var different: Array[String] = []
		for key in ["E","O","F","budget"]:
			if before[key] != now[key]: different.append({"E":"Power","O":"Oxygen","F":"Food","budget":"Tokens"}[key] + " %d → %d" % [before[key],now[key]])
		if not different.is_empty(): lines.append("Starting state changed: " + " · ".join(different))
		var old_growth := growth(before)
		var new_growth := growth(now)
		if old_growth != new_growth: lines.append("Starting crop growth differs. Compare both starting states.")
	else: lines.append("There is not enough starting-state data to narrow down the cause.")
	if old_choice == new_choice and layout.is_empty(): lines.append("The response and layout match. Compare earlier resources and crop growth too.")
	lines.append("Several starting conditions and choices can affect the result. This difference alone does not prove one cause.")
	return "\n".join(lines)

static func growth(state: Dictionary) -> Dictionary:
	var result := {}
	for facility: Dictionary in state.get("facilities",[]):
		if facility.type == "greenhouse": result[facility.slot_id] = facility.growth
	return result
