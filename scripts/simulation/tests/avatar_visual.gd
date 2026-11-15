extends SceneTree
const Mission = preload("res://scenes/main.tscn")
const Avatar = preload("res://scenes/player/avatar_visual.tscn")
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
func settle() -> void:
	for i in 4: await process_frame
func joints(avatar) -> Array:
	var values := []
	for child in avatar.get_children(): values.append(child.transform)
	return values
func capture(view, name: String) -> void:
	if not render: return
	await RenderingServer.frame_post_draw
	var image: Image = view.get_texture().get_image()
	check(not image.is_empty(), "Rendered " + name)
	image.save_png("res://logs/pe02/" + name + ".png")
func _run() -> void:
	DirAccess.make_dir_recursive_absolute("res://logs/pe02")
	for dimensions in [Vector2i(1280,720), Vector2i(800,900)]:
		var view := SubViewport.new()
		view.size = dimensions
		view.render_target_update_mode = SubViewport.UPDATE_ALWAYS
		root.add_child(view)
		var game = Mission.instantiate()
		view.add_child(game)
		game.set_physics_process(false)
		game.player.set_physics_process(false)
		game._set_mode("explore")
		await settle()
		var pose: Dictionary = game.player.pose()
		var camera_transform: Transform3D = game.player.camera.transform
		var state: Dictionary = game.session.state.duplicate(true)
		var ray_before: bool = game.player.sees_console(game.station.console)
		check(ray_before, "Fixture initially faces console within E reach")
		var avatar = game.player.avatar
		check(is_instance_valid(avatar), "Actual player scene includes avatar")
		await settle()
		check(avatar.find_children("*", "CollisionObject3D", true, false).is_empty(), "No visual collision bodies")
		check(avatar.find_children("*", "CollisionShape3D", true, false).is_empty(), "No visual collision shapes")
		check(game.player.sees_console(game.station.console) == ray_before, "Actual console ray unchanged")
		var idle := joints(avatar)
		for i in 40: avatar.update_motion(Vector3(0,0,-3),true,false,0.1)
		check(joints(avatar) == idle and avatar._phase == 0.0, "Inactive startup freezes")
		avatar.update_motion(Vector3(0,0,-3),true,true,0.1)
		check(joints(avatar) != idle, "Walking articulates limbs")
		var walking := joints(avatar)
		for i in 40: avatar.update_motion(Vector3(0,0,-3),true,false,0.1)
		check(joints(avatar) == walking, "Inactive UI freezes current pose immediately")
		avatar.update_motion(Vector3.ZERO,true,true,0.1)
		check(joints(avatar) == idle, "Stopping removes walk swing immediately")
		avatar.update_motion(Vector3(0,2,0),false,true,0.1)
		check(joints(avatar) != idle and joints(avatar) != walking, "Airborne posture distinct")
		avatar.update_motion(Vector3.ZERO,true,true,0.1)
		check(joints(avatar) == idle, "Landing returns to idle")
		check(game.player.pose() == pose and game.player.camera.transform == camera_transform, "Motion never modifies player/camera")
		check(game.session.state == state, "Motion never modifies simulation")
		var tag := "%dx%d" % [dimensions.x, dimensions.y]
		for sample in [["front",0.0,0.0,0],["down",-80.0,0.0,0],["up",80.0,0.0,0],["left",-60.0,90.0,0],["right",-60.0,-90.0,0],["walk",-45.0,0.0,1],["air",-45.0,0.0,2],["land",-45.0,0.0,0]]:
			game.player.rotation.y = deg_to_rad(sample[2])
			game.player.camera.rotation.x = deg_to_rad(sample[1])
			avatar.update_motion(Vector3(0,0,-3) if sample[3] == 1 else Vector3.ZERO, sample[3] != 2, true, 0.1)
			game.hud.set_target(game.player.sees_console(game.station.console), game.player.global_position, -game.player.global_basis.z)
			check(avatar.transform == Transform3D.IDENTITY, "Body root never inherits pitch or shifts")
			await settle()
			await capture(view, tag + "-" + sample[0])
		game.player.apply_pose(pose)
		check(game.player.sees_console(game.station.console) == ray_before, "Ray after yaw/pitch cycle unchanged")
		game.player.rotation.y = PI
		check(not game.player.sees_console(game.station.console), "Avatar cannot make rear console interactable")
		view.queue_free()
		await settle()
	print("PE-02 avatar: %d checks, %d failures" % [checks,failures])
	quit(1 if failures else 0)
