extends RefCounted
## Text and offline sources for the learning panels. Simulation stays separate.

const DONKI_RECORD := "res://research/donki-sample.json"
const DONKI_METADATA := "res://research/donki-sample.metadata.json"
const CSA_ARTICLE := "https://www.asc-csa.gc.ca/eng/sciences/food-production/growing-healthy-food-in-space-and-remote-areas.asp"

const FACILITIES := {
	"habitat": "매 턴 전력 6을 써서 산소 8을 만들어요. 승무원은 산소와 식량을 각각 6씩 써요.",
	"generator": "매 턴 전력을 만들어요. 햇빛 칸은 18, 다른 칸은 12를 만들어요. 고장 중에는 발전할 수 없어요.",
	"battery": "남는 전력을 담아 둘 수 있는 양이 20 늘어요. 짓는 순간 전력이 생기지는 않아요.",
	"greenhouse": "가동한 턴에는 전력 4를 써요. 3턴 가동할 때마다 식량 18을 얻어요. 멈춘 턴에는 자라지 않아요.",
	"shelter": "우주 날씨 경보 때 승무원이 대피할 수 있어요. 차폐 칸에 지으면 토큰을 1개 덜 써요."
}

const EVENTS := {
	2: ["발전기 고장 · 2–3턴",
		"발전량이 0이에요. 재배를 계속하면 식물이 자라지만 전력이 더 필요해요. 절전하면 재배를 멈춰 전력을 아낄 수 있어요."],
	4: ["우주 날씨 경보 · 4턴",
		"대피소에서 대피하면 훈련을 이어 가지만 이번 턴 재배는 멈춰요. 대피 없이 진행하면 훈련이 중단돼요."],
	5: ["식량 보급 지연 · 5턴",
		"식량 12가 7턴에 한 번 도착해요. 그때까지 비축 식량과 재배실의 수확으로 버텨요."]
}


static func archived_flare() -> Dictionary:
	var records = JSON.parse_string(FileAccess.get_file_as_string(DONKI_RECORD))
	var meta = JSON.parse_string(FileAccess.get_file_as_string(DONKI_METADATA))
	if not records is Array or not meta is Dictionary:
		return {}
	for record in records:
		if record is Dictionary and record.get("flrID") == meta.get("selected_event_id"):
			return {"record": record, "metadata": meta}
	return {}


static func utc_label(value: String) -> String:
	return value.trim_suffix("Z").replace("T", " ") + " UTC"


static func attempt_note(result: Dictionary) -> String:
	var choice: String = result.get("event_choice", "")
	var turn: int = result.get("turn_id", 0)
	var labels: Array[String] = []
	match choice:
		"normal": labels.append("재배 유지")
		"conserve": labels.append("절전")
		"shelter": labels.append("대피")
		"continue": labels.append("대피 없이 진행")
		"acknowledge": labels.append("보급 지연 확인")
	if turn == 3:
		labels.append("절전 유지" if result.state_after.get("fault_mode") == "conserve" else "재배 유지")
	var stats: Dictionary = result.get("stats", {})
	var skipped: Array = result.get("not_applied_steps", [])
	if skipped.has("power"):
		labels.append("중단으로 자원 계산 생략")
	elif not stats.is_empty():
		var demand: String = "필요" if result.get("phase") == "failed_power" else "사용"
		labels.append("발전 %d · 전력 %s %d" % [stats.generation, demand, stats.demand])
		if skipped.has("growth"):
			labels.append("중단으로 산소·재배·식량·보급 생략")
		else:
			labels.append("수확 %d · 보급 %d" % [stats.harvest, stats.supply])
	return " · ".join(labels)


static func comparison_prompt(compared: Dictionary) -> String:
	var before: Dictionary = compared.previous
	var after: Dictionary = compared.current
	var layout_changed := _slot_types(before.state_after) != _slot_types(after.state_after)
	var choice_changed: bool = before.event_choice != after.event_choice
	if before.turn_id == 3:
		choice_changed = before.state_after.fault_mode != after.state_after.fault_mode
	if layout_changed and choice_changed:
		return "배치와 대응이 모두 달랐어요. 한 가지만 바꿔 다시 비교해 보세요."
	if layout_changed:
		return "시설 배치가 달랐어요. 발전·전력 사용과 턴 시작 자원도 함께 살펴봐요."
	if choice_changed:
		return "대응이 달랐어요. 턴 시작 자원과 앞선 재배 상태도 함께 살펴봐요."
	return "두 시도의 시작 자원과 앞선 턴도 함께 살펴봐요."


static func _slot_types(state: Dictionary) -> Dictionary:
	var slots := {}
	for facility in state.get("facilities", []):
		slots[facility.slot_id] = facility.type
	return slots
