extends RefCounted
## Read-only presentation of the CURRENT turn. Reuses the authoritative calculator.
const Simulation = preload("res://scripts/simulation/simulation.gd")
const Rules = preload("res://scripts/simulation/scenario.gd")

static func choices_for(turn: int) -> Array[String]:
	match turn:
		2: return ["normal", "conserve"]
		4: return ["shelter", "continue"]
		5: return ["acknowledge"]
	return [""]

static func choice_label(choice: String) -> String:
	match choice:
		"normal": return "재배 유지"
		"conserve": return "절전"
		"shelter": return "대피하기"
		"continue": return "대피 없이 진행"
		"acknowledge": return "보급 지연 확인"
	return "현재 배치"

static func inspect(snapshot: Dictionary, draft: Array, choice: String, pose: Dictionary = {},
		advice_request: bool = false) -> Dictionary:
	var source := snapshot.duplicate(true)
	var edits := draft.duplicate(true)
	var valid := Simulation.validate_draft(source, edits, pose.duplicate(true))
	if valid.has("error"): return valid
	var layout: Dictionary = valid.state
	var capacity := Simulation.energy_cap(layout)
	var output := {"current_energy":source.E, "current_capacity":Simulation.energy_cap(source),
		"layout_capacity":capacity, "spill":maxi(0, source.E - capacity), "layout":layout,
		"conditional":false, "outcomes":[], "communication_cost":1 if advice_request else 0,
		"communication_delay":Simulation.communication_delay(source), "weather_profile":source.get("weather", {}).duplicate(true)}
	if source.phase != "planning": return output
	var choices := choices_for(source.turn_id)
	output.conditional = choice.is_empty() and choices != [""]
	if not output.conditional: choices = [choice]
	for option in choices:
		var result := Simulation.simulate_turn(source.duplicate(true), edits.duplicate(true), option, pose.duplicate(true), advice_request)
		output.outcomes.append({"choice":option,"result":result,
			"available":option != "shelter" or Simulation.count_kind(layout,"shelter") > 0})
	return output

static func flow_lines(before: Dictionary, result: Dictionary) -> String:
	if result.has("error"): return "현재 선택으로 계산할 수 없어요."
	var skipped: Array = result.get("not_applied_steps", [])
	var stats: Dictionary = result.get("stats", {})
	var after: Dictionary = result.state_after
	var lines: Array[String] = []
	if int(result.get("communication_cost", 0)) > 0:
		var reply_turn: int = after.communication.pending.get("reply_turn", int(result.turn_id) + Simulation.communication_delay(after))
		lines.append("조언 요청 전력 1 · %d턴 뒤인 T%d를 확정하면 답장이 와요. (게임 상담 처리 시간)" % [Simulation.communication_delay(after), reply_turn])
	if "advice_received" in result.get("causes", []):
		lines.append("지구의 답장: " + str(after.communication.message))
	if skipped.has("power") or stats.is_empty():
		lines.append("전력·산소·재배·식량·보급: 계산 전 중단")
		return "\n".join(lines)
	var usage := "필요" if result.phase == "failed_power" else "소비"
	lines.append("전력 생산 %d · 전력 %s %d · 최종 %d/%d" % [stats.generation,usage,stats.demand,after.E,Simulation.energy_cap(after)])
	if int(stats.get("protection_energy", 0)) > 0:
		lines.append("이 전력 수요에는 훈련 보호 전력 %d가 포함돼요." % stats.protection_energy)
	if skipped.has("oxygen") or result.phase == "failed_power":
		lines.append("산소·재배·식량 수확/소비·보급: 계산 전 중단")
		return "\n".join(lines)
	if before.has("O"):
		var oxygen_change: int = after.O - int(before.O)
		lines.append("산소 생산 8 · 소비 6 · 변화 %s%d · 최종 %d" % ["+" if oxygen_change >= 0 else "",oxygen_change,after.O])
		if oxygen_change < 2: lines.append("산소 상한 100: 실제 증가량만 반영해요.")
	else:
		lines.append("산소 생산 8 · 소비 6 · 최종 %d (시작 기록 없음)" % after.O)
	lines.append("식량 수확 %d · 보급 %d · 소비 6 · 최종 %d" % [stats.harvest,stats.supply,after.F])
	return "\n".join(lines)

static func growth_lines(layout: Dictionary, choice: String) -> String:
	var lines: Array[String] = []
	var turn: int = layout.turn_id
	var mode: String = choice if turn == 2 else layout.get("fault_mode", "")
	var paused := (turn == 4 and choice == "shelter") or (turn in [2,3] and mode == "conserve")
	for facility in layout.facilities:
		if facility.type != "greenhouse": continue
		var remaining: int = 3 - int(facility.growth)
		var status := "이번 턴 재배 정지 · 성장 그대로" if paused else "가동하면 성장 1회"
		if turn == 2 and choice.is_empty(): status = "선택에 따라 가동 또는 정지"
		if turn == 4:
			if choice.is_empty(): status = "선택에 따라 대피 중 정지 또는 계속 가동"
			elif choice == "continue" and Simulation.shelter_required(layout): status = "필수 대피를 하지 않으면 재배 계산 전 중단"
		lines.append("%02d 재배실: 가동 %d회 더 하면 식량 +18 · %s" % [facility.slot_id + 1,remaining,status])
	if lines.is_empty(): lines.append("재배실 없음 · 수확은 가동 3회마다 식량 +18이에요.")
	lines.append("전력이나 안전 문제로 먼저 중단되면 재배는 계산하지 않아요.")
	return "\n".join(lines)

static func current_effect(layout: Dictionary, choice: String) -> String:
	var turn: int = layout.turn_id
	if turn == 2:
		var action := "대응 선택에 따라 재배 가동 여부가 달라져요."
		if choice == "conserve": action = "절전: 두 턴 동안 재배와 성장이 멈춰요."
		elif choice == "normal": action = "재배 유지: 두 턴 동안 전력이 있으면 가동해요."
		return "발전 중단: 이번 턴과 다음 턴. " + action
	if turn == 3:
		return "발전 중단: 이번 턴까지 적용. " + ("절전 유지: 재배·성장 정지." if layout.fault_mode == "conserve" else "재배 유지: 전력이 있으면 가동해요.")
	if turn == 4:
		if not layout.has("weather"): return "이번 턴 대피하면 재배·성장은 멈춰요. 대피하지 않으면 자원 계산 전에 중단돼요."
		var protection: int = layout.weather.protection_energy
		var condition := "대피하지 않으면 자원 계산 전에 중단돼요." if Simulation.shelter_required(layout) else "이번 관찰 단계에서는 대피 없이 재배를 계속할 수 있어요."
		return "자료가 선택한 훈련 조건: 대피하면 보호 전력 %d를 더 쓰고 재배·성장이 멈춰요. " % protection + condition
	if turn >= 5 and not layout.supply_delivered:
		return "알려진 보급: 식량 12가 7턴에 한 번 도착해요. 그 전에 중단되면 받지 못해요."
	if turn == 7 and layout.supply_delivered: return "식량 보급은 이미 받았어요. 중복 보급은 없어요."
	return "지금 알려진 조건으로 이번 턴만 계산해요."
