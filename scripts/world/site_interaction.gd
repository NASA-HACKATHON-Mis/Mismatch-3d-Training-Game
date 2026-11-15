extends Node3D
## Read-only gaze query. Mission owns input, UI modes and all state changes.
const Rules = preload("res://scripts/simulation/scenario.gd")
const PAD_HALF_SIZE := 2.16
const PAD_HEIGHT := 0.02
var _station: Node3D

func configure(station: Node3D) -> void:
	_station = station

func resolve_target(camera: Camera3D, max_distance: float = 4.0) -> Dictionary:
	if not is_instance_valid(_station) or not is_instance_valid(camera):
		return _none()
	if not _station.is_inside_tree() or not camera.is_inside_tree() or max_distance <= 0.0 or not is_finite(max_distance):
		return _none()
	if camera.get_world_3d() != _station.get_world_3d():
		return _none()
	var origin := camera.global_position
	var direction := -camera.global_basis.z.normalized()
	var excluded: Array[RID] = []
	var ancestor: Node = camera.get_parent()
	while ancestor != null:
		if ancestor is CollisionObject3D:
			excluded.append(ancestor.get_rid())
		ancestor = ancestor.get_parent()
	var query := PhysicsRayQueryParameters3D.create(origin, origin + direction * max_distance, 0xFFFFFFFF, excluded)
	query.hit_from_inside = true
	var hit := camera.get_world_3d().direct_space_state.intersect_ray(query)
	var hit_distance := max_distance + 0.001
	if not hit.is_empty():
		hit_distance = origin.distance_to(hit.position)
	# Pads are visual surfaces, not new collision bodies. Intersect their plane
	# in station space, retaining world distance and the first physics occluder.
	var local_origin := _station.to_local(origin)
	var local_end := _station.to_local(origin + direction)
	var local_direction := local_end - local_origin
	if local_direction.y < -0.00001:
		var t := (PAD_HEIGHT - local_origin.y) / local_direction.y
		if t >= 0.0:
			var point := local_origin + local_direction * t
			var distance := origin.distance_to(_station.to_global(point))
			if distance <= max_distance and distance < hit_distance:
				for slot in Rules.SLOT_COUNT:
					var center: Vector3 = Rules.slot_position(slot)
					if absf(point.x - center.x) <= PAD_HALF_SIZE and absf(point.z - center.z) <= PAD_HALF_SIZE:
						if not _station.interaction_slot_occupied(slot):
							return {"kind": "slot", "slot_id": slot, "prompt": "1 · Build here"}
						break
	if not hit.is_empty():
		return _station.interaction_target_for(hit.collider)
	return _none()

func can_access_slot(camera: Camera3D, slot_id: int, max_distance: float = 4.0) -> bool:
	if slot_id < 0 or slot_id >= Rules.SLOT_COUNT:
		return false
	# Re-query the first visible surface every time. A panel never grants remote
	# access, and a rebuilt mesh at the same site keeps the same site identity.
	var target := resolve_target(camera, max_distance)
	return target.get("kind") == "slot" and target.get("slot_id", -1) == slot_id

func _none() -> Dictionary:
	return {"kind": "none", "slot_id": -1, "prompt": ""}
