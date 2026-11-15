extends Node3D
## Coordinates input modes and projects the logical session into the 3D world and UI.

const Scenario = preload("res://resources/scenarios/lunar_training.tres")
const Rules = preload("res://scripts/simulation/scenario.gd")
const Session = preload("res://scripts/simulation/snapshot_store.gd")
const UI = preload("res://scripts/ui/ui_style.gd")

@onready var station = $Station
@onready var player = $Player
@onready var hud = $Interface/HUD
@onready var terminal = $Interface/Terminal
@onready var help = $Interface/Help

var session = Session.new(Scenario)
var mode := "pause"
var _aiming := false
var _command_serial := 0
var _help_focus: Control
var _capture_elapsed := 0.0
const CAPTURE_TIMEOUT := 2.0
var _observation_camera: Camera3D
var _return_camera: Camera3D
var _start_camera: Camera3D
var _has_explored := false


func _ready() -> void:
	get_window().focus_exited.connect(_pause)
	terminal.closed.connect(_pause)
	terminal.selected_slot_changed.connect(_highlight_selected)
	terminal.inspect_requested.connect(_inspect_selected)
	hud.inspection_closed.connect(_close_inspection)
	terminal.edited.connect(_edit)
	terminal.cancelled.connect(_cancel_draft)
	terminal.advanced.connect(_commit)
	terminal.rewound.connect(_restore)
	hud.started.connect(_start_exploring)
	hud.result_requested.connect(_reopen_result)
	hud.guidance_changed.connect(_set_guidance)
	terminal.guidance_changed.connect(_set_guidance)
	_start_camera = Camera3D.new()
	_start_camera.fov = 58
	add_child(_start_camera)
	get_viewport().size_changed.connect(_layout_start_camera)
	_layout_start_camera()
	_start_camera.make_current()
	_observation_camera = Camera3D.new()
	_observation_camera.fov = 55
	add_child(_observation_camera)
	hud.help_requested.connect(_open_help)
	terminal.help_requested.connect(_open_help)
	help.closed.connect(_close_help)
	station.sync_facilities(session.state)
	_refresh()
	_set_mode("pause")


func _highlight_selected(slot: int) -> void:
	var layout: Dictionary = session.preview().state
	var facility: Dictionary = preload("res://scripts/simulation/simulation.gd").facility_at(layout,slot)
	station.highlight_slot(slot,UI.name_for(facility.type) if not facility.is_empty() else "빈 칸")

func _inspect_selected() -> void:
	if mode != "terminal" or terminal._selected_slot < 0: return
	_return_camera = get_viewport().get_camera_3d()
	var slot: int = terminal._selected_slot
	var target := Rules.slot_position(slot)
	_observation_camera.position = target + Vector3(7,9,10)
	_observation_camera.look_at(target + Vector3(0,0.8,0))
	_observation_camera.make_current()
	var state_label := "미확정 배치 포함" if not session.draft.is_empty() else "현재 확정 배치"
	hud.show_inspection("지도 %02d번 칸 · %s · 청록색 테두리와 번호가 선택 위치예요." % [slot+1,state_label])
	_set_mode("inspect")

func _close_inspection() -> void:
	if mode == "inspect": _set_mode("terminal")

func _reopen_result() -> void:
	if help.visible or mode != "pause" or session.state.phase == "planning": return
	_refresh()
	_set_mode("terminal")

func _set_guidance(enabled: bool) -> void:
	hud.set_guidance(enabled)
	terminal.set_guidance(enabled)

func _layout_start_camera() -> void:
	if _has_explored or not is_instance_valid(_start_camera): return
	var viewport_size := get_viewport().get_visible_rect().size
	var narrow := viewport_size.x < 960
	_start_camera.position = Vector3(1.1, 2.4, 24.5) if narrow else Vector3(0.0, 2.0, 24.0)
	_start_camera.look_at(Vector3(1.1, -1.4, 18.0) if narrow else Vector3(0.1, 1.0, 18.0))

func _physics_process(delta: float) -> void:
	# A Web permission response can arrive after Esc, focus loss, or timeout.
	if mode not in ["explore", "capturing"] and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	if mode == "capturing":
		_update_capture(delta, Input.mouse_mode == Input.MOUSE_MODE_CAPTURED)
		return
	if mode == "explore":
		if Input.mouse_mode != Input.MOUSE_MODE_CAPTURED:
			_pause()
			hud.set_input_notice(UI.trn("마우스 잠금이 풀렸어요. 다시 시작하려면 버튼을 눌러요.",
				"Mouse capture was released. Click the button to resume."))
			return
		_aiming = player.sees_console(station.console)
		hud.set_target(_aiming,player.global_position,-player.global_basis.z)


func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_ESCAPE and help.visible:
			_close_help()
			get_viewport().set_input_as_handled()
			return
		if event.keycode == KEY_ESCAPE and mode == "inspect":
			_close_inspection()
			get_viewport().set_input_as_handled()
			return
		if event.keycode == KEY_ESCAPE and mode != "pause":
			_pause()
			get_viewport().set_input_as_handled()
			return
		if not help.visible and mode != "explore" and (event.keycode == KEY_H or event.physical_keycode == KEY_H):
			_open_help()
			get_viewport().set_input_as_handled()
			return
	if mode == "explore" and event.is_action_pressed(&"open_terminal", false):
		if _aiming:
			terminal.clear_notice()
			_refresh()
			_set_mode("terminal")
		get_viewport().set_input_as_handled()


func _unhandled_input(event: InputEvent) -> void:
	if not help.visible and mode == "pause" and event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		_start_exploring()
		get_viewport().set_input_as_handled()


func _start_exploring() -> void:
	if mode == "pause" and not help.visible:
		_capture_elapsed = 0.0
		hud.set_input_notice(UI.trn("마우스 잠금을 기다리고 있어요. Esc로 취소할 수 있어요.",
			"Waiting for mouse capture. Press Esc to cancel."))
		_set_mode("capturing")
		# Keep the request inside the click/key gesture; Web capture is asynchronous.
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


func _update_capture(delta: float, captured: bool) -> void:
	if mode != "capturing":
		return
	if captured:
		hud.set_input_notice("")
		_set_mode("explore")
		return
	_capture_elapsed += delta
	if _capture_elapsed >= CAPTURE_TIMEOUT:
		_set_mode("pause")
		hud.set_input_notice(UI.trn("마우스 잠금을 허용하지 못했어요. 게임 화면을 클릭한 뒤 다시 시작해요.\n계속 막히면 게임을 새 탭에서 열어 주세요.",
			"Mouse capture was not allowed. Click the game and try again.\nIf it stays blocked, open the game in its own tab."))


func _open_help() -> void:
	if help.visible or mode in ["explore", "capturing"]:
		return
	_help_focus = get_viewport().gui_get_focus_owner()
	if _help_focus == null:
		_help_focus = terminal.help_button if mode == "terminal" else hud.help_button
	hud.hide()
	terminal.hide()
	help.open(0)


func _close_help() -> void:
	help.hide()
	_set_mode(mode)
	if is_instance_valid(_help_focus) and _help_focus.is_visible_in_tree():
		_help_focus.grab_focus()
	_help_focus = null


func _pause() -> void:
	if is_node_ready() and not help.visible:
		_set_mode("pause")
		hud.set_input_notice("")


func _set_mode(new_mode: String) -> void:
	if mode == "inspect" and new_mode != "inspect":
		if is_instance_valid(_return_camera): _return_camera.make_current()
		_return_camera = null
	mode = new_mode
	if mode == "explore":
		_has_explored = true
		player.camera.make_current()
	_aiming = false
	var requested_mouse_mode := Input.MOUSE_MODE_CAPTURED if mode == "explore" else Input.MOUSE_MODE_VISIBLE
	if Input.mouse_mode != requested_mouse_mode:
		Input.mouse_mode = requested_mouse_mode
	player.set_exploring(mode == "explore")
	hud.show_mode(mode)
	terminal.visible = mode == "terminal"
	if terminal.visible:
		terminal.focus_primary()


func _refresh() -> void:
	hud.refresh(session.state)
	terminal.refresh(session)


func _edit(action: String, slot_id: int, kind: String) -> void:
	var verdict: Dictionary = session.edit(action, slot_id, kind, player.pose())
	if verdict.has("error"):
		terminal.set_notice(UI.error_text(verdict.error), true)
		return
	var state: Dictionary = verdict.state
	station.sync_facilities(state)
	_refresh()
	terminal.set_notice(UI.trn("배치를 바꿨어요. ‘이번 턴 진행’을 누르면 확정돼요.", "Layout updated. Advance to confirm it."))


func _cancel_draft() -> void:
	session.cancel_draft()
	station.sync_facilities(session.state)
	_refresh()
	terminal.set_notice(UI.trn("이번 변경을 취소했어요. 이전 턴의 시설은 그대로예요.", "This turn's layout changes were cancelled."))


func _commit(event_choice: String) -> void:
	_command_serial += 1
	var command := {"attempt_id": session.attempt_id, "turn_id": session.state.turn_id,
		"command_id": _command_serial, "draft": session.draft.duplicate(true), "event_choice": event_choice}
	var result: Dictionary = session.commit_turn(command, player.pose(), mode)
	if result.has("error"):
		terminal.set_notice(UI.error_text(result.error), true)
		return
	station.sync_facilities(session.state)
	terminal.on_result(result.turn_id)
	_refresh()
	if result.phase == "turn_complete":
		terminal.set_notice("T%d 완료! 전력·산소·식량을 지켰어요. 다음 턴을 준비해요." % result.turn_id)
	else:
		terminal.scroll_to_outcome()


func _restore(turn_id: int) -> void:
	var restored: Dictionary = session.restore_turn(turn_id)
	if restored.has("error"):
		terminal.set_notice(UI.error_text(restored.error), true)
		return
	station.sync_facilities(restored.state)
	var pose: Dictionary = restored.state.player
	var safe: bool = station.pose_is_safe(pose, restored.state)
	if not safe:
		pose = {"position": [Rules.SPAWN.x, Rules.SPAWN.y, Rules.SPAWN.z], "yaw": 0.0, "pitch": 0.0}
	player.apply_pose(pose)
	session.state.player = pose.duplicate(true)
	terminal.on_restore(turn_id)
	_refresh()
	_set_mode("terminal")
	terminal.set_notice(UI.trn("T%d 시작으로 돌아왔어요. 다르게 시도해 보세요.",
		"Rewound to the start of T%d. Try a different choice.") % turn_id if safe else
		UI.trn("안전한 위치로 돌아왔어요.", "Returned to a safe position."))
