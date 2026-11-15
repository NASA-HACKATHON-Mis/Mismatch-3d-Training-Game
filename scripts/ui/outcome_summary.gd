extends RefCounted
## Presentation only: current branch results, never previous attempts or predictions.
const UI = preload("res://scripts/ui/ui_style.gd")
const Preview = preload("res://scripts/simulation/turn_preview.gd")

static func ended(state: Dictionary) -> bool:
	return state.phase == "completed" or str(state.phase).begins_with("failed_")

static func heading(state: Dictionary) -> String:
	if state.phase == "completed": return "7턴 훈련 완료!"
	var cause: String = {"failed_power":"전력 부족","failed_life_support":"생명 유지 자원 부족","failed_safety":"안전 조건 미충족"}.get(state.phase, "")
	return "T%d 훈련 중단 · %s" % [state.turn_id, cause]

static func reason(result: Dictionary) -> String:
	if result.is_empty(): return ""
	var after: Dictionary = result.state_after
	match result.phase:
		"completed": return "축하해요! 7턴 동안 기지를 운영했어요. 내가 고른 대응과 자원 기록을 확인해요."
		"failed_power": return "전력이 다 떨어졌어요. 이번 턴 필요 전력은 %d예요. 남은 전력이 0이 되어 중단됐어요.\n산소·재배·식량·보급은 계산 전 중단됐어요." % result.stats.demand
		"failed_safety": return "대피소에서 대피하지 못했어요. 대피소가 있고 ‘대피하기’를 골라야 안전해요.\n이번 턴 전력·산소·재배·식량·보급은 계산 전 중단됐어요."
		"failed_life_support":
			var depleted: Array[String] = []
			if after.O <= 0: depleted.append("산소")
			if after.F <= 0: depleted.append("식량")
			return "%s 부족(0)으로 생명 유지가 중단됐어요. 이번 턴 자원 계산은 끝났어요." % "·".join(depleted)
	return ""

static func history_lines(session) -> String:
	var lines: Array[String] = []
	for turn in range(1,8):
		var result: Dictionary = session.result_at(turn)
		if result.is_empty(): continue
		var after: Dictionary = result.state_after
		var choice: String = result.event_choice
		var decision := " · 대응: " + Preview.choice_label(choice) if not choice.is_empty() else ""
		lines.append("T%d · %s%s · 전력 %d / 산소 %d / 식량 %d" % [turn,UI.phase_text(result.phase),decision,after.E,after.O,after.F])
	return "\n".join(lines)
