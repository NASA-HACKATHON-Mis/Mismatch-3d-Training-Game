extends SceneTree
const Mission = preload("res://scenes/main.tscn")
var checks := 0
var failures := 0
var render := false
func _initialize() -> void:
	render = "--render" in OS.get_cmdline_user_args()
	call_deferred("_run")
func check(ok: bool, message: String) -> void:
	checks += 1
	if not ok:
		failures += 1
		push_error(message)
func walk(player, action: String, frames: int) -> void:
	Input.action_press(action)
	for i in frames:
		await physics_frame
		player._physics_process(1.0/60.0)
	Input.action_release(action)
func _run() -> void:
	var game = Mission.instantiate()
	root.add_child(game)
	game.set_physics_process(false)
	var player = game.player
	player.set_physics_process(false)
	game._set_mode("explore")
	var before: Dictionary = game.session.state.duplicate(true)
	var posts: Array[Node] = game.station.find_children("EdgePost_*", "StaticBody3D", false, false)
	check(posts.size() == 10, "All ten visible posts have collision")
	for post in posts:
		var side: float = signf(post.position.x)
		player.apply_pose({"position":[post.position.x-side*0.9,0.02,post.position.z],"yaw":0.0,"pitch":0.0})
		await walk(player,"walk_right" if side > 0 else "walk_left",30)
		var separation: float = absf(player.position.x-post.position.x)
		check(separation >= 0.42 and separation < 0.5, "Actual player stops at post " + post.name)
	for side in [-1.0,1.0]:
		player.apply_pose({"position":[side*15.7,0.02,0.0],"yaw":0.0,"pitch":0.0})
		await walk(player,"walk_right" if side > 0 else "walk_left",40)
		check(absf(player.position.x)>17.3,"Gap beside posts remains walkable")
	var sun: DirectionalLight3D = game.station.get_node("SunLight")
	var disk: MeshInstance3D = game.station.get_node("SunDisk")
	check(disk.position.normalized().dot(sun.basis.z.normalized())>0.9999,"Sun disk matches illumination direction")
	check(disk.cast_shadow == GeometryInstance3D.SHADOW_CASTING_SETTING_OFF,"Sun visual does not cast extra shadow")
	check(game.session.state == before,"World presentation preserves simulation")
	if render:
		DirAccess.make_dir_recursive_absolute("res://logs/fix-world")
		player.apply_pose({"position":[0,0.02,20],"yaw":0.0,"pitch":0.0})
		player.camera.look_at(disk.global_position)
		player.camera.rotate_y(deg_to_rad(12))
		game.hud.set_target(false,player.global_position,-player.global_basis.z)
		for i in 6: await process_frame
		await RenderingServer.frame_post_draw
		root.get_texture().get_image().save_png("res://logs/fix-world/sun.png")
	game.free()
	print("Edge posts and sun: %d checks, %d failures" % [checks,failures])
	quit(1 if failures else 0)
