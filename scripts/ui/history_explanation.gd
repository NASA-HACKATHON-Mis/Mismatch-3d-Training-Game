extends RefCounted
## Reads stored snapshots/results only. Does not simulate or restore.
const UI = preload("res://scripts/ui/ui_style.gd")
const Rules = preload("res://scripts/simulation/scenario.gd")
const Simulation = preload("res://scripts/simulation/simulation.gd")
const Preview = preload("res://scripts/simulation/turn_preview.gd")

static func start_line(state: Dictionary) -> String:
	if state.is_empty(): return "보관된 시작 상태 없음"
	var farms: Array[String] = []
	for facility: Dictionary in state.get("facilities",[]):
		if facility.type == "greenhouse": farms.append("%02d번 가동 %d/3" % [facility.slot_id+1,facility.growth])
	var growth := "재배실 없음" if farms.is_empty() else "재배 " + ", ".join(farms)
	return "저장된 턴 시작: 전력 %d/%d · 산소 %d · 식량 %d · 토큰 %d\n%s" % [state.E,Simulation.energy_cap(state),state.O,state.F,state.budget,growth]

static func candidates(session) -> Array[Dictionary]:
	var found: Array[Dictionary] = []
	var phase: String = session.state.phase
	if not phase.begins_with("failed_"): return found
	for turn in range(int(session.state.turn_id),0,-1):
		var start: Dictionary = session.snapshot(turn)
		if start.is_empty(): continue
		var evidence := ""
		if phase == "failed_power":
			if turn == 2: evidence = "이 시작점에서 고장 대응을 다시 고를 수 있어요."
			elif start.E > session.state.E: evidence = "중단 뒤보다 저장 전력이 남아 있는 시작점이에요."
		elif phase == "failed_life_support":
			if start.F <= session.state.F: continue
			var farms := Simulation.count_kind(start,"greenhouse")
			var remaining := 3
			var growing_slot := -1
			for facility: Dictionary in start.facilities:
				if facility.type == "greenhouse" and (growing_slot < 0 or 3-int(facility.growth) < remaining):
					remaining = 3-int(facility.growth)
					growing_slot = facility.slot_id
			# Preparation margin only, not a simulation of future harvest/survival.
			if start.F < remaining * 6: continue
			if farms > 0: evidence = "가장 자란 %02d번 재배실은 수확까지 가동 %d회가 남았어요." % [growing_slot+1,remaining]
			elif start.budget >= Rules.cost("greenhouse",0): evidence = "새 재배실 비용이 있고 수확까지 가동 3회가 필요해요. 빈 칸도 확인해요."
			if not evidence.is_empty(): evidence += "\n식량 %d / 매턴 소비 6 · %d회 소비량에 견준 탐색 기준이에요. 정지·전력 부족이면 더 필요하니 더 이른 기록도 살펴봐요." % [start.F,remaining]
		elif phase == "failed_safety":
			if Simulation.count_kind(start,"shelter") > 0: evidence = "대피소가 있는 시작점이에요. 사건 대응도 확인해요."
			else:
				for slot in Rules.SLOT_COUNT:
					if Simulation.facility_at(start,slot).is_empty() and start.budget >= Rules.cost("shelter",slot):
						evidence = "대피소를 놓을 빈 칸과 비용이 있는 시작점이에요."
						break
		if evidence.is_empty(): continue
		found.append({"turn":turn,"text":"T%d 시작 살펴보기\n%s\n%s" % [turn,evidence,start_line(start)]})
		if found.size() == 2: break
	return found

static func side(session, turn: int, previous: bool) -> String:
	var history: Dictionary = session.previous_attempt if previous else session.current_history
	var attempt: String = str(session.previous_attempt.get("attempt_id","없음")) if previous else str(session.attempt_id)
	var title := "%s · 시도 %s · T%d" % ["이전 시도" if previous else "이번 시도",attempt,turn]
	var result: Dictionary = history.get("results",{}).get(str(turn),{})
	var start: Dictionary = history.get("snapshots",{}).get(str(turn),{})
	if result.is_empty(): return title + " · 결과 없음\n" + start_line(start) + "\n이 턴을 아직 실행하지 않았거나 기록이 없어요."
	var choice: String = result.event_choice
	if turn == 3: choice = result.state_after.get("fault_mode","")
	var decision := Preview.choice_label(choice) if not choice.is_empty() else "별도 사건 선택 없음"
	var decision_title := "T2에서 고른 대응(이번 턴 유지): " if turn == 3 else "실제 대응: "
	var after: Dictionary = result.state_after
	var ending := "실제 최종 자원: 전력 %d/%d · 산소 %d · 식량 %d" % [after.E,Simulation.energy_cap(after),after.O,after.F]
	return title + " · " + UI.phase_text(result.phase) + "\n" + start_line(start) + "\n" + decision_title + decision + "\n" + ending + "\n실행 내역: " + Preview.flow_lines(start,result)

static func slots(state: Dictionary) -> Dictionary:
	var result := {}
	for facility: Dictionary in state.get("facilities",[]): result[int(facility.slot_id)] = str(facility.type)
	return result

static func changes(session, turn: int) -> String:
	var compared: Dictionary = session.compare_turn(turn)
	if compared.is_empty(): return "같은 턴의 양쪽 실행 결과가 있어야 차이를 비교해요. 결과가 없는 쪽은 예상으로 채우지 않아요."
	var old: Dictionary = compared.previous
	var current: Dictionary = compared.current
	var before: Dictionary = session.previous_attempt.get("snapshots",{}).get(str(turn),{})
	var now: Dictionary = session.snapshot(turn)
	var lines: Array[String] = ["실제 결과 차이(이번 − 이전): 전력 %s · 산소 %s · 식량 %s" % [UI.signed_delta(compared.delta.E),UI.signed_delta(compared.delta.O),UI.signed_delta(compared.delta.F)]]
	var old_choice: String = old.state_after.get("fault_mode","") if turn == 3 else old.event_choice
	var new_choice: String = current.state_after.get("fault_mode","") if turn == 3 else current.event_choice
	if old_choice != new_choice: lines.append("대응 차이: %s → %s" % [Preview.choice_label(old_choice),Preview.choice_label(new_choice)])
	var old_slots := slots(old.state_after)
	var new_slots := slots(current.state_after)
	var layout: Array[String] = []
	for slot in Rules.SLOT_COUNT:
		if old_slots.get(slot,"") != new_slots.get(slot,""):
			layout.append("%02d번 %s → %s" % [slot+1, UI.name_for(old_slots[slot]) if old_slots.has(slot) else "빈 칸",UI.name_for(new_slots[slot]) if new_slots.has(slot) else "빈 칸"])
	if not layout.is_empty(): lines.append("실행 배치 차이: " + ", ".join(layout))
	if not before.is_empty() and not now.is_empty():
		var different: Array[String] = []
		for key in ["E","O","F","budget"]:
			if before[key] != now[key]: different.append({"E":"전력","O":"산소","F":"식량","budget":"토큰"}[key] + " %d → %d" % [before[key],now[key]])
		if not different.is_empty(): lines.append("시작 상태 차이: " + " · ".join(different))
		var old_growth := growth(before)
		var new_growth := growth(now)
		if old_growth != new_growth: lines.append("시작 재배 가동 기록이 달라요. 양쪽 시작 상태를 함께 확인해요.")
	else: lines.append("시작 기록이 부족해 원인을 좁힐 수 없어요.")
	if old_choice == new_choice and layout.is_empty(): lines.append("이번 턴의 대응과 배치는 같아요. 앞선 턴의 시작 자원·재배 기록도 살펴봐요.")
	lines.append("여러 시작 조건과 선택이 결과에 영향을 줄 수 있어요. 이 차이만으로 한 가지 원인을 단정하지 않아요.")
	return "\n".join(lines)

static func growth(state: Dictionary) -> Dictionary:
	var result := {}
	for facility: Dictionary in state.get("facilities",[]):
		if facility.type == "greenhouse": result[facility.slot_id] = facility.growth
	return result
