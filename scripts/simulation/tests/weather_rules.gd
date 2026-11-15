extends SceneTree
## NASA records select teaching conditions; snapshots make each replay identical.
const Rules = preload("res://scripts/simulation/weather_rules.gd")
const Scenario = preload("res://resources/scenarios/lunar_training.tres")
const Simulation = preload("res://scripts/simulation/simulation.gd")
const Session = preload("res://scripts/simulation/snapshot_store.gd")
const Preview = preload("res://scripts/simulation/turn_preview.gd")
const POSE := {"position":[0.0,0.0,20.0], "yaw":0.0, "pitch":0.0}
var checks := 0
var failures := 0

func _initialize() -> void: call_deferred("_run")
func check(ok: bool, label: String) -> void:
	checks += 1
	if not ok:
		failures += 1
		push_error(label)

func record(kind: String, id: String, time := "2026-11-14T01:00Z") -> Dictionary:
	return {"record_type":kind, "event_id":id, "observed_at":time, "source_url":"https://ccmc.gsfc.nasa.gov/"}

func context(flare_class := "C1.0", sep := false, cme := false) -> Dictionary:
	var flare := record("FLR", "flare-" + flare_class)
	flare.class_type = flare_class
	return {"records":{"FLR":[flare], "SEP":[record("SEP", "sep-1")] if sep else [],
		"CME":[record("CME", "cme-1")] if cme else []},
		"sources":{"FLR":{"mode":"archive", "fetched_at":"2026-11-15T00:00:00Z"}}}

func layout(session) -> void:
	for item in [[0,"generator"],[11,"battery"],[13,"greenhouse"],[20,"shelter"]]:
		check(not session.edit("place",item[0],item[1],POSE).has("error"), "fixture layout " + item[1])

func turn_four(data: Dictionary) -> Dictionary:
	var session = Session.new(Scenario)
	session.configure_weather(data)
	layout(session)
	var state: Dictionary = session.preview().state
	state.turn_id = 4
	state.E = 8
	return state

func command(session, choice := "") -> Dictionary:
	return {"attempt_id":session.attempt_id, "turn_id":session.state.turn_id,
		"command_id":1, "draft":session.draft.duplicate(true), "event_choice":choice}

func _run() -> void:
	_mapping()
	_turn_four()
	_communication()
	_session_replay()
	print("NASA weather rules: %d checks / %d failures" % [checks, failures])
	quit(1 if failures else 0)

func _mapping() -> void:
	for letter in ["A", "B", "C", "M", "X"]:
		var data := context(letter + "2.0")
		var saved := data.duplicate(true)
		var profile := Rules.build(data)
		var severity: int = {"A":0,"B":0,"C":0,"M":1,"X":2}[letter]
		check(profile.alert_level == ["watch","warning","severe"][severity]
			and profile.protection_energy == severity * 2 and profile.shelter_required == (severity > 0), "FLR mapping " + letter)
		check(profile.mapping_version == "donki-training-v1" and profile.communication_delay == 1, "mapping version and no-CME delay")
		profile.context.sources.FLR.mode = "changed"
		check(data == saved, "profile does not alias original context")
	var data := context("X1.0", true, true)
	var stronger := record("FLR", "older-strongest", "2026-11-12T01:00Z")
	stronger.class_type = "X10.0"
	var latest := record("FLR", "latest-weak", "2026-11-15T01:00Z")
	latest.class_type = "C9.0"
	data.records.FLR.append_array([stronger,latest])
	data.records.SEP.append(record("SEP", "sep-latest", "2026-11-14T01:00:30Z"))
	data.records.CME.append(record("CME", "cme-latest", "2026-11-15T01:00Z"))
	var profile := Rules.build(data)
	check(profile.protection_energy == 6 and profile.alert_level == "severe" and profile.communication_delay == 2, "X plus SEP protection 6 and CME delay 2")
	check(profile.flare_class == "X10.0" and profile.flare_event_id == "older-strongest", "all FLRs select maximum strength instead of latest or lexical value")
	check(profile.source_ids == ["older-strongest", "sep-latest", "cme-latest"]
		and profile.sep_event_id == "sep-latest" and profile.cme_event_id == "cme-latest", "three representative evidence IDs, latest SEP/CME")
	data.records.FLR.reverse()
	check(Rules.build(data).source_ids == profile.source_ids, "record order cannot change selected rule evidence")
	var model := context("C1.0", true)
	model.records.SEP[0].evidence_type = "model"
	check(not Rules.build(model).shelter_required and Rules.build(model).sep_event_id.is_empty(), "model-only SEP cannot impose observed-particle rule")
	var observed := record("SEP", "mixed-observation")
	observed.evidence_type = "mixed"
	model.records.SEP.append(observed)
	check(Rules.build(model).shelter_required and Rules.build(model).sep_event_id == "mixed-observation", "mixed evidence includes observation")
	var flat: Dictionary = context("M2.3").records.FLR[0].duplicate(true)
	check(Rules.build(flat).protection_energy == 2, "legacy flat FLR context remains supported")

func _turn_four() -> void:
	var m := turn_four(context("M2.3"))
	var x := turn_four(context("X1.0"))
	var result_m := Simulation.simulate_turn(m, [], "shelter")
	var result_x := Simulation.simulate_turn(x, [], "shelter")
	check(result_m.state_after.E == 18 and result_x.state_after.E == 16, "M vs X changes same-input power by two")
	check(result_m.stats.protection_energy == 2 and result_x.stats.protection_energy == 4
		and result_m.stats.demand == 8 and result_x.stats.demand == 10, "protection is included once in demand")
	check(Simulation.facility_at(result_x.state_after,13).growth == 0, "sheltering pauses farm")
	var watch := turn_four(context("C1.0"))
	var sep := turn_four(context("C1.0", true))
	var watch_result := Simulation.simulate_turn(watch, [], "continue")
	var sep_result := Simulation.simulate_turn(sep, [], "continue")
	check(watch_result.phase == "turn_complete" and Simulation.facility_at(watch_result.state_after,13).growth == 1, "watch continue runs farm")
	check(sep_result.phase == "failed_safety" and sep_result.state_after.E == sep.E, "observed SEP requires shelter before resource use")
	check(Preview.growth_lines(watch, "continue").contains("가동하면 성장 1회")
		and Preview.current_effect(watch, "continue").contains("재배를 계속"), "watch growth and current effect explain continued operation")
	check(Preview.growth_lines(sep, "continue").contains("재배 계산 전 중단"), "required shelter preview explains skipped growth")
	check(Preview.flow_lines(x, result_x).contains("보호 전력 4"), "flow explains included protection cost")
	for source in [m,x,watch,sep]:
		var saved: Dictionary = source.duplicate(true)
		var preview := Preview.inspect(source, [], "")
		for outcome: Dictionary in preview.outcomes:
			check(outcome.result == Simulation.simulate_turn(source, [], outcome.choice), "both T4 choices have exact preview parity")
		check(source == saved, "preview and simulation keep source immutable")
	var no_generation := x.duplicate(true)
	no_generation = Simulation.validate_draft(no_generation, [{"action":"remove","slot_id":0}]).state
	no_generation.E = 10
	check(Simulation.simulate_turn(no_generation, [], "shelter").phase == "failed_power", "protection cost can exhaust power normally")

func _communication() -> void:
	for has_cme in [false,true]:
		var session = Session.new(Scenario)
		session.configure_weather(context("C1.0", false, has_cme))
		session.set_advice_request(true)
		var request_command := command(session)
		var requested: Dictionary = session.commit_turn(request_command, POSE, "terminal")
		var reply_turn := 3 if has_cme else 2
		check(session.state.communication.pending.reply_turn == reply_turn and session.state.E == 13, "CME changes wait, not request price")
		check(session.commit_turn(request_command, POSE, "terminal") == requested and session.state.E == 13, "duplicate request never repeats price")
		var response: Dictionary = session.commit_turn(command(session,"conserve"), POSE, "terminal")
		check(response.causes.has("advice_received") == (not has_cme), "T2 replies only without CME")
		if has_cme:
			response = session.commit_turn(command(session), POSE, "terminal")
			check(response.causes.has("advice_received") and response.state_after.communication.response_turn == 3, "CME reply arrives on T3 commit")
		var state := Scenario.initial_state()
		state.weather = Rules.build(context("C1.0",false,has_cme))
		state.turn_id = 6
		check(Simulation.advice_request_error(state) == ("advice_too_late" if has_cme else ""), "T6 request availability follows wait")
		state.turn_id = 1
		var preview := Preview.inspect(state, [], "", POSE, true)
		check(preview.communication_delay == reply_turn - 1 and preview.outcomes[0].result.state_after.communication.pending.reply_turn == reply_turn, "preview includes exact reply turn")
		check(Preview.flow_lines(state,preview.outcomes[0].result).contains("T%d" % reply_turn), "request text uses actual reply turn")

func _session_replay() -> void:
	var data := context("X2.0",true,true)
	var saved := data.duplicate(true)
	var session = Session.new(Scenario)
	var configured: Dictionary = session.configure_weather(data)
	check(configured.profile == session.state.weather and session.snapshot(1).weather == session.state.weather, "configure attaches profile to initial snapshot")
	configured.profile.context.records.FLR.clear()
	data.records.FLR.clear()
	check(session.state.weather.context == saved, "configure input and return cannot change frozen profile")
	check(not session.configure_weather(saved).has("error") and session.configure_weather(context()).get("error") == "weather_locked", "same context is idempotent and different context rejected")
	layout(session)
	session.set_advice_request(true)
	var choices := ["","normal","","shelter","acknowledge","",""]
	var energy := [27,17,7,13,21,29,37]
	for turn in 7:
		var cmd := command(session,choices[turn])
		var result: Dictionary = session.commit_turn(cmd,POSE,"terminal")
		check(result.state_after.E == energy[turn], "configured normal seven-turn E T%d" % (turn+1))
		check(result.weather_profile == result.state_after.weather and result.weather_profile.context == saved, "result retains profile and source context")
		check(session.commit_turn(cmd,POSE,"terminal") == result, "configured duplicate commit unchanged")
	check(session.state.phase == "completed" and session.state.F == 42, "configured seven-turn path succeeds without food rule changes")
	check(not session.configure_weather(saved).has("error"), "same configuration remains idempotent after completion")
	var old_four: Dictionary = session.result_at(4)
	session.restore_turn(4)
	check(session.state.weather.context == saved and not session.advice_requested, "rewind retains immutable profile and clears draft toggle")
	var replay: Dictionary = session.commit_turn(command(session,"shelter"),POSE,"terminal")
	check(replay.state_after == old_four.state_after and replay.weather_profile == old_four.weather_profile, "same profile and inputs replay identical T4 outcome")
	var late = Session.new(Scenario)
	late.commit_turn(command(late),POSE,"terminal")
	check(late.configure_weather(saved).get("error") == "weather_configuration_closed", "first weather setup cannot happen after play")
