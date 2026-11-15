extends RefCounted
## Read-only presentation of the CURRENT turn. Reuses the authoritative calculator.
const Simulation = preload("res://scripts/simulation/simulation.gd")
const Rules = preload("res://scripts/simulation/scenario.gd")

static func choices_for(turn: int) -> Array[String]:
	match turn:
		2: return ["normal", "conserve"]
		4: return ["shelter", "continue"]
		5: return ["acknowledge"]
	return [""]

static func choice_label(choice: String) -> String:
	match choice:
		"normal": return "Keep growing"
		"conserve": return "Save power"
		"shelter": return "Take shelter"
		"continue": return "Continue without shelter"
		"acknowledge": return "Acknowledge supply delay"
	return "Current layout"

static func inspect(snapshot: Dictionary, draft: Array, choice: String, pose: Dictionary = {},
		advice_request: bool = false) -> Dictionary:
	var source := snapshot.duplicate(true)
	var edits := draft.duplicate(true)
	var valid := Simulation.validate_draft(source, edits, pose.duplicate(true))
	if valid.has("error"): return valid
	var layout: Dictionary = valid.state
	var capacity := Simulation.energy_cap(layout)
	var output := {"current_energy":source.E, "current_capacity":Simulation.energy_cap(source),
		"layout_capacity":capacity, "spill":maxi(0, source.E - capacity), "layout":layout,
		"conditional":false, "outcomes":[], "communication_cost":1 if advice_request else 0,
		"communication_delay":Simulation.communication_delay(source), "weather_profile":source.get("weather", {}).duplicate(true)}
	if source.phase != "planning": return output
	var choices := choices_for(source.turn_id)
	output.conditional = choice.is_empty() and choices != [""]
	if not output.conditional: choices = [choice]
	for option in choices:
		var result := Simulation.simulate_turn(source.duplicate(true), edits.duplicate(true), option, pose.duplicate(true), advice_request)
		output.outcomes.append({"choice":option,"result":result,
			"available":option != "shelter" or Simulation.count_kind(layout,"shelter") > 0})
	return output

static func flow_lines(before: Dictionary, result: Dictionary) -> String:
	if result.has("error"): return "Cannot preview the current choices."
	var skipped: Array = result.get("not_applied_steps", [])
	var stats: Dictionary = result.get("stats", {})
	var after: Dictionary = result.state_after
	var lines: Array[String] = []
	if int(result.get("communication_cost", 0)) > 0:
		var reply_turn: int = after.communication.pending.get("reply_turn", int(result.turn_id) + Simulation.communication_delay(after))
		lines.append("Advice costs 1 power · Reply after %d turns, when T%d ends. (Simulated advice delay)" % [Simulation.communication_delay(after), reply_turn])
	if "advice_received" in result.get("causes", []):
		lines.append("Reply from Earth: " + str(after.communication.message))
	if skipped.has("power") or stats.is_empty():
		lines.append("Power, oxygen, crops, food and supplies: stopped before calculation")
		return "\n".join(lines)
	var usage := "needed" if result.phase == "failed_power" else "used"
	lines.append("Power made %d · Power %s %d · Final %d/%d" % [stats.generation,usage,stats.demand,after.E,Simulation.energy_cap(after)])
	if int(stats.get("protection_energy", 0)) > 0:
		lines.append("Demand includes %d protection power for this training event." % stats.protection_energy)
	if skipped.has("oxygen") or result.phase == "failed_power":
		lines.append("Oxygen, crops, food and supplies: stopped before calculation")
		return "\n".join(lines)
	if before.has("O"):
		var oxygen_change: int = after.O - int(before.O)
		lines.append("Oxygen made 8 · Used 6 · Change %s%d · Final %d" % ["+" if oxygen_change >= 0 else "",oxygen_change,after.O])
		if oxygen_change < 2: lines.append("Oxygen caps at 100. Only the actual gain is counted.")
	else:
		lines.append("Oxygen made 8 · Used 6 · Final %d (no start record)" % after.O)
	lines.append("Food harvested %d · Delivered %d · Used 6 · Final %d" % [stats.harvest,stats.supply,after.F])
	return "\n".join(lines)

static func growth_lines(layout: Dictionary, choice: String) -> String:
	var lines: Array[String] = []
	var turn: int = layout.turn_id
	var mode: String = choice if turn == 2 else layout.get("fault_mode", "")
	var paused := (turn == 4 and choice == "shelter") or (turn in [2,3] and mode == "conserve")
	for facility in layout.facilities:
		if facility.type != "greenhouse": continue
		var remaining: int = 3 - int(facility.growth)
		var status := "Crops paused this turn · No growth" if paused else "One growth step when active"
		if turn == 2 and choice.is_empty(): status = "Your choice runs or pauses crops"
		if turn == 4:
			if choice.is_empty(): status = "Your choice pauses crops for shelter or keeps them running"
			elif choice == "continue" and Simulation.shelter_required(layout): status = "Skipping required shelter stops the mission before crop calculation"
		lines.append("Greenhouse %02d: %d more active turns for +18 food · %s" % [facility.slot_id + 1,remaining,status])
	if lines.is_empty(): lines.append("No greenhouse · Each harvest gives 18 food after 3 active turns.")
	lines.append("Crops are not calculated if power or safety stops the mission first.")
	return "\n".join(lines)

static func current_effect(layout: Dictionary, choice: String) -> String:
	var turn: int = layout.turn_id
	if turn == 2:
		var action := "Your response decides whether crops run."
		if choice == "conserve": action = "Save power: crops and growth pause for both turns."
		elif choice == "normal": action = "Keep growing: crops run for both turns if power is available."
		return "Power outage: this turn and the next. " + action
	if turn == 3:
		return "Power outage: ends after this turn. " + ("Saving power: crops and growth paused." if layout.fault_mode == "conserve" else "Keep growing: crops run if power is available.")
	if turn == 4:
		if not layout.has("weather"): return "Sheltering pauses crops this turn. Skipping shelter stops the mission before resources are calculated."
		var protection: int = layout.weather.protection_energy
		var condition := "Skipping shelter stops the mission before resources are calculated." if Simulation.shelter_required(layout) else "At this watch level you may keep growing without sheltering."
		return "Data-selected training rule: shelter uses %d extra power and pauses crop growth. " % protection + condition
	if turn >= 5 and not layout.supply_delivered:
		return "Scheduled supply: 12 food arrives once in T7. It will not arrive if the mission stops first."
	if turn == 7 and layout.supply_delivered: return "Food supplies have already arrived. They are delivered only once."
	return "Preview uses known conditions for this turn only."
