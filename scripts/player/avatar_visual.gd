extends Node3D
## Visual-only child of the player's yaw root (never the pitched Camera3D).
## Integration calls update_motion explicitly; there is no autonomous animation.

var _phase := 0.0
var _arms: Array[Node3D] = []
var _legs: Array[Node3D] = []
var obstacle_near := false


func _ready() -> void:
	var suit := _material(Color("e7edf0"))
	var joint := _material(Color("34475a"))
	var stripe := _material(Color("e8a347"))
	# Shadow-only closed volumes: a full silhouette without a camera-facing head
	# or torso surface intersecting the first-person view.
	_box(self, Vector3(0.48, 0.62, 0.32), Vector3(0, 1.13, 0.06), suit, true)
	_box(self, Vector3(0.34, 0.36, 0.34), Vector3(0, 1.62, 0.04), suit, true)
	for side: float in [-1.0, 1.0]:
		var arm := Node3D.new()
		arm.position = Vector3(side * 0.36, 1.60, -0.16)
		arm.scale = Vector3(0.75, 0.85, 1.3)
		add_child(arm)
		_arms.append(arm)
		_box(arm, Vector3(0.18, 0.27, 0.19), Vector3(0, -0.12, 0.24), suit)
		_box(arm, Vector3(0.17, 0.12, 0.17), Vector3(0, -0.25, 0.10), joint)
		_box(arm, Vector3(0.17, 0.16, 0.31), Vector3(0, -0.27, -0.19), suit)
		_box(arm, Vector3(0.18, 0.17, 0.05), Vector3(0, -0.27, -0.33), stripe)
		_box(arm, Vector3(0.16, 0.14, 0.15), Vector3(0, -0.28, -0.42), joint)
		var leg := Node3D.new()
		leg.position = Vector3(side * 0.15, 0.85, 0.04)
		add_child(leg)
		_legs.append(leg)
		_box(leg, Vector3(0.23, 0.32, 0.24), Vector3(0, -0.16, 0), suit)
		_box(leg, Vector3(0.22, 0.10, 0.23), Vector3(0, -0.36, 0), joint)
		_box(leg, Vector3(0.22, 0.29, 0.23), Vector3(0, -0.55, 0), suit)
		_box(leg, Vector3(0.23, 0.05, 0.24), Vector3(0, -0.68, 0), stripe)
		_box(leg, Vector3(0.25, 0.15, 0.48), Vector3(0, -0.76, -0.20), joint)


func update_motion(local_velocity: Vector3, grounded: bool, active: bool, delta: float) -> void:
	if not active or _arms.is_empty():
		return
	var speed := Vector2(local_velocity.x, local_velocity.z).length()
	var swing := 0.0
	if grounded and speed > 0.05:
		_phase = fmod(_phase + maxf(delta, 0.0) * minf(speed, 3.0) * 3.2, TAU)
		swing = sin(_phase) * 0.10 * minf(speed / 3.0, 1.0)
	else:
		_phase = 0.0
	for index in range(2):
		var sign_value := -1.0 if index == 0 else 1.0
		_arms[index].rotation.x = sign_value * swing if grounded else -0.22
		_legs[index].rotation.x = -sign_value * swing if grounded else 0.24
		if obstacle_near: _arms[index].rotation = Vector3.ZERO


func set_obstacle_near(blocked: bool) -> void:
	obstacle_near = blocked
	for index in range(_arms.size()):
		var side := -1.0 if index == 0 else 1.0
		# Snap inward before any wall crossing; retained inside the existing capsule.
		_arms[index].position = Vector3(side * 0.17, 1.40, 0.04) if blocked else Vector3(side * 0.36, 1.60, -0.16)
		_arms[index].scale = Vector3(0.65, 0.85, 0.35) if blocked else Vector3(0.75, 0.85, 1.3)
		if blocked: _arms[index].rotation = Vector3.ZERO


func set_view_pitch(pitch: float) -> void:
	# Lowered view keeps the legs readable instead of looking through nearby arms.
	# Their world-space shadows remain present.
	for arm in _arms:
		for mesh in arm.get_children():
			mesh.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_SHADOWS_ONLY if pitch < deg_to_rad(-35.0) else GeometryInstance3D.SHADOW_CASTING_SETTING_ON


func _material(color: Color) -> StandardMaterial3D:
	var material := StandardMaterial3D.new()
	material.albedo_color = color
	material.roughness = 0.85
	return material


func _box(parent: Node3D, size: Vector3, center: Vector3, material: Material, shadow_only: bool = false) -> void:
	var instance := MeshInstance3D.new()
	var mesh := BoxMesh.new()
	mesh.size = size
	instance.mesh = mesh
	instance.material_override = material
	instance.position = center
	if shadow_only: instance.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_SHADOWS_ONLY
	parent.add_child(instance)
