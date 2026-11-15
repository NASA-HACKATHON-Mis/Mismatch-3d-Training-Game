extends Node3D
## Connected visual-only body, anchored to the player's yaw rather than camera pitch.
## Integration calls update_motion explicitly; there is no autonomous animation.

var _phase := 0.0
var _arms: Array[Node3D] = []
var _legs: Array[Node3D] = []
var _arm_parts: Array[Dictionary] = []
var obstacle_near := false
var _pitch := 0.0
var _swing := 0.0
var _grounded := true


func _ready() -> void:
	var suit := _material(Color("e7edf0"))
	var joint := _material(Color("34475a"))
	var stripe := _material(Color("e8a347"))
	# The eye sits just in front of the chest so looking down shows its outside.
	_box(self, Vector3(0.44, 0.58, 0.24), Vector3(0, 1.13, 0.15), suit).name = "Torso"
	_box(self, Vector3(0.43, 0.13, 0.24), Vector3(0, 0.87, 0.15), joint).name = "Waist"
	_box(self, Vector3(0.30, 0.07, 0.025), Vector3(0, 1.17, 0.017), stripe)
	# The camera is inside the helmet; only its external shadow is rendered.
	_box(self, Vector3(0.34, 0.36, 0.34), Vector3(0, 1.62, 0.04), suit, true).name = "HeadShadow"
	for side: float in [-1.0, 1.0]:
		var arm := Node3D.new()
		arm.name = "LeftArm" if side < 0 else "RightArm"
		add_child(arm)
		_arms.append(arm)
		_arm_parts.append({
			"upper": _box(arm, Vector3.ONE, Vector3.ZERO, suit),
			"elbow": _box(arm, Vector3.ONE * 0.165, Vector3.ZERO, joint),
			"forearm": _box(arm, Vector3.ONE, Vector3.ZERO, suit),
			"cuff": _box(arm, Vector3(0.17, 0.06, 0.17), Vector3.ZERO, stripe),
			"hand": _box(arm, Vector3(0.16, 0.15, 0.17), Vector3.ZERO, joint),
		})
		var leg := Node3D.new()
		leg.name = "LeftLeg" if side < 0 else "RightLeg"
		leg.position = Vector3(side * 0.12, 0.85, 0.16)
		add_child(leg)
		_legs.append(leg)
		_box(leg, Vector3(0.23, 0.34, 0.25), Vector3(0, -0.16, 0), suit)
		_box(leg, Vector3(0.23, 0.12, 0.25), Vector3(0, -0.35, 0), joint)
		_box(leg, Vector3(0.22, 0.31, 0.24), Vector3(0, -0.55, 0), suit)
		_box(leg, Vector3(0.23, 0.06, 0.25), Vector3(0, -0.68, 0), stripe)
		_box(leg, Vector3(0.25, 0.15, 0.40), Vector3(0, -0.76, -0.10), joint)
	_apply_pose()


func update_motion(local_velocity: Vector3, grounded: bool, active: bool, delta: float) -> void:
	if not active or _arms.is_empty():
		return
	var speed := Vector2(local_velocity.x, local_velocity.z).length()
	_swing = 0.0
	if grounded and speed > 0.05:
		_phase = fmod(_phase + maxf(delta, 0.0) * minf(speed, 3.0) * 3.2, TAU)
		_swing = sin(_phase) * 0.08 * minf(speed / 3.0, 1.0)
	else:
		_phase = 0.0
	_grounded = grounded
	_apply_pose()


func set_obstacle_near(blocked: bool) -> void:
	obstacle_near = blocked
	_apply_pose()


func set_view_pitch(pitch: float) -> void:
	_pitch = clampf(pitch, deg_to_rad(-65.0), deg_to_rad(75.0))
	_apply_pose()


func _apply_pose() -> void:
	for index in range(_arms.size()):
		var side := -1.0 if index == 0 else 1.0
		var arm := _arms[index]
		arm.position = Vector3(side * (0.18 if obstacle_near else 0.26), 1.40, 0.02)
		arm.rotation.x = 0.0 if obstacle_near else side * _swing + (0.0 if _grounded else 0.08)
		# Hands follow the gaze, while shoulders remain attached to the torso.
		# At a wall, fold the connected limbs down without hiding or scaling the rig.
		var hand_target: Vector3
		if obstacle_near:
			hand_target = Vector3(0, 0.20, -0.02) + Vector3(0, -0.14, -0.17).rotated(Vector3.RIGHT, _pitch)
		else:
			var pitch_follow := _pitch * (1.05 if _pitch > 0.0 else 0.8)
			hand_target = Vector3(0, -0.08, -0.56).rotated(Vector3.RIGHT, pitch_follow)
		var direction := hand_target.normalized()
		var distance := clampf(hand_target.length(), 0.06, 0.589)
		var reach := (0.27 * 0.27 - 0.32 * 0.32 + distance * distance) / (2.0 * distance)
		var bend := Vector3.DOWN
		bend = (bend - direction * bend.dot(direction)).normalized()
		if bend.length_squared() < 0.001:
			bend = Vector3.BACK
		var elbow := direction * reach + bend * sqrt(maxf(0.0, 0.27 * 0.27 - reach * reach))
		if obstacle_near:
			elbow.z = clampf(elbow.z, -0.10, 0.10)
		var parts := _arm_parts[index]
		_segment(parts.upper, Vector3.ZERO, elbow, 0.18)
		parts.elbow.position = elbow
		_segment(parts.forearm, elbow, hand_target, 0.16)
		parts.cuff.position = hand_target.lerp(elbow, 0.13)
		parts.cuff.quaternion = Quaternion(Vector3.UP, (hand_target - elbow).normalized())
		parts.hand.position = hand_target
		parts.hand.quaternion = parts.cuff.quaternion
		_legs[index].rotation.x = -side * _swing if _grounded else 0.18


func _segment(instance: MeshInstance3D, start: Vector3, end: Vector3, width: float) -> void:
	var direction := end - start
	instance.mesh.size = Vector3(width, direction.length() + 0.035, width)
	instance.position = (start + end) * 0.5
	instance.quaternion = Quaternion(Vector3.UP, direction.normalized())


func _material(color: Color) -> StandardMaterial3D:
	var material := StandardMaterial3D.new()
	material.albedo_color = color
	material.roughness = 0.85
	return material


func _box(parent: Node3D, size: Vector3, center: Vector3, material: Material, shadow_only: bool = false) -> MeshInstance3D:
	var instance := MeshInstance3D.new()
	var mesh := BoxMesh.new()
	mesh.size = size
	instance.mesh = mesh
	instance.material_override = material
	instance.position = center
	if shadow_only:
		instance.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_SHADOWS_ONLY
	parent.add_child(instance)
	return instance
