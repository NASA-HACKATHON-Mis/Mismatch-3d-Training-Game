extends SceneTree
const Mission = preload("res://scenes/main.tscn")
var checks := 0
var failures := 0
func _initialize() -> void: call_deferred("_run")
func check(ok: bool, message: String) -> void:
	checks += 1
	if not ok:
		failures += 1
		push_error(message)
func button(point: Vector2, pressed: bool) -> InputEventMouseButton:
	var event := InputEventMouseButton.new()
	event.position = point
	event.global_position = point
	event.button_index = MOUSE_BUTTON_LEFT
	event.pressed = pressed
	event.button_mask = MOUSE_BUTTON_MASK_LEFT if pressed else 0
	return event
func motion(point: Vector2, held: bool = true) -> InputEventMouseMotion:
	var event := InputEventMouseMotion.new()
	event.position = point
	event.global_position = point
	event.relative = Vector2(25,10)
	event.screen_relative = event.relative
	event.button_mask = MOUSE_BUTTON_MASK_LEFT if held else 0
	return event
func _run() -> void:
	var view := SubViewport.new()
	view.size = Vector2i(1280,800)
	root.add_child(view)
	var game = Mission.instantiate()
	view.add_child(game)
	game.set_physics_process(false)
	var player = game.player
	player.set_physics_process(false)
	for i in 6: await process_frame
	var initial: Dictionary = game.session.state.duplicate(true)
	game._start_exploring()
	game._update_capture(2.0, false)
	check(game.look_mode == "drag" and player.look_mode == "drag" and player.exploring, "Real player enters fallback")
	check(is_instance_valid(player.avatar) and player.avatar.get_parent() == player, "Body attached to yaw root")
	check("Space" in game.hud._controls.text and "drag" in game.help._controls.text, "Integrated capabilities advertised")
	var yaw: float = player.rotation.y
	view.push_input(motion(Vector2(700,300),false),true)
	check(player.rotation.y == yaw, "Hover cannot rotate")
	view.push_input(button(Vector2(50,50),true),true)
	view.push_input(motion(Vector2(700,300)),true)
	check(not player._dragging and player.rotation.y == yaw, "HUD click cannot begin drag")
	view.push_input(button(Vector2(700,300),false),true)
	view.push_input(button(Vector2(700,300),true),true)
	view.push_input(motion(Vector2(725,310)),true)
	check(player._dragging and player.rotation.y != yaw, "Unhandled world drag rotates actual player")
	yaw = player.rotation.y
	view.push_input(button(Vector2(50,50),false),true)
	view.push_input(motion(Vector2(725,310)),true)
	check(not player._dragging and player.rotation.y == yaw, "Release over HUD ends drag")
	view.push_input(button(Vector2(-1,300),true),true)
	view.push_input(motion(Vector2(725,310)),true)
	check(not player._dragging and player.rotation.y == yaw, "Outside press cannot begin drag")
	view.push_input(button(Vector2(700,300),true),true)
	view.push_input(motion(Vector2(-1,300)),true)
	view.push_input(motion(Vector2(725,310)),true)
	check(not player._dragging and player.rotation.y == yaw, "Leaving viewport cancels held drag")
	view.push_input(button(Vector2(700,300),true),true)
	game.get_window().mouse_exited.emit()
	check(not player._dragging, "Window mouse exit cancels drag")
	view.push_input(button(Vector2(700,300),true),true)
	game.get_window().focus_exited.emit()
	check(game.mode == "pause" and player.look_mode == "disabled" and not player._dragging, "Focus loss stops all input")
	game._set_mode("explore", "drag")
	view.push_input(motion(Vector2(725,310)),true)
	check(player.rotation.y == yaw, "Reentering requires fresh press")
	player.apply_pose(initial.player)
	for i in 3:
		await physics_frame
		player._physics_process(1.0/60.0)
	check(player.is_on_floor(), "Integrated character grounded")
	Input.action_press("walk_back")
	for i in 3:
		await physics_frame
		player._physics_process(1.0/60.0)
	check(player.avatar._phase > 0, "Movement advances body animation")
	Input.action_release("walk_back")
	Input.action_press("jump")
	await physics_frame
	player._physics_process(1.0/60.0)
	check(player.velocity.y > 0 and is_equal_approx(player.avatar._arms[0].rotation.x,-0.22), "Real jump drives airborne body pose")
	Input.action_release("jump")
	game._pause()
	var limb: Transform3D = player.avatar._arms[0].transform
	for i in 3: player._physics_process(1.0/60.0)
	check(player.avatar._arms[0].transform == limb and player.velocity == Vector3.ZERO, "Pause freezes body and velocity")
	game._restore(1)
	check(not player._dragging and player.look_mode == "disabled" and player.avatar._phase == 0, "Rewind resets body and mouse state")
	check(player.sees_console(game.station.console), "Body keeps console ray intact after rewind")
	game._set_mode("explore", "drag")
	game._physics_process(0.1)
	var interact := InputEventAction.new()
	interact.action = "open_terminal"
	interact.pressed = true
	game._input(interact)
	check(game.mode == "terminal" and player.look_mode == "disabled", "E works from real drag mode")
	check(game.session.state.E == initial.E and game.session.state.O == initial.O and game.session.state.F == initial.F, "Input and animation preserve resources")
	view.queue_free()
	await process_frame
	print("PE-05 input integration: %d checks, %d failures" % [checks,failures])
	quit(1 if failures else 0)
