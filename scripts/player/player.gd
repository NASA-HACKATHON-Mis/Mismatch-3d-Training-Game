extends CharacterBody3D

const SPEED := 3.0
const MOUSE_SENSITIVITY := 0.0023
const MAX_PITCH := deg_to_rad(80.0)
const WALK_ACTIONS := [&"walk_left", &"walk_right", &"walk_forward", &"walk_back"]
const Rules = preload("res://scripts/simulation/scenario.gd")

@onready var camera: Camera3D = $Camera3D
var exploring := false
var _wait_for_release: Array[StringName] = []


func set_exploring(enabled: bool) -> void:
	_wait_for_release.clear()
	if enabled:
		for action: StringName in WALK_ACTIONS:
			if Input.is_action_pressed(action):
				_wait_for_release.append(action)
	exploring = enabled
	velocity = Vector3.ZERO


func _physics_process(delta: float) -> void:
	if not exploring:
		return
	for action: StringName in _wait_for_release.duplicate():
		if not Input.is_action_pressed(action):
			_wait_for_release.erase(action)
	var axis := Vector2(_strength(&"walk_right") - _strength(&"walk_left"),
		_strength(&"walk_back") - _strength(&"walk_forward")).limit_length()
	var direction := transform.basis * Vector3(axis.x, 0.0, axis.y)
	velocity.x = direction.x * SPEED
	velocity.z = direction.z * SPEED
	if not is_on_floor():
		velocity.y -= 9.8 * delta
	move_and_slide()
	if global_position.y < -3.0:
		apply_pose({"position": [Rules.SPAWN.x, Rules.SPAWN.y, Rules.SPAWN.z], "yaw": 0.0, "pitch": 0.0})


func _strength(action: StringName) -> float:
	return 0.0 if _wait_for_release.has(action) else Input.get_action_strength(action)


func _unhandled_input(event: InputEvent) -> void:
	if exploring and event is InputEventMouseMotion:
		var motion := event as InputEventMouseMotion
		rotation.y = wrapf(rotation.y - motion.screen_relative.x * MOUSE_SENSITIVITY, -PI, PI)
		camera.rotation.x = clampf(camera.rotation.x - motion.screen_relative.y * MOUSE_SENSITIVITY,
			-MAX_PITCH, MAX_PITCH)


func sees_console(console: StaticBody3D) -> bool:
	var eye := camera.global_position
	var end := eye - camera.global_basis.z * 2.0
	var query := PhysicsRayQueryParameters3D.create(eye, end, 1, [get_rid()])
	var hit := get_world_3d().direct_space_state.intersect_ray(query)
	return not hit.is_empty() and hit.collider == console


func pose() -> Dictionary:
	return {"position": [global_position.x, global_position.y, global_position.z],
		"yaw": rotation.y, "pitch": camera.rotation.x}


func apply_pose(saved: Dictionary) -> void:
	var p: Array = saved.position
	global_position = Vector3(p[0], p[1], p[2])
	rotation.y = saved.yaw
	camera.rotation.x = clampf(saved.pitch, -MAX_PITCH, MAX_PITCH)
	velocity = Vector3.ZERO
	_wait_for_release.clear()
	reset_physics_interpolation()
