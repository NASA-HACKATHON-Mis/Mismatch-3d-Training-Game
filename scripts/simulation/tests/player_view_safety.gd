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
func settle() -> void:
	for i in 5: await process_frame
	await physics_frame
func capture(view, tag: String) -> void:
	if not render: return
	await RenderingServer.frame_post_draw
	var image: Image = view.get_texture().get_image()
	check(not image.is_empty(), "Rendered " + tag)
	image.save_png("res://logs/fix-player/" + tag + ".png")
func make_wall(parent, position: Vector3, size: Vector3) -> StaticBody3D:
	var body := StaticBody3D.new()
	body.position = position
	var shape := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = size
	shape.shape = box
	body.add_child(shape)
	var mesh := MeshInstance3D.new()
	var visual := BoxMesh.new()
	visual.size = size
	mesh.mesh = visual
	body.add_child(mesh)
	parent.add_child(body)
	return body
func _run() -> void:
	DirAccess.make_dir_recursive_absolute("res://logs/fix-player")
	for size in [Vector2i(1280,720), Vector2i(800,900)]:
		var view := SubViewport.new()
		view.size = size
		view.own_world_3d = true
		view.render_target_update_mode = SubViewport.UPDATE_ALWAYS
		root.add_child(view)
		var game = Mission.instantiate()
		view.add_child(game)
		game.set_physics_process(false)
		var player = game.player
		player.set_physics_process(false)
		game._set_mode("explore")
		await settle()
		var original_state: Dictionary = game.session.state.duplicate(true)
		var start_pose: Dictionary = player.pose()
		check(player.sees_console(game.station.console), "Actual original console ray remains true")
		var capsule: CapsuleShape3D = player.get_node("CollisionShape3D").shape
		check(is_equal_approx(capsule.radius,0.3) and is_equal_approx(capsule.height,1.8), "Original capsule dimensions")
		var shadows := []
		for node in player.avatar.get_children():
			if node is MeshInstance3D and node.cast_shadow == GeometryInstance3D.SHADOW_CASTING_SETTING_SHADOWS_ONLY: shadows.append(node)
		check(shadows.size() == 2, "Closed torso and head cast shadows only")
		check(player.avatar.find_children("*","CollisionObject3D",true,false).is_empty(), "Visuals add no collisions")
		var tag := "%dx%d" % [size.x,size.y]
		for entry in [["front",0.0,0.0],["down",-90.0,0.0],["up",90.0,0.0],["down-left",-90.0,90.0],["down-right",-90.0,-90.0]]:
			player.apply_pose({"position":[5,0.02,5],"yaw":deg_to_rad(entry[2]),"pitch":deg_to_rad(entry[1])})
			check(player.camera.rotation.x >= player.MIN_PITCH-0.000001 and player.camera.rotation.x <= player.MAX_PITCH+0.000001,"Restore clamps actual camera pitch")
			for arm in player.avatar._arms:
				for mesh in arm.get_children():
					check(mesh.cast_shadow == (GeometryInstance3D.SHADOW_CASTING_SETTING_SHADOWS_ONLY if entry[1] < -35 else GeometryInstance3D.SHADOW_CASTING_SETTING_ON),"Restore updates lowered-view arm visibility without removing shadows")
			game.hud.set_target(false,player.global_position,-player.global_basis.z)
			await settle()
			await capture(view,tag+"-"+entry[0])
		player.set_look_mode("drag")
		var press := InputEventMouseButton.new()
		press.button_index = MOUSE_BUTTON_LEFT
		press.pressed = true
		press.position = Vector2(100,100)
		player._unhandled_input(press)
		for movement in [100000.0,-100000.0]:
			var motion := InputEventMouseMotion.new()
			motion.position = Vector2(100,100)
			motion.button_mask = MOUSE_BUTTON_MASK_LEFT
			motion.screen_relative = Vector2(0,movement)
			player._unhandled_input(motion)
			check(is_equal_approx(player.camera.rotation.x,player.MIN_PITCH if movement > 0 else player.MAX_PITCH),"Actual drag input clamps pitch")
		player.apply_pose({"position":[5,0.02,5],"yaw":0.0,"pitch":0.0})
		for side in ["front","left","right"]:
			var offset := Vector3(0,1.1,-0.5) if side == "front" else Vector3(-0.5 if side == "left" else 0.5,1.1,0)
			var wall_size := Vector3(3,2.2,0.2) if side == "front" else Vector3(0.2,2.2,3)
			var wall := make_wall(game,player.position+offset,wall_size)
			await settle()
			var action := "walk_forward" if side == "front" else ("walk_left" if side == "left" else "walk_right")
			Input.action_press(action)
			for frame in 12:
				await physics_frame
				player._physics_process(1.0/60.0)
			Input.action_release(action)
			player._refresh_arm_clearance()
			check(player.avatar.obstacle_near,"Detect " + side + " wall across arm volume")
			var boundary: float = wall.position.z+wall_size.z/2-player.position.z if side == "front" else (wall.position.x+wall_size.x/2-player.position.x if side == "left" else wall.position.x-wall_size.x/2-player.position.x)
			for arm in player.avatar._arms:
				for mesh in arm.get_children():
					var bounds: AABB = mesh.get_aabb()
					for corner in 8:
						var point: Vector3 = player.to_local(mesh.to_global(bounds.get_endpoint(corner)))
						check(point.z > boundary if side == "front" else (point.x > boundary if side == "left" else point.x < boundary),"Retracted arm vertex remains in front of wall after actual capsule approach")
			var before: Dictionary = player.pose()
			var arm_pose: Transform3D = player.avatar._arms[0].transform
			player.set_exploring(false)
			player._physics_process(0.1)
			check(player.pose() == before and player.avatar._arms[0].transform == arm_pose,"Pause preserves clearance and player pose")
			game.hud.set_target(false,player.global_position,-player.global_basis.z)
			await settle()
			await capture(view,tag+"-wall-"+side)
			player.set_exploring(true)
			wall.queue_free()
			await settle()
			player._refresh_arm_clearance()
			check(not player.avatar.obstacle_near,"Clearance releases when wall removed")
			player.apply_pose({"position":[5,0.02,5],"yaw":0.0,"pitch":0.0})
		var side_wall := make_wall(game,player.position+Vector3(0.5,1.1,0),Vector3(0.2,2.2,3))
		await settle()
		player.apply_pose({"position":[5,0.02,5],"yaw":0.0,"pitch":-2.0})
		check(player.avatar.obstacle_near,"Restore immediately refreshes arm clearance")
		player.apply_pose({"position":[9,0.02,9],"yaw":0.0,"pitch":0.0})
		check(not player.avatar.obstacle_near,"Restore to open area clears old folded state")
		side_wall.queue_free()
		await settle()
		player.apply_pose({"position":[5,0.02,5],"yaw":0.0,"pitch":0.0})
		var camera := Camera3D.new()
		game.add_child(camera)
		camera.position = player.position + Vector3(3,6,6)
		camera.look_at(player.position+Vector3(0,0,-1))
		camera.make_current()
		game.hud.hide()
		await settle()
		await capture(view,tag+"-ground-shadow")
		player.camera.make_current()
		player.apply_pose(start_pose)
		check(player.sees_console(game.station.console),"Console ray unchanged after wall/restore cycle")
		check(game.session.state == original_state,"Visual checks never mutate simulation")
		view.queue_free()
		await settle()
	print("Player view safety: %d checks, %d failures" % [checks,failures])
	quit(1 if failures else 0)
