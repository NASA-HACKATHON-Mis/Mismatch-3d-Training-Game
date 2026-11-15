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


func _ready() -> void:
	get_window().focus_exited.connect(_pause)
	terminal.closed.connect(_pause)
	terminal.edited.connect(_edit)
	terminal.cancelled.connect(_cancel_draft)
	terminal.advanced.connect(_commit)
	terminal.rewound.connect(_restore)
	hud.started.connect(_start_exploring)
	hud.help_requested.connect(_open_help)
	terminal.help_requested.connect(_open_help)
	help.closed.connect(_close_help)
	station.sync_facilities(session.state)
	_refresh()
	_set_mode("pause")


func _physics_process(_delta: float) -> void:
	if mode == "explore":
		if Input.mouse_mode != Input.MOUSE_MODE_CAPTURED:
			_pause()
			return
		_aiming = player.sees_console(station.console)
		hud.set_target(_aiming)


func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_ESCAPE and help.visible:
			_close_help()
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
		_set_mode("explore")


func _open_help() -> void:
	if help.visible or mode == "explore":
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


func _set_mode(new_mode: String) -> void:
	mode = new_mode
	_aiming = false
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED if mode == "explore" else Input.MOUSE_MODE_VISIBLE
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
	terminal.set_notice(UI.trn("배치를 바꿨어요. 다음 턴에 확정돼요.", "Layout updated. Advance to confirm it."))


func _cancel_draft() -> void:
	session.cancel_draft()
	station.sync_facilities(session.state)
	_refresh()
	terminal.set_notice(UI.trn("이번 턴의 배치를 모두 취소했어요.", "This turn's layout changes were cancelled."))


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
