extends SceneTree
## Mission state-machine checks. Probe does NOT implement real pointer input.
const Mission = preload("res://scenes/main.tscn")
var checks := 0
var failures := 0
var notifications: Array[String] = []

class LookProbe extends Node3D:
	var camera: Camera3D
	var exploring := false
	var look_mode := "disabled"
	var transitions: Array[String] = []
	func _init() -> void:
		camera = Camera3D.new()
		add_child(camera)
	func set_exploring(enabled: bool) -> void:
		exploring = enabled
		look_mode = "disabled"
	func set_look_mode(value: String) -> void:
		look_mode = value
		transitions.append(value)
	func sees_console(_console: StaticBody3D) -> bool:
		return true

func _initialize() -> void:
	call_deferred("_run")

func check(ok: bool, detail: String) -> void:
	checks += 1
	if not ok:
		failures += 1
		push_error(detail)

func _run() -> void:
	var game = Mission.instantiate()
	root.add_child(game)
	game.set_physics_process(false)
	game.player.set_physics_process(false)
	var original_player = game.player
	var initial: Dictionary = game.session.state.duplicate(true)
	game._start_exploring()
	game._update_capture(2.0, false)
	check(game.mode == "pause" and not original_player.exploring, "Legacy player cannot enter unsafe drag")
	check(game.hud._input_notice.visible and not game.hud._start.disabled, "Legacy retry remains usable")
	game._set_mode("explore", "drag")
	check(game.mode == "pause", "Explicit drag also requires input API")
	var probe := LookProbe.new()
	game.add_child(probe)
	game.player = probe
	game.look_mode_changed.connect(func(value: String): notifications.append(value))
	game._start_exploring()
	check(game.mode == "capturing" and not probe.exploring and probe.look_mode == "disabled", "Waiting disables motion and look")
	game._update_capture(1.0, false)
	check(game.mode == "capturing", "No premature fallback")
	game._update_capture(1.0, false)
	check(game.mode == "explore" and probe.exploring and probe.look_mode == "drag", "Timeout selects drag with movement")
	check(Input.mouse_mode == Input.MOUSE_MODE_VISIBLE, "Drag leaves cursor free")
	check(not game.hud._intro.visible and game.hud._status_box.visible, "Drag uses exploration HUD")
	check(notifications.back() == "drag", "HUD receives persistent look-mode contract")
	for i in 5: game._physics_process(0.1)
	check(game.mode == "explore" and game.look_mode == "drag", "Uncaptured drag does not loop to pause")
	game._update_capture(0.1, true)
	check(game.look_mode == "drag", "Late callback cannot change drag to captured")
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	game._physics_process(0.1)
	check(game.look_mode == "drag" and Input.mouse_mode == Input.MOUSE_MODE_VISIBLE, "Late capture is released in drag")
	var interact := InputEventAction.new()
	interact.action = "open_terminal"
	interact.pressed = true
	game._input(interact)
	check(game.mode == "terminal" and game.terminal.visible, "Drag can open aimed console")
	check(not probe.exploring and probe.look_mode == "disabled", "Console disables both movement and look")
	game._pause()
	game._start_exploring()
	game._update_capture(0.1, true)
	check(game.mode == "explore" and probe.look_mode == "captured", "Explicit retry can capture successfully")
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	game._physics_process(0.1)
	check(game.mode == "pause" and probe.look_mode == "disabled", "Capture loss stops movement and look")
	game._set_mode("explore", "drag")
	var escape := InputEventKey.new()
	escape.keycode = KEY_ESCAPE
	escape.pressed = true
	game._input(escape)
	check(game.mode == "pause" and not probe.exploring and probe.look_mode == "disabled", "Esc ends drag")
	game._set_mode("explore", "drag")
	game.get_window().focus_exited.emit()
	check(game.mode == "pause" and probe.look_mode == "disabled", "Focus loss ends drag")
	game._start_exploring()
	game._input(escape)
	game._update_capture(3.0, false)
	check(game.mode == "pause", "Cancelled request cannot fall back later")
	game._start_exploring()
	game.get_window().focus_exited.emit()
	game._update_capture(0.1, true)
	check(game.mode == "pause", "Late success after focus loss cannot resume")
	game._set_mode("explore", "invalid")
	check(game.mode == "pause" and probe.look_mode == "disabled", "Invalid look mode fails closed")
	game._open_help()
	game._start_exploring()
	check(game.help.visible and game.mode == "pause" and not probe.exploring, "Help prevents capture request")
	game._close_help()
	check(game.session.state == initial and game.session.draft.is_empty(), "Input transitions never mutate simulation")
	game.player = original_player
	game.free()
	print("PE-04 mouse modes: %d checks, %d failures" % [checks, failures])
	quit(1 if failures else 0)
