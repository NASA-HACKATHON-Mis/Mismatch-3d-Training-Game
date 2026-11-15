extends SceneTree
const Player = preload("res://scenes/player/player.tscn")
const Rules = preload("res://scripts/simulation/scenario.gd")
const Mission = preload("res://scenes/main.tscn")
var checks := 0
var failures := 0
var tick_rate := 60
var render := false
func _initialize() -> void:
	render = "--render" in OS.get_cmdline_user_args()
	call_deferred("_run")
func check(ok: bool, message: String) -> void:
	checks += 1
	if not ok:
		failures += 1
		push_error(message)
func tick(player, count: int = 1) -> void:
	for i in count:
		await physics_frame
		player._physics_process(1.0 / tick_rate)
func reset(player) -> void:
	Input.action_release("jump")
	player.apply_pose({"position":[0,0.02,0],"yaw":0.0,"pitch":0.0})
	player.set_exploring(true)
	await tick(player, maxi(5, tick_rate / 5))
	check(player.is_on_floor(), "Fixture grounded")
func block(world, size: Vector3, position: Vector3) -> StaticBody3D:
	var body := StaticBody3D.new()
	body.position = position
	var shape := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = size
	shape.shape = box
	body.add_child(shape)
	var visual := MeshInstance3D.new()
	var mesh := BoxMesh.new()
	mesh.size = size
	visual.mesh = mesh
	body.add_child(visual)
	world.add_child(body)
	return body
func capture(view, tag: String) -> void:
	if not render: return
	await process_frame
	await RenderingServer.frame_post_draw
	var image: Image = view.get_texture().get_image()
	check(not image.is_empty(), "Render " + tag)
	image.save_png("res://logs/pe03/" + tag + ".png")
func _run() -> void:
	DirAccess.make_dir_recursive_absolute("res://logs/pe03")
	var original_ticks := Engine.physics_ticks_per_second
	var space_bound := false
	for event in InputMap.action_get_events("jump"):
		if event is InputEventKey and event.physical_keycode == KEY_SPACE: space_bound = true
	check(space_bound,"Space is bound to jump")
	var metrics := []
	for rate in [30,60,120]:
		tick_rate = rate
		Engine.physics_ticks_per_second = rate
		# Let the engine finish the frame that scheduled the previous tick rate.
		await process_frame
		await process_frame
		var view := SubViewport.new()
		view.size = Vector2i(1280,720)
		view.own_world_3d = true
		view.render_target_update_mode = SubViewport.UPDATE_ALWAYS
		root.add_child(view)
		var world := Node3D.new()
		view.add_child(world)
		var floor_body := block(world, Vector3(12,0.5,12), Vector3(0,-0.25,0))
		var player = Player.instantiate()
		world.add_child(player)
		player.set_physics_process(false)
		var camera := Camera3D.new()
		world.add_child(camera)
		camera.position = Vector3(4,2.7,5)
		camera.look_at(Vector3(0,1.2,0))
		camera.current = true
		var light := DirectionalLight3D.new()
		light.rotation_degrees = Vector3(-45,-30,0)
		world.add_child(light)
		# Fixture marker only: actual collision capsule remains the original scene.
		var marker := MeshInstance3D.new()
		var mesh := CapsuleMesh.new()
		mesh.radius = 0.3
		mesh.height = 1.8
		marker.mesh = mesh
		marker.position.y = 0.9
		player.add_child(marker)
		await reset(player)
		check(is_equal_approx(player.get_physics_process_delta_time(),1.0/rate), "Actual physics delta matches rate %d: %.9f" % [rate,player.get_physics_process_delta_time()])
		var base: float = player.position.y
		await capture(view, str(rate)+"-ground")
		Input.action_press("jump")
		await tick(player)
		check(is_equal_approx(player.velocity.y,sqrt(2.0*9.8*0.8)), "Launch uses sqrt(2*g*h)")
		var peak: float = player.position.y
		var previous_y: float = player.position.y
		var captured := false
		for i in rate * 2:
			await tick(player)
			peak = maxf(peak,player.position.y)
			if not captured and player.position.y < previous_y:
				captured = true
				await capture(view,str(rate)+"-apex")
			previous_y = player.position.y
		var height := peak-base
		metrics.append({"physics_hz":rate,"physics_delta":player.get_physics_process_delta_time(),"peak_m":height,"target_m":0.8,"error_percent":absf(height-0.8)/0.8*100.0})
		check(absf(height-0.8) <= 0.08,"Peak within 10%% at %dHz: %f" % [rate,height])
		check(player.is_on_floor() and absf(player.position.y-base)<0.005,"Holding Space never repeats after landing")
		await capture(view,str(rate)+"-land")
		Input.action_release("jump")
		await tick(player)
		Input.action_press("jump")
		await tick(player)
		check(player.velocity.y > 0,"Release and new press jumps again")
		Input.action_release("jump")
		await tick(player,2)
		var prior_velocity: float = player.velocity.y
		Input.action_press("jump")
		await tick(player)
		check(player.velocity.y < prior_velocity,"Airborne new press cannot re-jump")
		await tick(player,rate*2)
		check(player.is_on_floor(),"Airborne press is not buffered into landing")
		await reset(player)
		player.set_exploring(false)
		Input.action_press("jump")
		Input.action_release("jump")
		Input.action_press("jump")
		var frozen: Dictionary = player.pose()
		await tick(player,3)
		check(player.pose() == frozen and player.velocity == Vector3.ZERO,"UI blocks Space")
		player.set_exploring(true)
		await tick(player,3)
		check(player.is_on_floor(),"Held Space across UI resume is suppressed")
		Input.action_release("jump")
		await tick(player)
		Input.action_press("jump")
		await tick(player,3)
		player.set_exploring(false)
		frozen = player.pose()
		await tick(player,5)
		check(player.pose() == frozen and player.velocity == Vector3.ZERO,"Midair pause freezes pose and clears velocity")
		await capture(view,str(rate)+"-paused")
		player.set_exploring(true)
		var paused_y: float = player.position.y
		await tick(player)
		check(player.position.y < paused_y and player.velocity.y < 0,"Resume reapplies gravity, no held jump")
		player.apply_pose({"position":[0,0.02,0],"yaw":0.4,"pitch":-0.3})
		check(player.velocity == Vector3.ZERO,"apply_pose clears airborne velocity")
		await tick(player,rate)
		check(player.is_on_floor() and is_equal_approx(player.rotation.y,0.4),"Restore suppresses held input and preserves pose rotation")
		Input.action_release("jump")
		await tick(player)
		Input.action_press("jump")
		await tick(player)
		check(player.velocity.y > 0,"Restore allows a new press after release")
		await reset(player)
		player.apply_pose({"position":[0,2,0],"yaw":0.0,"pitch":0.0})
		Input.action_press("jump")
		await tick(player)
		check(player.position.y < 2.0 and player.velocity.y < 0,"First airborne restore tick cannot jump from stale floor contact")
		await reset(player)
		var ceiling := block(world,Vector3(3,0.2,3),Vector3(0,2.25,0))
		await tick(player,2)
		Input.action_press("jump")
		var ceiling_peak := 0.0
		var hit := false
		for i in rate*2:
			await tick(player)
			ceiling_peak = maxf(ceiling_peak,player.position.y)
			hit = hit or player.is_on_ceiling()
		check(hit and ceiling_peak < 0.36 and player.is_on_floor(),"Ceiling collision prevents penetration and allows landing")
		ceiling.queue_free()
		await tick(player,2)
		await reset(player)
		var wall := block(world,Vector3(2,3,0.2),Vector3(0,1.5,-1))
		Input.action_press("walk_forward")
		Input.action_press("jump")
		await tick(player,rate)
		check(player.position.z > -0.61,"Facility-like wall remains solid during jump")
		Input.action_release("walk_forward")
		wall.queue_free()
		player.apply_pose({"position":[20,-3.1,20],"yaw":1.0,"pitch":0.5})
		await tick(player)
		check(player.global_position == Rules.SPAWN and player.velocity == Vector3.ZERO,"Fall recovery uses existing spawn and clears velocity")
		check(player._jump_was_pressed,"Fall recovery suppresses held jump")
		Input.action_release("jump")
		floor_body.queue_free()
		view.queue_free()
		await process_frame
	Engine.physics_ticks_per_second = original_ticks
	tick_rate = original_ticks
	var game = Mission.instantiate()
	root.add_child(game)
	game.set_physics_process(false)
	game.player.set_physics_process(false)
	game._set_mode("terminal")
	game._edit("place",0,"generator")
	game._commit("")
	game._set_mode("explore")
	await tick(game.player,20)
	Input.action_press("jump")
	await tick(game.player,3)
	check(game.player.velocity.y > 0,"Actual mission player jumps before rewind")
	game._restore(1)
	check(game.mode == "terminal" and game.player.velocity == Vector3.ZERO,"Actual rewind stops jump in terminal")
	check(game.session.state.turn_id == 1 and game.player.pose() == game.session.state.player,"Actual rewind restores stored pose and turn")
	var restored_state: Dictionary = game.session.state.duplicate(true)
	for mode in ["terminal","help","pause"]:
		game._set_mode("terminal" if mode == "help" else mode)
		if mode == "help":
			game._open_help()
			check(game.help.visible and game.mode == "terminal", "Actual help opens over terminal")
		var before: Dictionary = game.player.pose()
		await tick(game.player,3)
		check(game.player.pose() == before and game.player.velocity == Vector3.ZERO,"Actual mode blocks jump: " + mode)
		if mode == "help":
			game._close_help()
			check(not game.help.visible and game.mode == "terminal", "Actual help closes to terminal")
		game._set_mode("explore")
		await tick(game.player,10)
		check(game.player.velocity.y <= 0,"Actual mode resume suppresses held jump: " + mode)
	check(game.session.state == restored_state,"Jump/UI transitions never calculate resources or turns")
	Input.action_release("jump")
	game.queue_free()
	var file := FileAccess.open("res://logs/pe03/jump_metrics.json",FileAccess.WRITE)
	file.store_string(JSON.stringify(metrics,"  "))
	print(JSON.stringify(metrics))
	print("PE-03 jump: %d checks, %d failures" % [checks,failures])
	quit(1 if failures else 0)
