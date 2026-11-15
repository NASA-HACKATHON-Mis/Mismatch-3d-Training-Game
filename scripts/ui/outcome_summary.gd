extends RefCounted
## Presentation only: current branch results, never previous attempts or predictions.
const UI = preload("res://scripts/ui/ui_style.gd")
const Preview = preload("res://scripts/simulation/turn_preview.gd")

static func ended(state: Dictionary) -> bool:
	return state.phase == "completed" or str(state.phase).begins_with("failed_")

static func heading(state: Dictionary) -> String:
	if state.phase == "completed": return "7-turn mission complete!"
	var cause: String = {"failed_power":"Out of power","failed_life_support":"Life support depleted","failed_safety":"Safety requirement missed"}.get(state.phase, "")
	return "T%d mission stopped · %s" % [state.turn_id, cause]

static func reason(result: Dictionary) -> String:
	if result.is_empty(): return ""
	var after: Dictionary = result.state_after
	match result.phase:
		"completed": return "You managed your base for 7 turns! Review your choices and resources."
		"failed_power": return "Power ran out. This turn needed %d power; reaching 0 stopped the mission.\nOxygen, growth, food and supply were not calculated." % result.stats.demand
		"failed_safety": return "This training alert requires shelter. Build a shelter and choose Shelter to continue.\nThis turn stopped before power, oxygen, growth, food or supply calculations."
		"failed_life_support":
			var depleted: Array[String] = []
			if after.O <= 0: depleted.append("Oxygen")
			if after.F <= 0: depleted.append("Food")
			return "%s reached 0 and life support stopped. This turn's resource calculation finished." % "·".join(depleted)
	return ""

static func history_lines(session) -> String:
	var lines: Array[String] = []
	for turn in range(1,8):
		var result: Dictionary = session.result_at(turn)
		if result.is_empty(): continue
		var after: Dictionary = result.state_after
		var choice: String = result.event_choice
		var decision := " · Choice: " + Preview.choice_label(choice) if not choice.is_empty() else ""
		lines.append("T%d · %s%s · Power %d / Oxygen %d / Food %d" % [turn,UI.phase_text(result.phase),decision,after.E,after.O,after.F])
	return "\n".join(lines)
