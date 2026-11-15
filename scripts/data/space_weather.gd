extends Node
## Parallel DONKI catalogue queries. Physical records are not lunar dose estimates.
signal updated(data: Dictionary)

const BASE_URL := "https://ccmc.gsfc.nasa.gov/DONKI-API/get/"
const ENDPOINT := BASE_URL + "FLR"
const TYPES := ["FLR", "SEP", "CME"]
const ARCHIVE_ROOT := "res://research/nasa-2024-05/"
const TIMEOUT_SECONDS := 8.0
const MAX_BODY_BYTES := 2097152
var _requests: Dictionary = {}
var _settled: Dictionary = {}
var _records: Dictionary = {}
var _sources: Dictionary = {}
var _archives: Dictionary = {}
var _archive_sources: Dictionary = {}
var _context: Dictionary = {}
var _started := false
var _frozen := false
var _deadline: Timer
var _start_date := ""
var _end_date := ""

func _init() -> void:
	for kind: String in TYPES:
		_load_archive(kind)
		_use_archive(kind, "ready")
	_refresh_context()

func get_context() -> Dictionary:
	return _context.duplicate(true)

func start() -> void:
	if _started or _frozen: return
	_started = true
	var now := _now_unix()
	_start_date = Time.get_datetime_string_from_unix_time(now - 30 * 86400).left(10)
	_end_date = Time.get_datetime_string_from_unix_time(now).left(10)
	for kind: String in TYPES:
		_settled[kind] = false
		_use_archive(kind, "loading")
	_publish()
	if _frozen: return
	if not is_inside_tree():
		for kind: String in TYPES: _finish_archive(kind, "unavailable")
		return
	_deadline = Timer.new()
	_deadline.one_shot = true
	_deadline.wait_time = TIMEOUT_SECONDS
	add_child(_deadline)
	_deadline.timeout.connect(_on_deadline)
	_deadline.start()
	# No await: all three requests begin in this frame and share one deadline.
	for kind: String in TYPES:
		if _frozen: break
		var error := _begin_request(kind, _request_url(kind))
		if error != OK: _finish_archive(kind, "request_failed")

func freeze() -> Dictionary:
	if not _frozen:
		_frozen = true
		for kind: String in TYPES:
			if not _settled.get(kind, false): _use_archive(kind, "frozen_archive")
			_cancel_request(kind)
		if is_instance_valid(_deadline): _deadline.stop()
		_publish()
	return get_context()

func _request_url(kind: String) -> String:
	var url := BASE_URL + kind + "?startDate=" + _start_date + "&endDate=" + _end_date + "&catalog=M2M_CATALOG&version=Latest"
	if kind == "FLR": url += "&class=ALL"
	return url

func _begin_request(kind: String, url: String) -> Error:
	var request := HTTPRequest.new()
	request.timeout = TIMEOUT_SECONDS
	request.body_size_limit = MAX_BODY_BYTES
	request.max_redirects = 0
	_requests[kind] = request
	add_child(request)
	request.request_completed.connect(_on_request_completed.bind(kind))
	return request.request(url, PackedStringArray(["Accept: application/json"]))

func _cancel_request(kind: String) -> void:
	if is_instance_valid(_requests.get(kind)): _requests[kind].cancel_request()

func _on_deadline() -> void:
	if _frozen: return
	for kind: String in TYPES:
		if not _settled.get(kind, false):
			_cancel_request(kind)
			_finish_archive(kind, "timeout")

func _on_request_completed(result: int, code: int, _headers: PackedStringArray, body: PackedByteArray, kind: String) -> void:
	if _frozen or _settled.get(kind, false) or kind not in TYPES: return
	if result != HTTPRequest.RESULT_SUCCESS:
		_finish_archive(kind, "timeout" if result == HTTPRequest.RESULT_TIMEOUT else "network_failed")
		return
	if code != 200:
		_finish_archive(kind, "http_failed")
		return
	if body.size() > MAX_BODY_BYTES:
		_finish_archive(kind, "response_too_large")
		return
	var parser := JSON.new()
	if parser.parse(body.get_string_from_utf8()) != OK or not parser.data is Array:
		_finish_archive(kind, "invalid_data")
		return
	var normalized := _normalize_array(parser.data, kind, _start_date, _end_date)
	if normalized.has("error"):
		_finish_archive(kind, "invalid_data")
		return
	var rows: Array = normalized.records
	# An empty valid SEP/CME response means no recent catalogue record, not a fabricated storm.
	if rows.is_empty() and kind == "FLR":
		_finish_archive(kind, "no_recent_record")
		return
	_records[kind] = rows
	_sources[kind] = {"mode":"live", "status":"recent" if not rows.is_empty() else "no_recent_record",
		"fetched_at":Time.get_datetime_string_from_unix_time(_now_unix()) + "Z", "request_url":_request_url(kind),
		"start_date":_start_date, "end_date":_end_date, "record_count":rows.size()}
	_settled[kind] = true
	_publish()

func _finish_archive(kind: String, status: String) -> void:
	if _frozen or _settled.get(kind, false): return
	_settled[kind] = true
	_use_archive(kind, status)
	_publish()

func _use_archive(kind: String, status: String) -> void:
	_records[kind] = _archives.get(kind, []).duplicate(true)
	_sources[kind] = _archive_sources.get(kind, {}).duplicate(true)
	_sources[kind].status = status if not _records[kind].is_empty() else "archive_unavailable"
	if _started: _sources[kind].attempted_request_url = _request_url(kind)

func _load_archive(kind: String) -> void:
	var raw: Variant = JSON.parse_string(FileAccess.get_file_as_string(ARCHIVE_ROOT + kind + ".json"))
	var meta: Variant = JSON.parse_string(FileAccess.get_file_as_string(ARCHIVE_ROOT + kind + ".metadata.json"))
	var normalized := _normalize_array(raw, kind, "2024-05-08", "2024-05-13")
	_archives[kind] = normalized.get("records", [])
	if not meta is Dictionary: meta = {}
	_archive_sources[kind] = {"mode":"archive", "status":"ready", "fetched_at":str(meta.get("retrieved_at", "")),
		"request_url":str(meta.get("request_url", BASE_URL + kind)), "start_date":"2024-05-08", "end_date":"2024-05-13",
		"sha256":str(meta.get("sha256", "")), "record_count":_archives[kind].size()}

func _publish() -> void:
	_refresh_context()
	if is_instance_valid(_deadline) and _settled.values().count(true) == TYPES.size(): _deadline.stop()
	updated.emit(get_context())

func _refresh_context() -> void:
	var live_count := 0
	for kind: String in TYPES:
		if _sources[kind].mode == "live": live_count += 1
	var mode := "live" if live_count == TYPES.size() else ("archive" if live_count == 0 else "mixed")
	var flares: Array = _records.get("FLR", [])
	var chosen: Dictionary = flares.back() if not flares.is_empty() else {}
	_context = {"mode":mode, "record_type":"FLR", "event_id":chosen.get("event_id", ""), "observed_at":chosen.get("observed_at", ""),
		"fetched_at":_sources.FLR.fetched_at, "class_type":chosen.get("class_type", ""), "source_url":chosen.get("source_url", ENDPOINT),
		"status":_sources.FLR.status, "records":_records.duplicate(true), "sources":_sources.duplicate(true),
		"explanation":"NASA DONKI의 FLR·SEP·CME 기록을 사용해요. 종류별 조회 기간과 출처가 다를 수 있어요. 게임 효과는 교육용 규칙이며 실제 달의 피폭량이나 통신 장애를 계산한 결과가 아니에요."}

func _normalize_array(raw: Variant, kind: String, start_date: String, end_date: String) -> Dictionary:
	if not raw is Array: return {"error":"invalid_data"}
	var rows: Array = []
	var seen := {}
	for entry: Variant in raw:
		var row := _normalize_record(entry, kind)
		if row.is_empty(): return {"error":"invalid_data"}
		var day: String = row.observed_at.left(10)
		if day < start_date or day > end_date: return {"error":"outside_period"}
		if not seen.has(row.event_id):
			seen[row.event_id] = true
			rows.append(row)
	rows.sort_custom(func(a, b): return _time_key(a.observed_at) < _time_key(b.observed_at))
	return {"records":rows}

func _normalize_record(raw: Variant, kind: String) -> Dictionary:
	if not raw is Dictionary: return {}
	var id_key: String = {"FLR":"flrID", "SEP":"sepID", "CME":"activityID"}[kind]
	var time_key: String = {"FLR":"beginTime", "SEP":"eventTime", "CME":"startTime"}[kind]
	var id: Variant = raw.get(id_key)
	var stamp: Variant = raw.get(time_key)
	if not id is String or not stamp is String or not _valid_time(stamp): return {}
	var pattern := RegEx.new()
	pattern.compile("^[0-9]{4}-[0-9]{2}-[0-9]{2}T[0-9]{2}:[0-9]{2}:[0-9]{2}-" + kind + "-[0-9]+$")
	if pattern.search(id) == null or id.left(16) != stamp.left(16): return {}
	var link: String = str(raw.get("link", ""))
	if not link.begins_with("https://ccmc.gsfc.nasa.gov/DONKI/view/" + kind + "/"): link = BASE_URL + kind
	var row := {"record_type":kind, "event_id":id, "observed_at":stamp, "source_url":link}
	if kind == "FLR":
		var value: Variant = raw.get("classType")
		pattern.compile("^[ABCMX][0-9]+(\\.[0-9]+)?$")
		if not value is String or pattern.search(value) == null: return {}
		row.class_type = value
	var instruments: Array[String] = []
	for instrument: Variant in raw.get("instruments", []) if raw.get("instruments") is Array else []:
		if instrument is Dictionary and instrument.get("displayName") is String:
			instruments.append(instrument.displayName.left(256))
	row.instruments = instruments
	var models := 0
	for instrument: String in instruments:
		if instrument.begins_with("MODEL:"): models += 1
	row.evidence_type = "model" if models > 0 and models == instruments.size() else ("mixed" if models > 0 else "catalogue")
	if kind == "CME":
		row.analyses = []
		for analysis: Variant in raw.get("cmeAnalyses", []) if raw.get("cmeAnalyses") is Array else []:
			if not analysis is Dictionary: continue
			var speed: Variant = analysis.get("speed")
			var angle: Variant = analysis.get("halfAngle")
			if (speed is int or speed is float) and is_finite(float(speed)) and speed >= 0 and (angle is int or angle is float) and is_finite(float(angle)) and angle >= 0 and angle <= 180:
				row.analyses.append({"speed_km_s":speed, "half_angle_deg":angle, "is_most_accurate":analysis.get("isMostAccurate", false) == true})
	return row

func _valid_time(stamp: String) -> bool:
	var pattern := RegEx.new()
	pattern.compile("^[0-9]{4}-[0-9]{2}-[0-9]{2}T[0-9]{2}:[0-9]{2}(:[0-9]{2})?Z$")
	if pattern.search(stamp) == null: return false
	var bits := {"year":stamp.substr(0,4).to_int(), "month":stamp.substr(5,2).to_int(), "day":stamp.substr(8,2).to_int(),
		"hour":stamp.substr(11,2).to_int(), "minute":stamp.substr(14,2).to_int(), "second":stamp.substr(17,2).to_int() if stamp.length() == 20 else 0}
	if bits.year < 1900 or bits.month < 1 or bits.month > 12 or bits.day < 1 or bits.day > 31 or bits.hour > 23 or bits.minute > 59 or bits.second > 59: return false
	var days := [31, 29 if bits.year % 4 == 0 and (bits.year % 100 != 0 or bits.year % 400 == 0) else 28, 31,30,31,30,31,31,30,31,30,31]
	return bits.day <= days[bits.month - 1]

func _time_key(stamp: String) -> String:
	var key := stamp.trim_suffix("Z")
	return key + ":00" if key.length() == 16 else key

func _now_unix() -> int:
	return int(Time.get_unix_time_from_system())
