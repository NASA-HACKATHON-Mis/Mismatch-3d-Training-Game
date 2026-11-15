extends SceneTree
## Exercise real CharacterBody motion, not only collision rays above the floor.
const Mission = preload("res://scenes/main.tscn")
var checks := 0
var failures := 0

func _initialize() -> void:
	call_deferred("_run")

func check(ok: bool, detail: String) -> void:
	checks += 1
	if not ok:
		failures += 1
		push_error(detail)

func _walk(player: CharacterBody3D, direction: Vector3, frames: int) -> void:
	player.set_exploring(true)
	for action: StringName in player.WALK_ACTIONS:
		Input.action_release(action)
	if direction.x > 0: Input.action_press("walk_right")
	if direction.x < 0: Input.action_press("walk_left")
	if direction.z > 0: Input.action_press("walk_back")
	if direction.z < 0: Input.action_press("walk_forward")
	for frame in frames:
		await physics_frame
		player._physics_process(1.0 / 60.0)
	for action: StringName in player.WALK_ACTIONS:
		Input.action_release(action)
	player.set_exploring(false)

func _run() -> void:
	var game = Mission.instantiate()
	root.add_child(game)
	game.set_physics_process(false)
	var player: CharacterBody3D = game.player
	player.set_physics_process(false)
	_check_capture(game)
	for phase in ["initial", "placed", "restored"]:
		if phase == "placed":
			game._set_mode("terminal")
			game._edit("place", 0, "generator")
			game._commit("")
		elif phase == "restored":
			game._restore(1)
		await _check_routes(game, phase)
	game.free()
	print("UX-R01 navigation: %d checks, %d failures" % [checks, failures])
	quit(1 if failures else 0)

func _check_routes(game: Node, phase: String) -> void:
	var player: CharacterBody3D = game.player
	for route in [
		["south", Vector3(5, 0.02, 20), Vector3.BACK],
		["north", Vector3(5, 0.02, -14), Vector3.FORWARD],
		["east", Vector3(16, 0.02, 8), Vector3.RIGHT],
		["west", Vector3(-16, 0.02, 8), Vector3.LEFT],
		["south-east", Vector3(16.3, 0.02, 20.3), Vector3(1, 0, 1).normalized()],
		["south-west", Vector3(-16.3, 0.02, 20.3), Vector3(-1, 0, 1).normalized()],
		["north-east", Vector3(16.3, 0.02, -14.3), Vector3(1, 0, -1).normalized()],
		["north-west", Vector3(-16.3, 0.02, -14.3), Vector3(-1, 0, -1).normalized()],
	]:
		player.global_position = route[1]
		player.rotation.y = 0
		await _walk(player, Vector3.ZERO, 20)
		await _walk(player, route[2], 50)
		var outside := player.global_position
		check((outside - route[1]).dot(route[2]) > 2.2, phase + " " + route[0] + " exit")
		await _walk(player, -route[2], 50)
		print("route %s %s: outside=%s returned=%s" % [phase, route[0], outside, player.global_position])
		check(player.global_position.distance_to(route[1]) < 0.18, phase + " " + route[0] + " re-entry")
	# Keep the original 2 m sight ray and exercise approach after leaving/returning.
	player.apply_pose({"position": [0, 0.02, 22], "yaw": 0.0, "pitch": 0.0})
	await _walk(player, Vector3.FORWARD, 42)
	check(player.sees_console(game.station.console), phase + " front console approach")
	_check_console_open(game, phase + " front")
	# Approach from the clear left side, not through the guide robot on the right.
	player.apply_pose({"position": [-3.5, 0.02, 18], "yaw": 0.0, "pitch": 0.0})
	await _walk(player, Vector3.RIGHT, 30)
	player.rotation.y = -PI / 2
	await physics_frame
	check(player.sees_console(game.station.console), phase + " side console approach")
	_check_console_open(game, phase + " side")
	player.apply_pose({"position": [0, 0.02, 22], "yaw": 0.0, "pitch": 0.0})
	await physics_frame
	check(not player.sees_console(game.station.console), phase + " no remote terminal access")

func _check_console_open(game: Node, detail: String) -> void:
	game._set_mode("explore")
	# Headless DisplayServer cannot capture a real pointer. Feed the real ray
	# result to the input handler; actual pointer permissions require Web QA.
	game._aiming = game.player.sees_console(game.station.console)
	var interact := InputEventAction.new()
	interact.action = "open_terminal"
	interact.pressed = true
	game._input(interact)
	check(game.mode == "terminal" and game.terminal.visible, detail + " E opens terminal")
	game._pause()

func _check_capture(game: Node) -> void:
	var before: Dictionary = game.session.state.duplicate(true)
	game._start_exploring()
	game._update_capture(0.1, false)
	check(game.mode == "capturing" and not game.player.exploring, "Async capture waits without movement")
	game._update_capture(2.0, false)
	check(game.mode == "explore" and game.look_mode == "drag" and game.player.exploring,
		"Denied/timed-out capture enables integrated drag exploration")
	game._pause()
	game._start_exploring()
	game._update_capture(0.1, true)
	check(game.mode == "explore" and game.player.exploring, "Retry succeeds after capture arrives")
	game._pause()
	game._start_exploring()
	var escape := InputEventKey.new()
	escape.keycode = KEY_ESCAPE
	escape.pressed = true
	game._input(escape)
	game._update_capture(0.1, true)
	check(game.mode == "pause" and not game.player.exploring, "Esc cancels pending capture")
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	game._physics_process(0.1)
	check(Input.mouse_mode == Input.MOUSE_MODE_VISIBLE, "Late capture after cancel is released")
	game._start_exploring()
	game._pause()
	game._update_capture(0.1, true)
	check(game.mode == "pause", "Focus-loss pause cannot be resumed by late capture")
	check(game.session.state == before, "Capture retries leave simulation state unchanged")
