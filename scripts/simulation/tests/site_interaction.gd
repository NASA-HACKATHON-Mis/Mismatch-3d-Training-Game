extends SceneTree
const Station = preload("res://scripts/world/station.gd")
const Interaction = preload("res://scripts/world/site_interaction.gd")
const Rules = preload("res://scripts/simulation/scenario.gd")
var checks := 0
var failures := 0

func _initialize() -> void:
	call_deferred("_run")

func check(ok: bool, message: String) -> void:
	checks += 1
	if not ok:
		failures += 1
		push_error(message)

func _run() -> void:
	var station = Station.new()
	root.add_child(station)
	var state: Dictionary = Rules.new().initial_state()
	station.sync_facilities(state)
	var before := state.duplicate(true)
	var camera := Camera3D.new()
	root.add_child(camera)
	var interaction = Interaction.new()
	root.add_child(interaction)
	check(interaction.resolve_target(camera).kind == "none", "Unconfigured is safe")
	interaction.configure(station)
	await physics_frame
	await physics_frame
	camera.position = Vector3(-6, 1.7, 3)
	camera.look_at(Vector3(-6, 0.02, 1))
	var target: Dictionary = interaction.resolve_target(camera)
	check(target.kind == "slot" and target.slot_id == 11 and target.prompt.contains("Build"), "Empty pad near edge")
	check(interaction.resolve_target(camera, 0.5).kind == "none", "Out of reach pad")
	camera.position = Vector3(0, 1.7, 5)
	camera.look_at(Vector3(0, 1.7, 0))
	target = interaction.resolve_target(camera)
	check(target.kind == "slot" and target.slot_id == 12 and target.prompt.contains("View details"), "Building surface within four meters even when center is farther")
	camera.position = Vector3(0, 1.7, 7)
	camera.look_at(Vector3(0, 1.7, 0))
	check(interaction.resolve_target(camera).kind == "none", "Far building does not activate")
	camera.position = Vector3(0, 1.7, 20)
	camera.look_at(Vector3(0, 1.4, 18))
	check(interaction.resolve_target(camera).kind == "console", "Central console stays targetable")
	var player := CharacterBody3D.new()
	var player_shape := CollisionShape3D.new()
	var capsule := CapsuleShape3D.new()
	capsule.height = 2.0
	capsule.radius = 0.3
	player_shape.shape = capsule
	player.add_child(player_shape)
	root.add_child(player)
	player.position = camera.position
	camera.reparent(player)
	await physics_frame
	await physics_frame
	check(interaction.resolve_target(camera).kind == "console", "Camera owner collider is excluded")
	camera.reparent(root)
	player.free()
	camera.position = Vector3(-6, 1.7, 3)
	camera.look_at(Vector3(-6, 0.02, 1))
	var wall := StaticBody3D.new()
	var shape := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = Vector3(2, 3, 0.2)
	shape.shape = box
	wall.add_child(shape)
	wall.position = Vector3(-6, 1.5, 2)
	root.add_child(wall)
	await physics_frame
	await physics_frame
	check(interaction.resolve_target(camera).kind == "none", "Unrelated wall blocks pad")
	wall.free()
	var added := {"type": "battery", "slot_id": 11, "instance_id": 2}
	state.facilities.append(added)
	station.sync_facilities(state)
	await physics_frame
	await physics_frame
	camera.position = Vector3(-6, 1.7, 4)
	camera.look_at(Vector3(-6, 1.7, 0))
	target = interaction.resolve_target(camera)
	check(target.kind == "slot" and target.slot_id == 11 and target.prompt.contains("View details"), "Rebuilt facility target replaces empty pad")
	station.sync_facilities(before)
	await physics_frame
	await physics_frame
	camera.position = Vector3(-6, 1.7, 3)
	camera.look_at(Vector3(-6, 0.02, 1))
	check(interaction.resolve_target(camera).prompt.contains("Build"), "Removed facility restores empty pad")
	check(before == Rules.new().initial_state(), "Queries do not mutate simulation")
	check(interaction.get_child_count() == 0, "Query adds no movement colliders")
	check(interaction.resolve_target(camera, -1).kind == "none", "Invalid range is safe")
	camera.look_at(camera.position + Vector3.FORWARD)
	check(interaction.resolve_target(camera).kind == "none", "Looking over empty pad does not invent target")
	interaction.free()
	camera.free()
	station.free()
	print("Site interaction: %d checks, %d failures" % [checks, failures])
	quit(1 if failures else 0)
