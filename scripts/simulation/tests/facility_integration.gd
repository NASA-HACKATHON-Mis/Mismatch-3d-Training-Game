extends SceneTree
## Checks the remaining Blender models through the game's normal scene and turn flow.

const Mission = preload("res://scenes/main.tscn")
const Rules = preload("res://scripts/simulation/scenario.gd")
const MODELS := {
	"battery": [11, Vector3(3.3, 2.253, 2.68), ["alloy_shell", "equipment_blue", "service_amber"]],
	"habitat": [12, Vector3(3.26, 3.1165, 3.66), ["alloy_shell", "equipment_blue", "service_amber"]],
	"greenhouse": [13, Vector3(3.44, 2.9825, 3.75), ["alloy_shell", "glazing_blue", "leaf_green"]],
	"shelter": [14, Vector3(3.8, 2.795, 3.79), ["alloy_shell", "regolith_shielding", "service_amber"]],
}

var _checks := 0
var _failures := 0


func _initialize() -> void:
	call_deferred("_run")


func _check(condition: bool, detail: String) -> void:
	_checks += 1
	if not condition:
		_failures += 1
		push_error(detail)


func _run() -> void:
	var game = Mission.instantiate()
	root.add_child(game)
	game._set_mode("terminal")
	game._edit("place", 7, "generator")
	for kind: String in ["battery", "greenhouse", "shelter"]:
		game._edit("place", MODELS[kind][0], kind)

	var station: Node3D = game.station
	var wrappers := station.get_node("FacilityWrappers")
	var player: CharacterBody3D = game.player
	await physics_frame
	await physics_frame
	for kind: String in MODELS:
		_check_facility(wrappers, player, kind)

	var corridor := Transform3D(Basis.IDENTITY, Vector3(3.0, 0.02, 3.0))
	_check(not player.test_move(corridor, Vector3(0.0, 0.0, -6.0)),
		"A player can walk between the habitat and greenhouse")
	_check(6.0 - (Rules.footprint("habitat").x + Rules.footprint("greenhouse").x) * 0.5 >= 2.19,
		"The narrow corridor retains 2.2 m between the collision boxes")
	_check_guide(station, player)

	game._commit("")
	game._edit("remove", 13, "")
	_check(wrappers.get_node_or_null("Slot13_greenhouse") == null, "Removing the greenhouse removes its wrapper")
	game._restore(2)
	var restored := wrappers.get_node_or_null("Slot13_greenhouse/Visual") as Node3D
	_check(restored != null and _has_model(restored, "facility_greenhouse"),
		"Rewind restores the greenhouse model for a placement kept in the snapshot")
	game._restore(1)
	_check(wrappers.get_child_count() == 1 and wrappers.has_node("Slot12_habitat"),
		"Rewind to the initial turn removes the placed facility wrappers")
	_check(station.has_node("GuideRobot"), "The guide stays in place across rewinds")

	game.free()
	print("HH-004 expanded models: %d checks, %d failures" % [_checks, _failures])
	quit(1 if _failures else 0)


func _has_model(visual: Node3D, model_name: String) -> bool:
	return visual.get_child_count() == 1 and visual.get_child(0).scene_file_path == _path(model_name)


func _path(model_name: String) -> String:
	return "res://assets/models/" + model_name + ".glb"


func _check_mesh(model: Node3D, size: Vector3, materials: Array) -> MeshInstance3D:
	var nodes := model.find_children("*", "MeshInstance3D", true, false)
	var label := str(model.name)
	_check(nodes.size() == 1, label + ": one mesh instance")
	if nodes.size() != 1:
		return null
	var imported := nodes[0] as MeshInstance3D
	var expected := AABB(Vector3(-size.x * 0.5, 0.0, -size.z * 0.5), size)
	_check(imported.transform.is_equal_approx(Transform3D.IDENTITY) and imported.get_aabb().is_equal_approx(expected),
		label + ": original size, +Y up, and bottom-centered pivot")
	var found: Array = []
	for index in imported.mesh.get_surface_count():
		var material := imported.mesh.surface_get_material(index) as StandardMaterial3D
		if material == null:
			continue
		found.append(material.resource_name)
		if material.resource_name == "glazing_blue":
			_check(is_equal_approx(material.albedo_color.a, 0.26)
				and material.transparency == BaseMaterial3D.TRANSPARENCY_ALPHA_DEPTH_PRE_PASS,
				"Greenhouse glazing retains alpha 0.26 and the depth pre-pass")
	found.sort()
	_check(found == materials, label + ": original material names")
	return imported


func _check_facility(wrappers: Node, player: CharacterBody3D, kind: String) -> void:
	var expected: Array = MODELS[kind]
	var slot: int = expected[0]
	var wrapper := wrappers.get_node_or_null("Slot%02d_%s" % [slot, kind]) as Node3D
	_check(wrapper != null and wrapper.position == Rules.slot_position(slot), kind + ": appears on its assigned slot")
	if wrapper == null:
		return
	var visual := wrapper.get_node("Visual") as Node3D
	var has_model := _has_model(visual, "facility_" + kind)
	_check(has_model, kind + ": station uses the imported GLB")
	if not has_model:
		return
	var model := visual.get_child(0) as Node3D
	_check(model.transform.is_equal_approx(Transform3D.IDENTITY)
		and model.find_children("*", "CollisionObject3D", true, false).is_empty(),
		kind + ": original -Z facing and collision-free GLB scene")
	var imported := _check_mesh(model, expected[1], expected[2])
	var body := wrapper.get_node("Collision") as StaticBody3D
	var nodes := body.find_children("*", "CollisionShape3D", false, false)
	_check(nodes.size() == 1, kind + ": one independent collision shape")
	if imported == null or nodes.size() != 1:
		return
	var shape := (nodes[0] as CollisionShape3D).shape as BoxShape3D
	var volume := AABB(body.position - shape.size * 0.5, shape.size)
	_check(volume.encloses(imported.get_aabb()) and shape.size.x <= 3.8 and shape.size.z <= 3.8,
		kind + ": collision contains the model without intruding into the grid lanes")
	var approach := Transform3D(Basis.IDENTITY, wrapper.position + Vector3(0, 0.02, 2.95))
	var hit := KinematicCollision3D.new()
	_check(player.test_move(approach, Vector3(0, 0, -2.9), hit) and hit.get_collider() == body,
		kind + ": player capsule stops at the wrapper")


func _check_guide(station: Node3D, player: CharacterBody3D) -> void:
	var guide := station.get_node_or_null("GuideRobot") as Node3D
	_check(guide != null and guide.scene_file_path == _path("guide_robot"), "Guide robot is loaded beside the console")
	if guide == null:
		return
	_check_mesh(guide, Vector3(0.755091, 1.462, 0.5245), ["alloy_shell", "equipment_blue", "service_amber"])
	_check((-guide.basis.z).is_equal_approx(Vector3.BACK) and guide.position.x > 1.8 and guide.position.y == 0.0,
		"Guide is set off the approach and faces the incoming player")
	var approach := Transform3D(Basis.IDENTITY, Rules.SPAWN + Vector3(1.4, 0.02, 0.0))
	_check(not player.test_move(approach, Vector3(0, 0, -3.0)), "Console approach stays clear beside the guide")
	_check(guide.find_children("*", "CollisionObject3D", true, false).is_empty(),
		"The GLB keeps its collision separate")
	var body := station.get_node_or_null("GuideRobotCollision") as StaticBody3D
	var front := Transform3D(Basis.IDENTITY, guide.position + Vector3(0.0, 0.02, 1.6))
	var hit := KinematicCollision3D.new()
	_check(body != null and player.test_move(front, Vector3(0.0, 0.0, -1.6), hit)
		and hit.get_collider() == body, "A separate collision box prevents walking through the guide")
	var position: Vector3 = guide.position
	var pose := {"position": [position.x, position.y, position.z]}
	_check(not station.pose_is_safe(pose, {"facilities": []}), "Rewind rejects a pose overlapping the guide")
