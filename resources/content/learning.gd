extends RefCounted
## Text and offline sources for the learning panels. Simulation stays separate.

const DONKI_RECORD := "res://research/donki-sample.json"
const DONKI_METADATA := "res://research/donki-sample.metadata.json"
const CSA_ARTICLE := "https://www.asc-csa.gc.ca/eng/sciences/food-production/growing-healthy-food-in-space-and-remote-areas.asp"

const FACILITIES := {
	"habitat": "Uses 6 power to make 8 oxygen each turn. The crew uses 6 oxygen and 6 food.",
	"generator": "Makes power each turn: 18 on a sun pad, 12 elsewhere. Produces nothing during a fault.",
	"battery": "Adds 20 power storage. Building a battery does not create power.",
	"greenhouse": "Uses 4 power each active turn. Harvest 18 food after 3 active turns. Growth pauses when inactive.",
	"shelter": "Protects the crew during space weather alerts. Building on a shield pad saves 1 token."
}

const EVENTS := {
	2: ["Solar array fault · T2–T3",
		"Power generation is 0. Keep farming to grow food, or pause farming to save power."],
	4: ["Space weather alert · T4",
		"Follow the NASA-based training alert. Sheltering pauses farming. When shelter is required, continuing without it stops the mission."],
	5: ["Food supply delay · T5",
		"A one-time delivery of 12 food arrives at T7. Use stored food and greenhouse harvests until then."]
}


static func archived_flare() -> Dictionary:
	var records = JSON.parse_string(FileAccess.get_file_as_string(DONKI_RECORD))
	var meta = JSON.parse_string(FileAccess.get_file_as_string(DONKI_METADATA))
	if not records is Array or not meta is Dictionary:
		return {}
	for record in records:
		if record is Dictionary and record.get("flrID") == meta.get("selected_event_id"):
			return {"record": record, "metadata": meta}
	return {}


static func utc_label(value: String) -> String:
	return value.trim_suffix("Z").replace("T", " ") + " UTC"


static func attempt_note(result: Dictionary) -> String:
	var choice: String = result.get("event_choice", "")
	var turn: int = result.get("turn_id", 0)
	var labels: Array[String] = []
	match choice:
		"normal": labels.append("Keep farming")
		"conserve": labels.append("Save power")
		"shelter": labels.append("Shelter")
		"continue": labels.append("Continue without shelter")
		"acknowledge": labels.append("Acknowledge supply delay")
	if turn == 3:
		labels.append("Keep saving power" if result.state_after.get("fault_mode") == "conserve" else "Keep farming")
	var stats: Dictionary = result.get("stats", {})
	var skipped: Array = result.get("not_applied_steps", [])
	if skipped.has("power"):
		labels.append("Stopped before resource calculations")
	elif not stats.is_empty():
		var demand: String = "required" if result.get("phase") == "failed_power" else "used"
		labels.append("Generated %d · Power %s %d" % [stats.generation, demand, stats.demand])
		if skipped.has("growth"):
			labels.append("Stopped before oxygen, growth, food and supply")
		else:
			labels.append("Harvest %d · Supply %d" % [stats.harvest, stats.supply])
	return " · ".join(labels)


static func comparison_prompt(compared: Dictionary) -> String:
	var before: Dictionary = compared.previous
	var after: Dictionary = compared.current
	var layout_changed := _slot_types(before.state_after) != _slot_types(after.state_after)
	var choice_changed: bool = before.event_choice != after.event_choice
	if before.turn_id == 3:
		choice_changed = before.state_after.fault_mode != after.state_after.fault_mode
	if layout_changed and choice_changed:
		return "Both layout and response changed. Try changing just one to compare again."
	if layout_changed:
		return "Your layout changed. Compare generation, power use and starting resources too."
	if choice_changed:
		return "Your response changed. Compare starting resources and earlier growth too."
	return "Compare both starting states and earlier turns too."


static func _slot_types(state: Dictionary) -> Dictionary:
	var slots := {}
	for facility in state.get("facilities", []):
		slots[facility.slot_id] = facility.type
	return slots
