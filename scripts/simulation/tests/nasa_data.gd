extends SceneTree
const Weather = preload("res://scripts/data/space_weather.gd")
var checks := 0
var failures := 0
class StubWeather extends Weather:
	var calls: Array = []
	var cancelled: Array = []
	var request_errors := {}
	func _begin_request(kind: String, url: String) -> Error:
		calls.append({"kind":kind,"url":url})
		return request_errors.get(kind, OK)
	func _cancel_request(kind: String) -> void: cancelled.append(kind)
	func _now_unix() -> int: return 1794700800 # 2026-11-15 UTC
func _initialize() -> void: call_deferred("_run")
func check(ok: bool, label: String) -> void:
	checks += 1
	if not ok:
		failures += 1
		push_error(label)
func fixture() -> StubWeather:
	var service := StubWeather.new()
	root.add_child(service)
	return service
func record(kind: String, day := "2026-11-14") -> Dictionary:
	var id_key: String = {"FLR":"flrID","SEP":"sepID","CME":"activityID"}[kind]
	var time_key: String = {"FLR":"beginTime","SEP":"eventTime","CME":"startTime"}[kind]
	var row := {id_key:day+"T21:16:00-"+kind+"-001", time_key:day+"T21:16Z", "link":"https://ccmc.gsfc.nasa.gov/DONKI/view/"+kind+"/123/-1"}
	if kind == "FLR": row.classType="M1.3"
	if kind == "SEP": row.instruments=[{"displayName":"MODEL: REleASE fixture"}]
	if kind == "CME": row.cmeAnalyses=[{"speed":900.0,"halfAngle":45.0,"isMostAccurate":true}]
	return row
func respond(service: Node, kind: String, data: Variant, code := 200, result := HTTPRequest.RESULT_SUCCESS) -> void:
	service._on_request_completed(result,code,PackedStringArray(),JSON.stringify(data).to_utf8_buffer(),kind)
func _run() -> void:
	var service := fixture()
	var before: Dictionary = service.get_context()
	check(before.mode=="archive", "All archives are available before networking")
	check(before.source_label == "Embedded historical data - not live" and not before.is_live_feed, "Embedded archive explicitly rejects live-feed presentation")
	check(not before.snapshot_frozen, "Pre-start archive is not falsely marked frozen")
	for pair in [["FLR",87],["SEP",14],["CME",21]]:
		var kind: String=pair[0]
		check(before.records[kind].size()==pair[1],"Actual common-period archive count "+kind)
		var meta: Variant=JSON.parse_string(FileAccess.get_file_as_string(Weather.ARCHIVE_ROOT+kind+".metadata.json"))
		var bytes:=FileAccess.get_file_as_bytes(Weather.ARCHIVE_ROOT+kind+".json")
		var hash:=HashingContext.new();hash.start(HashingContext.HASH_SHA256);hash.update(bytes)
		check(hash.finish().hex_encode()==meta.sha256,"Original response SHA256 "+kind)
		check(before.sources[kind].request_url.contains("startDate=2024-05-08") and before.sources[kind].end_date=="2024-05-13","Archive period "+kind)
		check(before.sources[kind].fetched_at == meta.retrieved_at and before.sources[kind].fetched_at.begins_with("2026-"), "Archive keeps original retrieval date rather than current launch time " + kind)
	service.start();service.start()
	check(service.calls.size()==3,"Exactly three parallel startup requests, no repeats")
	check(service._deadline.wait_time==8.0 and not service._deadline.is_stopped(),"One common eight-second deadline")
	for request: Dictionary in service.calls:
		check(request.url.contains("startDate=2026-10-16") and request.url.contains("endDate=2026-11-15"),"UTC recent period "+request.kind)
	respond(service,"FLR",[record("FLR"),record("FLR","2026-10-16")])
	check(service.get_context().mode=="mixed" and service.get_context().observed_at=="2026-11-14T21:16Z","Partial live result is explicit and FLR latest remains summary")
	check(service.get_context().source_label.contains("Mixed fetched and historical") and not service.get_context().is_live_feed, "Mixed records are never advertised as a live feed")
	respond(service,"SEP",[]);respond(service,"CME",[])
	var live: Dictionary=service.get_context()
	check(live.mode=="live" and live.records.SEP.is_empty() and live.records.CME.is_empty(),"Valid empty SEP/CME stays empty live data")
	check(live.source_label == "Fetched NASA records - not a live feed" and not live.is_live_feed, "Successful catalogue fetch is not real-time monitoring")
	check(live.sources.SEP.status=="no_recent_record" and service._deadline.is_stopped(),"Empty means no catalogue record and completed requests stop timer")
	check(live.fetched_at!=live.observed_at,"Fetch and observation times remain distinct")
	live.records.FLR.clear();live.sources.FLR.mode="bad"
	check(not service.get_context().records.FLR.is_empty() and service.get_context().sources.FLR.mode=="live","Nested context is deep copied")
	before=service.freeze();respond(service,"FLR",[record("FLR","2026-11-15")]);service._on_deadline()
	check(before.snapshot_frozen and not before.is_live_feed, "Frozen fetched snapshot remains explicitly not live")
	check(service.get_context()==before,"All frozen records ignore late responses and timeout")
	service.free()
	for kind: String in Weather.TYPES:
		for outcome in [[0,HTTPRequest.RESULT_CANT_CONNECT],[500,HTTPRequest.RESULT_SUCCESS],[0,HTTPRequest.RESULT_TIMEOUT]]:
			service=fixture();service.start();respond(service,kind,[],outcome[0],outcome[1])
			check(service.get_context().sources[kind].mode=="archive" and not service.get_context().records[kind].is_empty(),"Failure retains actual archive "+kind+str(outcome))
			check(service.get_context().source_label == "Embedded historical data - not live" and not service.get_context().is_live_feed, "API failure cannot label static archive as live " + kind)
			service.free()
		for invalid in [{},null,[{}],[record(kind,"2026-11-31")],[record(kind,"2024-05-10")]]:
			service=fixture();service.start();respond(service,kind,invalid)
			check(service.get_context().sources[kind].status=="invalid_data","Malformed or outside recent period falls back "+kind)
			service.free()
	service=fixture();service.start();respond(service,"FLR",[])
	check(service.get_context().sources.FLR.mode=="archive","Empty FLR keeps documented fallback")
	service.free()
	service=fixture();service.start();respond(service,"FLR",[record("FLR")]);service._on_deadline()
	before=service.get_context()
	check(before.mode=="mixed" and before.sources.SEP.status=="timeout" and before.sources.CME.status=="timeout","Common deadline completes both pending requests without replacing live FLR")
	check(service.cancelled.has("SEP") and service.cancelled.has("CME"),"Deadline cancels pending HTTP requests")
	service.free()
	service=fixture();service.start();respond(service,"SEP",[record("SEP")]);before=service.freeze()
	check(before.mode=="mixed" and before.sources.FLR.status=="frozen_archive" and before.sources.SEP.mode=="live","Freeze locks partial live and pending fallback together")
	check(before.records.SEP[0].evidence_type=="model" and before.records.SEP[0].instruments[0].begins_with("MODEL:"),"SEP model evidence stays identified")
	respond(service,"CME",[record("CME")]);check(service.get_context()==before,"Late CME cannot alter frozen context")
	service.free()
	service=fixture();before=service.freeze();service.start()
	check(service.calls.is_empty() and before.mode=="archive","Freeze before startup starts no HTTP")
	service.free()
	service=fixture();service.updated.connect(func(_d):service.freeze(),CONNECT_ONE_SHOT);service.start()
	check(service.calls.is_empty(),"Freeze from startup signal starts no HTTP")
	service.free()
	service=fixture();service.request_errors.SEP=ERR_CANT_CONNECT;service.start()
	check(service.calls.size()==3 and service.get_context().sources.SEP.status=="request_failed","One synchronous failure does not prevent other queries")
	service.free()
	service=fixture();service.start()
	service._on_request_completed(HTTPRequest.RESULT_SUCCESS,200,PackedStringArray(),"not JSON".to_utf8_buffer(),"SEP")
	check(service.get_context().sources.SEP.status=="invalid_data","Malformed JSON is rejected")
	var oversized:=PackedByteArray();oversized.resize(Weather.MAX_BODY_BYTES+1)
	service._on_request_completed(HTTPRequest.RESULT_SUCCESS,200,PackedStringArray(),oversized,"CME")
	check(service.get_context().sources.CME.status=="response_too_large","Body size rejected before parsing")
	service.free()
	service=fixture();service.start();respond(service,"CME",[record("CME")])
	check(service.get_context().records.CME[0].analyses[0].speed_km_s==900.0,"CME measurement units are explicit")
	service.free()
	print("NASA data: %d checks / %d failures" % [checks,failures])
	quit(1 if failures else 0)
