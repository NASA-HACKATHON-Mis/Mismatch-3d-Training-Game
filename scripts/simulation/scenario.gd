class_name LunarScenario
extends Resource
## Fixed teaching scenario. All units are game units, not measurements.

const HABITAT_SLOT := 12
const SLOT_COUNT := 25
const SPAWN := Vector3(0.0, 0.0, 20.0)
const CONSOLE := Vector3(0.0, 0.0, 18.0)
const SUNLIT := [0, 4]
const SHIELDED := [0, 20]
const BUILDABLE := ["generator", "battery", "greenhouse", "shelter"]
const EVENTS := {"2": "power_fault", "4": "weather_alert", "5": "supply_delay"}

@export var scenario_id := "lunar_training"
@export var rule_version := "0.1"
@export var source_labels := {"resources": "educational_game_units", "events": "fictional_training_events"}


static func slot_position(slot_id: int) -> Vector3:
	@warning_ignore("integer_division")
	var row := slot_id / 5
	return Vector3((slot_id % 5 - 2) * 6, 0.0, (row - 2) * 6)


static func cost(kind: String, slot_id: int) -> int:
	match kind:
		"generator", "greenhouse":
			return 3
		"battery":
			return 2
		"shelter":
			return 3 if SHIELDED.has(slot_id) else 4
		_:
			return -1


static func footprint(kind: String) -> Vector3:
	match kind:
		"generator":
			return Vector3(3.6, 2.2, 3.4)
		"battery":
			return Vector3(2.8, 1.6, 2.7)
		"greenhouse":
			return Vector3(3.8, 2.4, 3.5)
		"shelter":
			return Vector3(3.6, 2.5, 3.8)
		_:
			return Vector3(3.8, 2.7, 3.8)


static func facility_overlaps_player(kind: String, slot_id: int, pose: Dictionary) -> bool:
	var p: Array = pose.position
	var center := slot_position(slot_id)
	var half := footprint(kind) * 0.5
	var x := maxf(absf(float(p[0]) - center.x) - half.x, 0.0)
	var z := maxf(absf(float(p[2]) - center.z) - half.z, 0.0)
	# The 0.3 m capsule stands 1.8 m above its foot origin.
	return float(p[1]) < half.y * 2 and float(p[1]) + 1.8 > 0 and x * x + z * z < 0.09


func initial_state() -> Dictionary:
	var grid := []
	grid.resize(SLOT_COUNT)
	grid[HABITAT_SLOT] = 1
	return {
		"scenario_id": scenario_id,
		"rule_version": rule_version,
		"turn_id": 1,
		"phase": "planning",
		"grid": grid,
		"facilities": [{"instance_id": 1, "type": "habitat", "slot_id": HABITAT_SLOT,
			"actual_paid_cost": 0, "growth": 0}],
		"E": 20, "O": 60, "F": 36,
		"budget": 12, "next_instance_id": 2,
		"fault_mode": "", "event_schedule": EVENTS.duplicate(true), "event_applied": {},
		"supply_delivered": false, "mission_progress": 0,
		"player": {"position": [SPAWN.x, SPAWN.y, SPAWN.z], "yaw": 0.0, "pitch": 0.0},
		"input_mode": "pause",
	}
