extends SceneTree
const Fixture = preload("res://scripts/simulation/tests/ui_fixture.gd")
## Checks the teammate's imported model as rendered by the actual station.

const Mission = preload("res://scenes/main.tscn")
const Rules = preload("res://scripts/simulation/scenario.gd")
const Generator = preload("res://assets/models/facility_generator.glb")
const ScaleCube = preload("res://assets/models/scale_reference_1m.glb")

var _checks := 0
var _failures := 0


func _initialize() -> void:
	call_deferred("_run")


func _check(condition: bool, detail: String) -> void:
	_checks += 1
	if not condition:
		_failures += 1
		push_error(detail)


func _mesh_node(model: Node3D) -> MeshInstance3D:
	var meshes := model.find_children("*", "MeshInstance3D", true, false)
	_check(meshes.size() == 1, "Expected one imported mesh in " + str(model.name))
	return meshes[0] as MeshInstance3D if meshes.size() == 1 else null


func _material_vertices(mesh: Mesh, material_name: String) -> PackedVector3Array:
	for index in mesh.get_surface_count():
		var material := mesh.surface_get_material(index)
		if material != null and material.resource_name == material_name:
			return mesh.surface_get_arrays(index)[Mesh.ARRAY_VERTEX]
	return PackedVector3Array()


func _run() -> void:
	var cube := ScaleCube.instantiate() as Node3D
	root.add_child(cube)
	var reference := _mesh_node(cube)
	if reference != null:
		_check(cube.transform.is_equal_approx(Transform3D.IDENTITY)
			and reference.transform.is_equal_approx(Transform3D.IDENTITY), "Scale cube needs no transform")
		_check(reference.get_aabb().is_equal_approx(AABB(Vector3(-0.5, 0, -0.5), Vector3.ONE)),
			"Scale cube is 1 m, with a bottom-centered pivot")
		var arrow := _material_vertices(reference.mesh, "service_amber")
		_check(not arrow.is_empty() and Array(arrow).all(func(vertex: Vector3): return is_equal_approx(vertex.z, -0.5)),
			"Cube front marker faces -Z")
	cube.free()

	var game = Mission.instantiate()
	root.add_child(game)
	game._set_mode("terminal")
	Fixture.edit(game, "place", 17, "generator")
	Fixture.edit(game, "place", 18, "generator")
	var station: Node3D = game.station
	var first := station.get_node_or_null("FacilityWrappers/Slot17_generator") as Node3D
	var second := station.get_node_or_null("FacilityWrappers/Slot18_generator") as Node3D
	_check(first != null and second != null, "Adjacent generator slots populate in the actual game")
	if first != null and second != null:
		await _check_generators(first, second, game.player)
	_check(station.get_node_or_null("FacilityWrappers/Slot12_habitat/Visual") != null,
		"Other facilities retain their visual fallback")
	game.free()
	print("HH-004 generator: %d checks, %d failures" % [_checks, _failures])
	quit(1 if _failures else 0)


func _check_generators(first: Node3D, second: Node3D, player: CharacterBody3D) -> void:
	var first_position := Rules.slot_position(17)
	var second_position := Rules.slot_position(18)
	_check(first.position == first_position and second.position == second_position, "Slot origins remain unchanged")
	var visual := first.get_node("Visual") as Node3D
	_check(visual.get_child_count() == 1, "Only the imported generator is drawn in its wrapper")
	if visual.get_child_count() != 1:
		return
	var model := visual.get_child(0) as Node3D
	_check(model.scene_file_path == Generator.resource_path and model.transform.is_equal_approx(Transform3D.IDENTITY),
		"Station uses the original generator GLB at unit scale and the contract orientation")
	var imported := _mesh_node(model)
	if imported == null:
		return
	var bounds := imported.get_aabb()
	_check(imported.transform.is_equal_approx(Transform3D.IDENTITY)
		and bounds.is_equal_approx(AABB(Vector3(-1.8, 0, -1.6), Vector3(3.6, 2.592986, 3.2))),
		"Generator bounds preserve bottom center, +Y up, and the manifest dimensions")
	_check(imported.mesh.get_surface_count() == 3, "Generator's three imported material surfaces are retained")
	# The amber surface also colors details on the back. Locate the inverter
	# face on the lower center, away from the perimeter trim and panel frame.
	var panel := _material_vertices(imported.mesh, "service_amber")
	_check(Array(panel).any(func(vertex: Vector3):
		return absf(vertex.x) < 0.85 and vertex.y < 1.05 and vertex.z < -0.94),
		"Generator's amber inverter face remains on -Z")
	_check(model.find_children("*", "CollisionObject3D", true, false).is_empty(), "Imported mesh has no collision objects")

	var body := first.get_node("Collision") as StaticBody3D
	var shapes := body.find_children("*", "CollisionShape3D", false, false)
	_check(shapes.size() == 1, "Wrapper has one separate collision shape")
	if shapes.size() != 1:
		return
	var shape := shapes[0] as CollisionShape3D
	var box := shape.shape as BoxShape3D
	var volume := AABB(body.position - box.size * 0.5, box.size)
	_check(box.size.is_equal_approx(Vector3(3.6, 2.6, 3.4)) and volume.encloses(bounds),
		"Independent box collider encloses the complete generator")
	_check(is_equal_approx(second_position.x - first_position.x - box.size.x, 2.4),
		"Adjacent arrays leave a 2.4 m passage")
	await physics_frame
	await physics_frame
	var corridor := Transform3D(Basis.IDENTITY, (first_position + second_position) * 0.5 + Vector3(0, 0.02, 3))
	var obstruction := KinematicCollision3D.new()
	_check(not player.test_move(corridor, Vector3(0, 0, -6), obstruction),
		"The actual player capsule can traverse the full passage between arrays")
	var approach := Transform3D(Basis.IDENTITY, first_position + Vector3(0, 0.02, 3))
	_check(player.test_move(approach, Vector3(0, 0, -3), obstruction) and obstruction.get_collider() == body,
		"The actual player capsule hits the generator wrapper when approaching its face")
