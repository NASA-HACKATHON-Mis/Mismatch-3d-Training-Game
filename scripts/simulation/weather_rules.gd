extends RefCounted
## Deterministic teaching rules selected by observations, not a physical forecast.

const MAPPING_VERSION := "donki-training-v1"


static func build(context: Dictionary) -> Dictionary:
	var records: Dictionary = context.get("records", {})
	# Keep earlier single-FLR callers compatible with the multi-product context.
	if not records.has("FLR") and context.get("record_type", "") == "FLR":
		records = records.duplicate(true)
		records.FLR = [context]
	var maximum := 0
	var strongest: Dictionary = {}
	var strongest_rank := -1
	var strongest_size := -1.0
	for record: Dictionary in records.get("FLR", []):
		var flare_class: String = str(record.get("class_type", ""))
		var rank := "ABCMX".find(flare_class.left(1)) if not flare_class.is_empty() else -1
		if rank < 0: continue
		var size := flare_class.substr(1).to_float()
		if rank > strongest_rank or (rank == strongest_rank and (size > strongest_size or (size == strongest_size and _later(record, strongest)))):
			strongest = record
			strongest_rank = rank
			strongest_size = size
	if strongest_rank == 3: maximum = 1
	elif strongest_rank == 4: maximum = 2
	var sep: Dictionary = {}
	for record: Dictionary in records.get("SEP", []):
		if record.get("evidence_type", "observation") != "model" and _later(record, sep): sep = record
	var cme: Dictionary = {}
	for record: Dictionary in records.get("CME", []):
		if _later(record, cme): cme = record
	var source_ids: Array[String] = []
	for record: Dictionary in [strongest, sep, cme]:
		var source_id: String = str(record.get("event_id", ""))
		if not source_id.is_empty() and not source_ids.has(source_id): source_ids.append(source_id)
	var has_sep := not sep.is_empty()
	var delay := 2 if not cme.is_empty() else 1
	var level: String = "severe" if has_sep or maximum == 2 else ("warning" if maximum == 1 else "watch")
	var protection := maximum * 2 + (2 if has_sep else 0)
	var required := maximum > 0 or has_sep
	var summary := "Training alert %s · Shelter %s · Protection power %d · Advice delay %d turns. Records select educational rules, not real radiation exposure or lunar CME arrival predictions." % [
		{"watch":"Watch", "warning":"Warning", "severe":"Severe"}[level], "required" if required else "optional", protection, delay]
	return {"mapping_version": MAPPING_VERSION, "context": context.duplicate(true),
		"alert_level": level, "shelter_required": required, "protection_energy": protection,
		"communication_delay": delay, "summary": summary, "source_ids": source_ids,
		"flare_class":strongest.get("class_type", ""), "flare_event_id":strongest.get("event_id", ""),
		"sep_event_id":sep.get("event_id", ""), "cme_event_id":cme.get("event_id", "")}


static func _later(candidate: Dictionary, current: Dictionary) -> bool:
	if current.is_empty(): return true
	var candidate_time := _timestamp(candidate)
	var current_time := _timestamp(current)
	return candidate_time > current_time or (candidate_time == current_time and str(candidate.get("event_id", "")) > str(current.get("event_id", "")))


static func _timestamp(record: Dictionary) -> int:
	var stamp: String = str(record.get("observed_at", "")).trim_suffix("Z")
	if stamp.is_empty(): return 0
	if stamp.length() == 16: stamp += ":00"
	return Time.get_unix_time_from_datetime_string(stamp)
