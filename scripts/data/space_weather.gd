extends Node
## One startup DONKI query. Observations explain the scenario; never calculate risk.
signal updated(data: Dictionary)

const ENDPOINT := "https://ccmc.gsfc.nasa.gov/DONKI-API/get/FLR"
const ARCHIVE := "res://research/donki-sample.json"
const METADATA := "res://research/donki-sample.metadata.json"
const TIMEOUT_SECONDS := 8.0
const MAX_BODY_BYTES := 2097152
var _request: HTTPRequest
var _started := false
var _frozen := false
var _settled := false
var _context: Dictionary = {}
var _request_url := ""
var _start_date := ""
var _end_date := ""

func _init() -> void:
	_context = _archive_context("ready")

func get_context() -> Dictionary:
	return _context.duplicate(true)

func start() -> void:
	if _started or _frozen: return
	_started = true
	var now := _now_unix()
	_start_date = Time.get_datetime_string_from_unix_time(now - 30 * 86400).left(10)
	_end_date = Time.get_datetime_string_from_unix_time(now).left(10)
	_request_url = ENDPOINT + "?startDate=" + _start_date + "&endDate=" + _end_date + "&catalog=M2M_CATALOG&class=ALL&version=Latest"
	_context = _archive_context("loading")
	updated.emit(get_context())
	# A receiver can start play (freeze) during this emission.
	if _frozen: return
	if not is_inside_tree():
		_use_archive("unavailable")
		return
	var error := _begin_request(_request_url)
	if error != OK: _use_archive("request_failed")

func freeze() -> Dictionary:
	if not _frozen:
		_frozen = true
		if not _settled:
			_context = _archive_context("frozen_archive")
		_cancel_request()
		updated.emit(get_context())
	return get_context()

func _begin_request(url: String) -> Error:
	_request = HTTPRequest.new()
	_request.timeout = TIMEOUT_SECONDS
	_request.body_size_limit = MAX_BODY_BYTES
	_request.max_redirects = 0
	add_child(_request)
	_request.request_completed.connect(_on_request_completed)
	return _request.request(url, PackedStringArray(["Accept: application/json"]))

func _cancel_request() -> void:
	if is_instance_valid(_request): _request.cancel_request()

func _on_request_completed(result: int, response_code: int, _headers: PackedStringArray, body: PackedByteArray) -> void:
	if _frozen or _settled: return
	if result != HTTPRequest.RESULT_SUCCESS:
		_use_archive("timeout" if result == HTTPRequest.RESULT_TIMEOUT else "network_failed")
		return
	if response_code != 200:
		_use_archive("http_failed")
		return
	if body.size() > MAX_BODY_BYTES:
		_use_archive("response_too_large")
		return
	var parser := JSON.new()
	if parser.parse(body.get_string_from_utf8()) != OK:
		_use_archive("invalid_data")
		return
	if not parser.data is Array:
		_use_archive("invalid_data")
		return
	var chosen: Dictionary = {}
	for raw: Variant in parser.data:
		if not _valid_flare(raw): continue
		var date: String = raw.beginTime.left(10)
		if date < _start_date or date > _end_date: continue
		if chosen.is_empty() or _observation_time(raw) > _observation_time(chosen): chosen = raw
	if chosen.is_empty():
		_use_archive("no_recent_record")
		return
	_settled = true
	_context = _from_record(chosen, "live", "recent", Time.get_datetime_string_from_unix_time(_now_unix()) + "Z")
	updated.emit(get_context())

func _use_archive(status: String) -> void:
	if _frozen or _settled: return
	_settled = true
	_context = _archive_context(status)
	updated.emit(get_context())

func _archive_context(status: String) -> Dictionary:
	var records: Variant = JSON.parse_string(FileAccess.get_file_as_string(ARCHIVE))
	var meta: Variant = JSON.parse_string(FileAccess.get_file_as_string(METADATA))
	if records is Array and meta is Dictionary:
		for raw: Variant in records:
			if _valid_flare(raw) and raw.flrID == meta.get("selected_event_id", ""):
				return _from_record(raw, "archive", status, str(meta.get("retrieved_at", "")))
	return {"mode":"archive", "record_type":"", "event_id":"", "observed_at":"", "fetched_at":"", "class_type":"", "source_url":ENDPOINT,
		"explanation":"보관 자료를 읽지 못했어요. 게임의 경보는 교육용 가상 사건이에요.", "status":"archive_unavailable"}

func _from_record(record: Dictionary, mode: String, status: String, fetched_at: String) -> Dictionary:
	var link: String = str(record.get("link", ""))
	if not link.begins_with("https://ccmc.gsfc.nasa.gov/DONKI/view/FLR/"): link = ENDPOINT
	return {"mode":mode, "record_type":"FLR", "event_id":record.flrID, "observed_at":record.beginTime, "fetched_at":fetched_at,
		"class_type":record.classType, "source_url":link, "status":status,
		"explanation":"태양 플레어 %s 관측 사례예요. 우주 날씨를 살피고 대피를 준비하는 이유를 배워요. 게임 4턴 경보는 가상 사건이며 이 등급으로 피해나 방사선량을 계산하지 않아요." % record.classType}

func _valid_flare(raw: Variant) -> bool:
	if not raw is Dictionary: return false
	for key in ["flrID", "beginTime", "classType"]:
		if not raw.get(key) is String or raw[key].is_empty() or raw[key].length() > 128: return false
	var date_pattern := RegEx.new()
	date_pattern.compile("^[0-9]{4}-[0-9]{2}-[0-9]{2}T[0-9]{2}:[0-9]{2}(:[0-9]{2})?Z$")
	if date_pattern.search(raw.beginTime) == null: return false
	var stamp: String = raw.beginTime
	var bits := {"year":stamp.substr(0,4).to_int(), "month":stamp.substr(5,2).to_int(), "day":stamp.substr(8,2).to_int(),
		"hour":stamp.substr(11,2).to_int(), "minute":stamp.substr(14,2).to_int(), "second":stamp.substr(17,2).to_int() if stamp.length() == 20 else 0}
	if bits.year < 1900 or bits.month < 1 or bits.month > 12 or bits.day < 1 or bits.day > 31 or bits.hour > 23 or bits.minute > 59 or bits.second > 59: return false
	var days := [31, 29 if bits.year % 4 == 0 and (bits.year % 100 != 0 or bits.year % 400 == 0) else 28, 31,30,31,30,31,31,30,31,30,31]
	if bits.day > days[bits.month - 1]: return false
	var class_pattern := RegEx.new()
	class_pattern.compile("^[ABCMX][0-9]+(\\.[0-9]+)?$")
	return _valid_flare_id_and_class(raw, class_pattern)

func _valid_flare_id_and_class(raw: Dictionary, pattern: RegEx) -> bool:
	# DONKI may publish more than one flare ID at a timestamp.
	var id_pattern := RegEx.new()
	id_pattern.compile("^[0-9]{4}-[0-9]{2}-[0-9]{2}T[0-9]{2}:[0-9]{2}:[0-9]{2}-FLR-[0-9]+$")
	return pattern.search(raw.classType) != null and id_pattern.search(raw.flrID) != null and raw.flrID.left(16) == raw.beginTime.left(16)

func _observation_time(record: Dictionary) -> int:
	var stamp: String = record.beginTime.trim_suffix("Z")
	if stamp.length() == 16: stamp += ":00"
	return Time.get_unix_time_from_datetime_string(stamp)

func _now_unix() -> int:
	return int(Time.get_unix_time_from_system())
