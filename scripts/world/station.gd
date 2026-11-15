extends Node3D
## Facility scenes supply the visuals. Collision stays in the slot wrapper.

const Rules = preload("res://scripts/simulation/scenario.gd")
const MODEL_DIR := "res://assets/models/"
const GUIDE_POSITION := Rules.CONSOLE + Vector3(2.15, 0.0, 0.2)
const GUIDE_SIZE := Vector3(0.76, 1.47, 0.53)
const INK := Color("#121d2d")
const ALLOY := Color("#c3d0d9")
const AMBER := Color("#ffc16f")
const CYAN := Color("#55e5dc")
const GREEN := Color("#99d77d")
const VIOLET := Color("#ae95f1")
const COLORS := {"habitat": CYAN, "generator": AMBER, "battery": VIOLET,
	"greenhouse": GREEN, "shelter": Color("#8dbfff")}

var console: StaticBody3D
var _wrappers := Node3D.new()
var _materials := {}
var _facility_models: Dictionary[String, PackedScene] = {}
var _guide_collision: StaticBody3D


func _ready() -> void:
	for kind: String in COLORS:
		var model := _load_model("facility_" + kind)
		if model != null:
			_facility_models[kind] = model
	_atmosphere()
	_terrain()
	_deck()
	_create_console()
	_create_guide_robot()
	_wrappers.name = "FacilityWrappers"
	add_child(_wrappers)


func _atmosphere() -> void:
	var world := WorldEnvironment.new()
	var settings := Environment.new()
	settings.background_mode = Environment.BG_COLOR
	settings.background_color = Color("#070d1b")
	settings.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	settings.ambient_light_color = Color("#b9ccff")
	settings.ambient_light_energy = 0.48
	world.environment = settings
	add_child(world)
	var sun := DirectionalLight3D.new()
	sun.rotation_degrees = Vector3(-31, -36, 0)
	sun.light_color = Color("#ffdec4")
	sun.light_energy = 1.18
	sun.shadow_enabled = true
	sun.directional_shadow_max_distance = 50.0
	add_child(sun)
	var rng := RandomNumberGenerator.new()
	rng.seed = 32
	var star_mesh := SphereMesh.new()
	star_mesh.radius = 0.12
	star_mesh.height = 0.24
	star_mesh.radial_segments = 5
	star_mesh.rings = 3
	star_mesh.material = _mat(Color("#dce6ff"), true)
	var stars := MultiMesh.new()
	stars.transform_format = MultiMesh.TRANSFORM_3D
	stars.mesh = star_mesh
	stars.instance_count = 165
	for index in stars.instance_count:
		var azimuth := rng.randf_range(-PI, PI)
		var elevation := rng.randf_range(0.015, 1.5)
		var point := Vector3(cos(azimuth) * cos(elevation), sin(elevation), sin(azimuth) * cos(elevation)) * 160
		stars.set_instance_transform(index, Transform3D(Basis.IDENTITY.scaled(Vector3.ONE * rng.randf_range(0.7, 1.6)), point))
	var sky_mesh := MultiMeshInstance3D.new()
	sky_mesh.multimesh = stars
	sky_mesh.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	add_child(sky_mesh)
	_sphere(self, Vector3(-38, 26, -118), Vector3.ONE * 8.5, Color("#5591d2"), true)
	_sphere(self, Vector3(-36.8, 27.6, -114.6), Vector3(2.6, 1.1, 1.0), Color("#b5dad6"), true)
	_sphere(self, Vector3(-40.2, 25.1, -114.5), Vector3(1.8, 0.7, 1.0), Color("#b5dad6"), true)


func _terrain() -> void:
	_body(self, "Regolith", Vector3(0, -0.48, 0), Vector3(126, 0.6, 126), Color("#4c5360"))
	var rng := RandomNumberGenerator.new()
	rng.seed = 74
	for i in 52:
		var angle := rng.randf_range(-PI, PI)
		var distance := rng.randf_range(28, 59)
		var scale := rng.randf_range(0.4, 2.6)
		_sphere(self, Vector3(cos(angle) * distance, -0.22, sin(angle) * distance),
			Vector3(1.2, 0.58, 0.9) * scale, Color("#555a66").darkened(rng.randf_range(0, 0.26)))
	# Keep a distant ridgeline and a contained training area.
	for i in 16:
		_sphere(self, Vector3(i * 8 - 60, -1.4, -60 - (i % 3) * 3),
			Vector3(15, 3 + (i % 5), 11), Color("#343e53"))
	_collider(self, "WestBoundary", Vector3(-19.0, 1.5, 3.0), Vector3(0.5, 3.0, 42.0))
	_collider(self, "EastBoundary", Vector3(19.0, 1.5, 3.0), Vector3(0.5, 3.0, 42.0))
	_collider(self, "NorthBoundary", Vector3(0.0, 1.5, -17.5), Vector3(38.0, 3.0, 0.5))
	_collider(self, "SouthBoundary", Vector3(0.0, 1.5, 23.5), Vector3(38.0, 3.0, 0.5))


func _deck() -> void:
	_body(self, "Deck", Vector3(0, -0.15, 3), Vector3(34, 0.3, 36), Color("#293747"))
	# The terrain is 18 cm below the deck. Continuous ramps preserve walking
	# access at every edge, including corners, without adding a jump/teleport.
	_deck_ramp("SouthRamp", [Vector3(-17, 0, 21), Vector3(17, 0, 21), Vector3(18, -0.18, 22), Vector3(-18, -0.18, 22)])
	_deck_ramp("NorthRamp", [Vector3(17, 0, -15), Vector3(-17, 0, -15), Vector3(-18, -0.18, -16), Vector3(18, -0.18, -16)])
	_deck_ramp("EastRamp", [Vector3(17, 0, 21), Vector3(17, 0, -15), Vector3(18, -0.18, -16), Vector3(18, -0.18, 22)])
	_deck_ramp("WestRamp", [Vector3(-17, 0, -15), Vector3(-17, 0, 21), Vector3(-18, -0.18, 22), Vector3(-18, -0.18, -16)])
	for i in range(-3, 4):
		_box(self, Vector3(i * 4.8, 0.004, 16.0), Vector3(2.25, 0.008, 0.06), CYAN, true)
	for x: float in [-16.6, 16.6]:
		_box(self, Vector3(x, 0.02, 2.5), Vector3(0.09, 0.04, 34.7), AMBER, true)
		for z: float in [-14.6, -5.0, 5.0, 15.0, 20.5]:
			_box(self, Vector3(x, 0.35, z), Vector3(0.18, 0.7, 0.18), INK)
			_box(self, Vector3(x, 0.72, z), Vector3(0.27, 0.1, 0.27), AMBER, true)
	for id in Rules.SLOT_COUNT:
		var slot := Rules.slot_position(id)
		var shade := Color("#384959")
		if Rules.SUNLIT.has(id):
			shade = Color("#655548")
		elif Rules.SHIELDED.has(id):
			shade = Color("#405976")
		_box(self, slot + Vector3(0, 0.003, 0), Vector3(4.32, 0.006, 4.32), shade)
		var border := shade.lightened(0.28)
		for direction: float in [-1.0, 1.0]:
			_box(self, slot + Vector3(0, 0.009, direction * 2.12), Vector3(4.28, 0.012, 0.04), border)
			_box(self, slot + Vector3(direction * 2.12, 0.009, 0), Vector3(0.04, 0.012, 4.28), border)
		for x: float in [-1.9, 1.9]:
			_box(self, slot + Vector3(x, 0.015, 1.92), Vector3(0.17, 0.014, 0.13), border, true)
		_sign(self, "%02d" % (id + 1), slot + Vector3(0, 0.017, 1.88), Color("#b8c5d3"), 32, 0.014, true)


func _deck_ramp(label: String, top: Array) -> void:
	var body := StaticBody3D.new()
	body.name = label
	var points := PackedVector3Array()
	for point: Vector3 in top:
		points.append(point)
		points.append(Vector3(point.x, -0.3, point.z))
	var shape := ConvexPolygonShape3D.new()
	shape.points = points
	var collider := CollisionShape3D.new()
	collider.shape = shape
	body.add_child(collider)
	var surface := SurfaceTool.new()
	surface.begin(Mesh.PRIMITIVE_TRIANGLES)
	for index: int in [0, 1, 2, 0, 2, 3]:
		surface.add_vertex(top[index])
	surface.generate_normals()
	var visual := MeshInstance3D.new()
	visual.mesh = surface.commit()
	visual.material_override = _mat(Color("#354556"), false)
	body.add_child(visual)
	add_child(body)


func _create_console() -> void:
	var frame := Node3D.new()
	frame.name = "TerminalRig"
	frame.position = Rules.CONSOLE
	add_child(frame)
	console = _collider(frame, "ConsoleInteraction", Vector3(0, 1.04, 0), Vector3(1.6, 2.08, 0.7))
	_box(frame, Vector3(0, 0.1, 0), Vector3(1.62, 0.2, 0.8), ALLOY)
	_box(frame, Vector3(0, 0.7, 0), Vector3(0.62, 1.25, 0.53), INK)
	_box(frame, Vector3(0, 1.58, 0), Vector3(1.56, 0.86, 0.5), ALLOY)
	_box(frame, Vector3(0, 1.58, 0.273), Vector3(1.4, 0.7, 0.05), Color("#0b2837"))
	_box(frame, Vector3(0, 1.28, 0.31), Vector3(1.23, 0.035, 0.022), CYAN, true)
	_sign(frame, "MISSION OPS", Vector3(0, 1.70, 0.31), CYAN, 28, 0.005)
	_sign(frame, "01   /   ONLINE", Vector3(0, 1.47, 0.31), Color("#a3d8df"), 17, 0.005)
	for x: float in [-0.91, 0.91]:
		_box(frame, Vector3(x, 1.28, 0.03), Vector3(0.08, 1.1, 0.08), INK)
		_box(frame, Vector3(x, 1.84, 0.03), Vector3(0.12, 0.18, 0.12), CYAN, true)


func sync_facilities(state: Dictionary) -> void:
	for child: Node in _wrappers.get_children():
		_wrappers.remove_child(child)
		child.queue_free()
	for facility: Dictionary in state.facilities:
		_facility(facility)


func _load_model(model_name: String) -> PackedScene:
	var path := MODEL_DIR + model_name + ".glb"
	if not ResourceLoader.exists(path, "PackedScene"):
		return null
	return ResourceLoader.load(path, "PackedScene") as PackedScene


func _create_guide_robot() -> void:
	var scene := _load_model("guide_robot")
	if scene == null:
		return
	var robot := scene.instantiate() as Node3D
	robot.name = "GuideRobot"
	robot.position = GUIDE_POSITION
	# The source faces -Z. Turn it toward the entrance on the +Z side.
	robot.rotation.y = PI
	add_child(robot)
	_guide_collision = _collider(self, "GuideRobotCollision", GUIDE_POSITION + Vector3.UP * GUIDE_SIZE.y * 0.5,
		GUIDE_SIZE)


func _facility(facility: Dictionary) -> void:
	var kind: String = facility.type
	var id: int = facility.slot_id
	var tint: Color = COLORS[kind]
	var wrapper := Node3D.new()
	wrapper.name = "Slot%02d_%s" % [id, kind]
	wrapper.position = Rules.slot_position(id)
	wrapper.set_meta("slot_id", id)
	wrapper.set_meta("instance_id", facility.instance_id)
	_wrappers.add_child(wrapper)
	var size := Rules.footprint(kind)
	_collider(wrapper, "Collision", Vector3(0, size.y * 0.5, 0), size)
	var model := Node3D.new()
	model.name = "Visual"
	wrapper.add_child(model)
	if _facility_models.has(kind):
		model.add_child(_facility_models[kind].instantiate())
		return
	_box(model, Vector3(0, 0.09, 0), Vector3(size.x, 0.18, size.z), INK)
	_box(model, Vector3(0, 0.19, size.z * 0.49), Vector3(size.x * 0.84, 0.07, 0.05), tint, true)
	match kind:
		"generator":
			_box(model, Vector3(0, 0.62, 0), Vector3(0.5, 1.0, 0.6), ALLOY)
			var mount := Node3D.new()
			mount.position = Vector3(0, 1.42, 0)
			mount.rotation_degrees.x = -24
			model.add_child(mount)
			_box(mount, Vector3.ZERO, Vector3(3.42, 0.16, 2.88), tint.darkened(0.45))
			for x in 4:
				for z in 3:
					_box(mount, Vector3((x - 1.5) * 0.8, 0.09, (z - 1.0) * 0.88),
						Vector3(0.76, 0.04, 0.81), Color("#263e75"))
			_box(model, Vector3(0, 0.47, 1.05), Vector3(1.14, 0.55, 0.52), ALLOY)
		"battery":
			for x: float in [-0.72, 0.72]:
				_box(model, Vector3(x, 0.77, 0), Vector3(1.23, 1.23, 2.38), ALLOY)
				_box(model, Vector3(x, 1.43, 0), Vector3(0.63, 0.16, 1.84), tint)
				_box(model, Vector3(x, 0.95, 1.21), Vector3(0.74, 0.12, 0.035), tint, true)
		"greenhouse":
			_box(model, Vector3(0, 0.66, 0), Vector3(3.72, 1.02, 3.32), ALLOY)
			_sphere(model, Vector3(0, 1.30, 0), Vector3(3.55, 2.12, 3.19), tint.darkened(0.31))
			for x: float in [-1.32, 0.0, 1.32]:
				_box(model, Vector3(x, 0.85, 1.682), Vector3(0.22, 0.42, 0.035), INK)
		"shelter":
			_box(model, Vector3(0, 0.78, 0), Vector3(3.49, 1.38, 3.66), Color("#8299ac"))
			_box(model, Vector3(0, 1.75, -0.14), Vector3(2.91, 0.66, 3.04), ALLOY)
			_box(model, Vector3(0, 0.91, 1.85), Vector3(1.5, 1.45, 0.06), INK)
			_box(model, Vector3(0, 1.32, 1.9), Vector3(0.88, 0.09, 0.035), tint, true)
		_:
			_box(model, Vector3(0, 1.21, 0), Vector3(3.75, 2.08, 3.52), ALLOY)
			_box(model, Vector3(0, 2.36, 0), Vector3(3.22, 0.2, 2.93), INK)
			_box(model, Vector3(0, 1.01, 1.79), Vector3(1.38, 1.68, 0.07), INK)
			for x: float in [-1.24, 1.24]:
				_box(model, Vector3(x, 1.51, 1.79), Vector3(0.81, 0.47, 0.07), Color("#284454"))
			_box(model, Vector3(1.13, 2.46, -0.83), Vector3(0.075, 0.42, 0.075), tint, true)
	var tag: String = {"habitat": "HAB", "generator": "SOL", "battery": "BAT",
		"greenhouse": "GROW", "shelter": "SAFE"}[kind]
	_sign(model, tag, Vector3(0, 0.35, size.z * 0.5 + 0.02), tint, 32, 0.007)


func pose_is_safe(pose: Dictionary, state: Dictionary) -> bool:
	var p: Array = pose.position
	if absf(p[0]) > 18.4 or p[1] < -0.1 or p[2] < -17 or p[2] > 23:
		return false
	if absf(p[0]) < 1.1 and absf(float(p[2]) - Rules.CONSOLE.z) < 0.65:
		return false
	if _guide_collision != null and p[1] < GUIDE_SIZE.y and p[1] + 1.8 > 0.0:
		var x := maxf(absf(float(p[0]) - GUIDE_POSITION.x) - GUIDE_SIZE.x * 0.5, 0.0)
		var z := maxf(absf(float(p[2]) - GUIDE_POSITION.z) - GUIDE_SIZE.z * 0.5, 0.0)
		if x * x + z * z < 0.09:
			return false
	for facility: Dictionary in state.facilities:
		if Rules.facility_overlaps_player(facility.type, facility.slot_id, pose):
			return false
	return true


func _mat(color: Color, glow: bool) -> StandardMaterial3D:
	var key := color.to_html() + str(glow)
	if not _materials.has(key):
		var material := StandardMaterial3D.new()
		material.albedo_color = color
		material.roughness = 0.88
		if glow:
			material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		_materials[key] = material
	return _materials[key]


func _box(parent: Node3D, at: Vector3, size: Vector3, color: Color, glow := false) -> void:
	var mesh := BoxMesh.new()
	mesh.size = size
	var item := MeshInstance3D.new()
	item.mesh = mesh
	item.position = at
	item.material_override = _mat(color, glow)
	parent.add_child(item)


func _sphere(parent: Node3D, at: Vector3, size: Vector3, color: Color, glow := false) -> void:
	var mesh := SphereMesh.new()
	mesh.radius = 0.5
	mesh.height = 1.0
	mesh.radial_segments = 12
	mesh.rings = 6
	var item := MeshInstance3D.new()
	item.mesh = mesh
	item.position = at
	item.scale = size
	item.material_override = _mat(color, glow)
	if glow:
		item.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	parent.add_child(item)


func _collider(parent: Node3D, label: String, at: Vector3, size: Vector3) -> StaticBody3D:
	var body := StaticBody3D.new()
	body.name = label
	body.position = at
	var shape := BoxShape3D.new()
	shape.size = size
	var collision := CollisionShape3D.new()
	collision.shape = shape
	body.add_child(collision)
	parent.add_child(body)
	return body


func _body(parent: Node3D, label: String, at: Vector3, size: Vector3, color: Color) -> void:
	var body := _collider(parent, label, at, size)
	_box(body, Vector3.ZERO, size, color)


func _sign(parent: Node3D, label: String, at: Vector3, color: Color, font_size: int,
		pixel_size: float, flat := false) -> void:
	var text := Label3D.new()
	text.text = label
	text.font_size = font_size
	text.pixel_size = pixel_size
	text.outline_size = 0
	text.modulate = color
	text.position = at
	if flat:
		text.rotation_degrees.x = -90
	parent.add_child(text)
