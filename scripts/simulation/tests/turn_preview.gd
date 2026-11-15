extends SceneTree
const Fixture = preload("res://scripts/simulation/tests/ui_fixture.gd")
const Preview = preload("res://scripts/simulation/turn_preview.gd")
const Session = preload("res://scripts/simulation/snapshot_store.gd")
const Simulation = preload("res://scripts/simulation/simulation.gd")
const Scenario = preload("res://resources/scenarios/lunar_training.tres")
const Mission = preload("res://scenes/main.tscn")
var checks := 0
var failures := 0

func _initialize() -> void: call_deferred("_run")
func check(ok: bool, message: String) -> void:
	checks += 1
	if not ok:
		failures += 1
		push_error(message)

func fingerprint(session) -> Array:
	return [session.state.duplicate(true),session.draft.duplicate(true),session.current_history.duplicate(true),session.previous_attempt.duplicate(true),session.attempt_id,session.committed_command_ids.duplicate(true)]

func make_session(turn: int, energy: int = 28, oxygen: int = 60, growth: int = 0, mode: String = "normal", has_shelter: bool = true):
	var session = Session.new(Scenario)
	var base: Dictionary = session.state.duplicate(true)
	var layout := [{"action":"place","slot_id":0,"type":"generator"},{"action":"place","slot_id":11,"type":"battery"},{"action":"place","slot_id":13,"type":"greenhouse"}]
	if has_shelter: layout.append({"action":"place","slot_id":20,"type":"shelter"})
	base = Simulation.validate_draft(base,layout).state
	base.turn_id = turn
	base.E = energy
	base.O = oxygen
	base.F = 36
	base.fault_mode = mode
	base.supply_delivered = false
	for facility in base.facilities:
		if facility.type == "greenhouse": facility.growth = growth
	session.state = base
	session.current_history = {"snapshots":{str(turn):base.duplicate(true)},"results":{}}
	return session

func parity(session, choice: String, label: String) -> Dictionary:
	var original := fingerprint(session)
	var preview: Dictionary = Preview.inspect(session.snapshot(session.state.turn_id),session.draft,choice)
	check(fingerprint(session) == original,label + " preview does not mutate session")
	check(not preview.has("error") and preview.outcomes.size() == 1,label + " one outcome")
	var predicted: Dictionary = preview.outcomes[0].result
	var turn: int = session.state.turn_id
	var actual: Dictionary = session.commit_turn({"attempt_id":session.attempt_id,"turn_id":turn,"command_id":1,"draft":session.draft.duplicate(true),"event_choice":choice},session.state.player,"terminal")
	check(not actual.has("error"),label + " commit accepted")
	for field in ["E","O","F","phase","facilities","grid","budget","fault_mode","event_applied","supply_delivered","mission_progress"]:
		check(predicted.state_after[field] == actual.state_after[field],label + " parity " + field)
	check(predicted.stats == actual.stats and predicted.not_applied_steps == actual.not_applied_steps,label + " applied accounting parity")
	return predicted

func _run() -> void:
	var initial = Session.new(Scenario)
	var original := fingerprint(initial)
	initial.edit("place",11,"battery",initial.state.player)
	var added: Dictionary = Preview.inspect(initial.snapshot(1),initial.draft,"")
	check(added.current_energy == 20 and added.current_capacity == 20 and added.layout_capacity == 40,"Battery grows capacity without charging")
	check(initial.state.E == 20 and Simulation.energy_cap(initial.state) == 20,"Battery preview keeps current energy/cap")
	parity(initial,"","battery added")
	var removal = make_session(3)
	removal.edit("remove",11,"",removal.state.player)
	var removed: Dictionary = Preview.inspect(removal.snapshot(3),removal.draft,"")
	check(removed.current_energy == 28 and removed.current_capacity == 40 and removed.layout_capacity == 20 and removed.spill == 8,"Battery removal shows current/cap/spill separately")
	parity(removal,"","battery removed")
	var cancel = Session.new(Scenario)
	cancel.edit("place",11,"battery",cancel.state.player)
	cancel.cancel_draft()
	check(fingerprint(cancel) == original,"Cancel returns to original draft and state")
	check(Preview.inspect(cancel.snapshot(1),cancel.draft,"").layout_capacity == 20,"Cancel removes capacity prediction")
	for turn in [2,4,5]:
		var conditional = make_session(turn)
		var before := fingerprint(conditional)
		var options: Dictionary = Preview.inspect(conditional.snapshot(turn),conditional.draft,"")
		check(options.conditional and options.outcomes.size() == Preview.choices_for(turn).size(),"Unselected current event branches T%d" % turn)
		check(fingerprint(conditional) == before,"Conditional branches cannot mutate history")
		for outcome in options.outcomes:
			var expected := parity(make_session(turn),outcome.choice,"T%d %s" % [turn,outcome.choice])
			check(outcome.result.state_after == expected.state_after,"Conditional selected parity")
	var unsafe = Preview.inspect(make_session(4,28,60,0,"normal",false).state,[],"")
	check(not unsafe.outcomes[0].available and unsafe.outcomes[0].result.phase == "failed_safety","No shelter branch clearly unavailable")
	check(Preview.flow_lines({},unsafe.outcomes[1].result).contains("전력·산소") and not Preview.flow_lines({},unsafe.outcomes[1].result).contains("소비 6"),"Safety failure has no fabricated calculations")
	for growth in [0,1,2]:
		for mode in ["normal","conserve"]:
			for turn in [2,3,4,7]:
				var session = make_session(turn,28,99,growth,mode)
				var choice: String = mode if turn == 2 else ("shelter" if turn == 4 else "")
				var before: Dictionary = session.state.duplicate(true)
				var result := parity(session,choice,"growth%d T%d %s" % [growth,turn,mode])
				var paused: bool = turn == 4 or (turn in [2,3] and mode == "conserve")
				var farm: Dictionary = Simulation.facility_at(result.state_after,13)
				check(farm.growth == (growth if paused else (growth + 1) % 3),"Growth follows actual active count")
				check(Preview.growth_lines(before,choice).contains("가동 %d회 더" % (3-growth)),"Growth countdown uses active runs")
				check(Preview.flow_lines(before,result).contains("변화 +1") and Preview.flow_lines(before,result).contains("상한 100"),"Oxygen cap shows actual change")
				if turn == 7: check(result.stats.supply == 12,"T7 actual one-time supply")
	var power_before = make_session(3,10).state
	var failed := Simulation.simulate_turn(power_before,[],"")
	check(failed.phase == "failed_power" and Preview.flow_lines(power_before,failed).contains("식량 수확/소비·보급: 계산 전 중단"),"Power interruption distinguishes not-calculated from zero")
	var ordinary = make_session(1,28,60)
	var ordinary_before: Dictionary = ordinary.state.duplicate(true)
	var ordinary_result := parity(ordinary,"","ordinary oxygen")
	check(Preview.flow_lines(ordinary_before,ordinary_result).contains("산소 생산 8 · 소비 6 · 변화 +2"),"Normal oxygen accounting")
	var full_oxygen = make_session(1,28,100)
	var full_before: Dictionary = full_oxygen.state.duplicate(true)
	check(Preview.flow_lines(full_before,parity(full_oxygen,"","oxygen100")).contains("변화 +0"),"O100 actual change zero")
	check(Preview.flow_lines(power_before,failed).contains("전력 필요 10") and not Preview.flow_lines(power_before,failed).contains("전력 소비 10"),"Power shortage distinguishes demand from actual use")
	var delivered = make_session(7)
	delivered.state.supply_delivered = true
	delivered.current_history.snapshots["7"] = delivered.state.duplicate(true)
	check(parity(delivered,"","already supplied").stats.supply == 0,"No duplicate T7 supply")
	var alias_session = make_session(2)
	var alias_before := fingerprint(alias_session)
	var detached: Dictionary = Preview.inspect(alias_session.state,alias_session.draft,"")
	detached.layout.facilities[0].growth = 999
	detached.outcomes[0].result.state_after.facilities[0].growth = 888
	check(fingerprint(alias_session) == alias_before,"Returned nested data has no session aliases")
	for i in 5:
		var repeated: Dictionary = Preview.inspect(alias_session.state,alias_session.draft,"")
		check(repeated.layout.facilities[0].growth != 999 and repeated.outcomes[0].result.state_after.facilities[0].growth != 888 and fingerprint(alias_session) == alias_before,"Repeated reads do not retain returned mutations")
	for turn in [1,2,3,4]:
		var known = make_session(turn)
		var description: String = Preview.current_effect(known.state,"")
		check(not description.contains("7턴") and not description.contains("보급"),"No future supply disclosure before T5")
	check(Preview.current_effect(make_session(3,28,60,0,"conserve").state,"").contains("이번 턴까지"),"T3 duration shown")
	await ui_checks()
	print("UX-R03 turn preview: %d checks, %d failures" % [checks,failures])
	quit(1 if failures else 0)

func ui_checks() -> void:
	var game = Mission.instantiate()
	root.add_child(game)
	game.set_physics_process(false)
	game._set_mode("terminal")
	var ui = game.terminal
	var before := fingerprint(game.session)
	ui._toggle_preview()
	ui.refresh(game.session)
	check(fingerprint(game.session) == before,"Opening/reloading UI is read-only")
	Fixture.edit(game, "place",0,"generator")
	Fixture.edit(game, "place",4,"generator")
	Fixture.edit(game, "place",1,"greenhouse")
	Fixture.edit(game, "place",2,"greenhouse")
	var panel = game._site_panel
	panel.open_site(game.session, 3, "edit")
	panel.set_access_allowed(true)
	panel._select_kind("battery")
	check(panel._permission.text.contains("부족") and panel._place.disabled and panel._place.text.contains("2 토큰"),"Site menu shows budget shortage and exact cost")
	check(not panel._choice_buttons.battery.disabled,"Unaffordable description remains readable")
	panel._select_kind("generator")
	check(not panel._notice.text.contains("부족"),"Changing selection clears old error")
	Fixture.cancel_draft(game)
	check(not panel._permission.text.contains("부족") and not panel._notice.text.contains("부족"),"Fixture reset clears resolved shortage")
	panel.open_site(game.session, 20, "edit")
	check(panel._choice_buttons.shelter.text.contains("3 토큰"),"Shielded slot cost3")
	panel.open_site(game.session, 24, "edit")
	check(panel._choice_buttons.shelter.text.contains("4 토큰"),"Other slot cost4")
	ui._select_slot(12)
	check(ui._remove.disabled and ui._map_help.text.contains("고정"),"Fixed habitat reason")
	Fixture.cancel_draft(game)
	Fixture.edit(game, "place",0,"generator")
	game._commit("")
	check(ui._advance.disabled and ui._advance_reason.text.contains("사건 대응"),"Missing event reason near advance")
	ui._choose_event(1)
	check(not ui._advance.disabled and ui._advance_reason.text.is_empty(),"Required reason disappears after selection")
	game.free()
	var discount_game = Mission.instantiate()
	root.add_child(discount_game)
	discount_game.set_physics_process(false)
	discount_game.session.state.budget = 3
	discount_game.session.current_history.snapshots["1"] = discount_game.session.state.duplicate(true)
	discount_game._refresh()
	discount_game._set_mode("terminal")
	var discount_panel = discount_game._site_panel
	discount_panel.open_site(discount_game.session, 24, "edit")
	discount_panel.set_access_allowed(true)
	discount_panel._select_kind("shelter")
	check(discount_game.session.draft.is_empty() and discount_panel._place.disabled and discount_panel._permission.text.contains("부족"),"Budget3 cannot build nonshielded cost4")
	check(not discount_panel._choice_buttons.shelter.disabled,"Cost4 selection does not trap affordable alternative")
	discount_panel.open_site(discount_game.session, 20, "edit")
	discount_panel.set_access_allowed(true)
	discount_panel._select_kind("shelter")
	check(not discount_panel._place.disabled,"Budget3 enables shielded shelter action")
	Fixture.edit(discount_game, "place",20,"shelter")
	check(discount_game.session.preview().state.budget == 0 and Simulation.count_kind(discount_game.session.preview().state,"shelter") == 1,"Budget3 can switch to shielded cost3")
	discount_game.free()
