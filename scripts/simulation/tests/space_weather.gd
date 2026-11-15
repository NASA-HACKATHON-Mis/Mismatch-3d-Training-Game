extends SceneTree
const Weather = preload("res://scripts/data/space_weather.gd")
var checks := 0
var failures := 0
class StubWeather extends Weather:
	var calls := 0
	var sent_url := ""
	var request_error := OK
	var cancel_calls := 0
	func _cancel_request() -> void:
		cancel_calls += 1
	func _begin_request(url: String) -> Error:
		calls += 1
		sent_url = url
		return request_error
	func _now_unix() -> int:
		return 1794700800 # 2026-11-15 UTC

func _initialize() -> void: call_deferred("_run")
func check(ok: bool, label: String) -> void:
	checks += 1
	if not ok:
		failures += 1
		push_error(label)
func fixture() -> StubWeather:
	var w := StubWeather.new()
	root.add_child(w)
	return w
func flare(day: String, value := "M1.3") -> Dictionary:
	return {"flrID":day + "T21:16:00-FLR-001", "beginTime":day + "T21:16Z", "classType":value,
		"link":"https://ccmc.gsfc.nasa.gov/DONKI/view/FLR/123/-1", "linkedEvents":[{"activityID":"fake-SEP"}]}
func respond(w: Node, data: Variant, code := 200, result := HTTPRequest.RESULT_SUCCESS) -> void:
	w._on_request_completed(result, code, PackedStringArray(), JSON.stringify(data).to_utf8_buffer())
func _run() -> void:
	var w := fixture()
	check(w.get_context().mode == "archive" and w.get_context().event_id == "2016-01-01T23:10:00-FLR-001", "Actual archive available before networking")
	w.start()
	check(w.calls == 1 and w.get_context().status == "loading", "Starts nonblocking with usable archive")
	check(w.sent_url.contains("startDate=2026-10-16") and w.sent_url.contains("endDate=2026-11-15"), "UTC thirty day query")
	w.start()
	check(w.calls == 1, "At most one startup request")
	respond(w,[flare("2026-11-14","C2.8"),flare("2026-10-16")])
	var context: Dictionary = w.get_context()
	check(context.mode == "live" and context.class_type == "C2.8" and context.observed_at == "2026-11-14T21:16Z", "Latest actual record selected irrespective of ordering")
	check(context.fetched_at.begins_with("2026-11-15") and context.fetched_at != context.observed_at, "Fetch date is not observation date")
	check(context.record_type == "FLR" and not context.has("linkedEvents"), "Linked IDs are not SEP/CME observations")
	context.class_type = "bad"
	check(w.get_context().class_type == "C2.8", "Returned context cannot mutate service")
	var frozen: Dictionary = w.freeze()
	respond(w,[flare("2026-11-15","X9.9")])
	check(w.get_context() == frozen, "Frozen recent record ignores late response")
	frozen.mode = "changed"
	check(w.get_context().mode == "live", "Frozen return is copied")
	w.free()
	for pair in [[500,HTTPRequest.RESULT_SUCCESS,"http_failed"],[0,HTTPRequest.RESULT_CANT_CONNECT,"network_failed"],[0,HTTPRequest.RESULT_TIMEOUT,"timeout"],[200,HTTPRequest.RESULT_BODY_SIZE_LIMIT_EXCEEDED,"network_failed"]]:
		w = fixture(); w.start()
		respond(w,[],pair[0],pair[1])
		check(w.get_context().mode == "archive" and w.get_context().status == pair[2], "Failed response uses archive " + str(pair))
		w.free()
	for data in [[],{},null,[null,1,{}],[flare("2016-01-01")],[flare("2027-01-01")],[flare("2026-11-14","wrong")],[flare("2026-11-31")],[{"flrID":"bad", "beginTime":"bad", "classType":"M1"}]]:
		w=fixture();w.start();respond(w,data)
		check(w.get_context().mode == "archive" and w.get_context().class_type == "M2.3", "Empty/malformed/out-of-range uses archive " + str(data))
		w.free()
	w=fixture();w.start()
	w._on_request_completed(HTTPRequest.RESULT_SUCCESS,200,PackedStringArray(),"not json".to_utf8_buffer())
	check(w.get_context().status == "invalid_data", "Invalid JSON fails cleanly")
	w.free()
	w=fixture();w.start()
	var oversized := PackedByteArray()
	oversized.resize(Weather.MAX_BODY_BYTES+1)
	w._on_request_completed(HTTPRequest.RESULT_SUCCESS,200,PackedStringArray(),oversized)
	check(w.get_context().status == "response_too_large", "Oversized body is rejected before JSON parsing")
	w.free()
	w=fixture();w.start()
	var second_record := flare("2026-11-14","X1.0")
	second_record.beginTime="2026-11-14T21:16:30Z"
	second_record.flrID="2026-11-14T21:16:30-FLR-001"
	respond(w,[second_record,flare("2026-11-14","C1.0")])
	check(w.get_context().class_type == "X1.0", "Mixed minute and second timestamps select latest observation")
	w.free()
	w=fixture();w.request_error=ERR_CANT_CONNECT;w.start()
	check(w.get_context().status == "request_failed", "Synchronous failure fallback")
	w.free()
	w=fixture();w.start()
	var before: Dictionary=w.freeze()
	respond(w,[flare("2026-11-14")]);w.start()
	check(w.get_context() == before and before.status == "frozen_archive" and w.calls == 1,"Starting play while loading freezes archive and ignores network")
	check(w.cancel_calls == 1,"Freeze cancels in-flight request")
	w.free()
	w=fixture();before=w.freeze();w.start()
	check(w.calls == 0 and w.get_context()==before,"Freeze before start never sends request")
	w.free()
	w=fixture();w.start()
	var unsafe := flare("2026-11-14");unsafe.link="javascript:alert(1)"
	respond(w,[unsafe])
	check(w.get_context().source_url.begins_with("https://ccmc.gsfc.nasa.gov/"),"Untrusted response cannot supply unsafe source link")
	w.free()
	w=fixture()
	w.updated.connect(func(_d): w.freeze(), CONNECT_ONE_SHOT)
	w.start()
	check(w.calls==0,"Freeze from loading notification avoids sending request")
	w.free()
	print("Space weather: %d checks / %d failures" % [checks,failures])
	quit(1 if failures else 0)
