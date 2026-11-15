extends SceneTree
const Rules = preload("res://scripts/simulation/scenario.gd")
const Session = preload("res://scripts/simulation/snapshot_store.gd")
const SitePanel = preload("res://scripts/ui/site_panel.gd")
const HUD = preload("res://scripts/ui/hud.gd")
const Station = preload("res://scripts/world/station.gd")
const Interaction = preload("res://scripts/world/site_interaction.gd")
var checks := 0
var failures := 0
var requests: Array = []

func _initialize() -> void:
	call_deferred("_run")

func check(value: bool, label: String) -> void:
	checks += 1
	if not value:
		failures += 1
		push_error(label)

func _run() -> void:
	var viewport := SubViewport.new()
	viewport.size = Vector2i(1280, 800)
	viewport.own_world_3d = true
	viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	root.add_child(viewport)
	var station = Station.new()
	viewport.add_child(station)
	var session = Session.new(Rules.new())
	station.sync_facilities(session.state)
	var camera := Camera3D.new()
	viewport.add_child(camera)
	camera.current = true
	camera.position = Vector3(-6, 1.7, 3)
	camera.look_at(Vector3(-6, 0.02, 1))
	var interaction = Interaction.new()
	viewport.add_child(interaction)
	interaction.configure(station)
	var hud = HUD.new()
	hud.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	viewport.add_child(hud)
	hud.refresh(session.state)
	hud.show_mode("explore")
	var panel = SitePanel.new()
	viewport.add_child(panel)
	panel.edited.connect(func(action, slot, kind): requests.append([action, slot, kind]))
	await physics_frame
	await physics_frame
	var target: Dictionary = interaction.resolve_target(camera)
	check(interaction.can_access_slot(camera, 11), "Nearby visible pad grants its own site access")
	check(not interaction.can_access_slot(camera, 10), "A different site cannot use the open panel")
	check(not interaction.can_access_slot(camera, 11, 0.5), "Surface range revalidation rejects remote access")
	check(not interaction.can_access_slot(camera, -1), "Invalid site fails closed")
	hud.set_site_target(target, session.state)
	station.show_interaction_target(target, session.state)
	await process_frame
	check(hud._status_box.visible and hud._site_buttons.edit.visible, "Empty site has short square action menu")
	check(hud._site_buttons.inspect.disabled, "Empty site has no building inspection action")
	check(station._interaction_highlight.visible and station._interaction_highlight.get_child_count() == 8, "Empty site highlights pad corners")
	check(hud._status_box.size.x <= 448 and hud._status_box.size.y < 160, "Nearby menu replaces the full width notification bar")
	if "--render" in OS.get_cmdline_user_args():
		await _capture(viewport, "field-hover.png")
	var before: Dictionary = session.state.duplicate(true)
	hud.show_mode("field")
	panel.open_site(session, 11, "edit")
	panel._place_selected()
	check(requests.is_empty(), "Opening a menu does not grant action permission")
	panel.set_access_allowed(true)
	panel._select_kind("battery")
	check(session.state == before and session.draft.is_empty(), "Selection never changes simulation state")
	panel._place_selected()
	check(requests == [["place", 11, "battery"]], "Install is an explicit request for the one opened site")
	check(session.draft.is_empty(), "Panel requests never apply installation directly")
	panel.set_access_allowed(false, "멀어졌어요")
	panel._place_selected()
	panel._remove_selected()
	check(requests.size() == 1 and panel._place.disabled, "Lost access blocks handlers and buttons")
	panel.set_access_allowed(true)
	await process_frame
	await process_frame
	check(panel._card.position.x >= 0 and panel._card.get_rect().end.x <= viewport.size.x, "Site panel fits 1280 viewport")
	if "--render" in OS.get_cmdline_user_args():
		await _capture(viewport, "field-install.png")
	var pose := {"position": [-6, 0, 3], "yaw": 0.0, "pitch": 0.0}
	var placed: Dictionary = session.edit("place", 11, "battery", pose)
	check(not placed.has("error"), "Fixture can install battery at the queried site")
	station.sync_facilities(placed.state)
	await physics_frame
	await physics_frame
	check(interaction.can_access_slot(camera, 11), "Installing a mesh keeps the physical site permission")
	station.show_interaction_target(interaction.resolve_target(camera), placed.state)
	check(station._interaction_highlight.get_child_count() == 20, "Occupied site adds an outer building frame")
	panel.refresh(session)
	check(panel._remove.visible and not panel._place.visible and panel._remove.text.contains("2 토큰"), "Draft facility shows its full token refund")
	panel._remove_selected()
	check(requests.back() == ["remove", 11, ""], "Removal is an explicit request for the same site")
	panel.open_site(session, 11, "details")
	panel.set_access_allowed(true)
	var count := requests.size()
	panel._place_selected()
	panel._remove_selected()
	check(requests.size() == count and not panel._place.visible and not panel._remove.visible, "Details cannot emit edits even via direct handler calls")
	panel.open_site(session, 12, "edit")
	panel.set_access_allowed(true)
	panel._remove_selected()
	check(requests.size() == count and panel._remove.disabled, "Fixed habitat cannot be removed")
	panel.open_site(session, 11, "edit")
	panel.set_access_allowed(true)
	hud.show_mode("field")
	check(not hud._status_box.visible and not hud._intro.visible and not hud._reticle.visible and hud._header.visible, "Field mode keeps only resource header")
	viewport.size = Vector2i(960, 600)
	await process_frame
	await process_frame
	check(panel._card.get_rect().end.x <= 960 and panel._card.get_rect().end.y <= 600, "Site panel fits 960x600 viewport")
	if "--render" in OS.get_cmdline_user_args():
		await _capture(viewport, "field-remove-960.png")
	panel.hide()
	hud.show_mode("explore")
	hud.set_site_target({"kind": "console", "slot_id": -1}, placed.state)
	check(not hud._site_buttons.edit.visible and not hud._site_buttons.inspect.visible and hud._site_buttons.details.visible, "Console offers dashboard only")
	hud.set_site_target({"kind": "none", "slot_id": -1}, placed.state)
	station.show_interaction_target({"kind": "none", "slot_id": -1}, placed.state)
	check(not hud._status_box.visible and not station._interaction_highlight.visible, "No target clears cards and world highlight")
	var wall := StaticBody3D.new()
	var shape := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = Vector3(2, 3, 0.2)
	shape.shape = box
	wall.add_child(shape)
	wall.position = Vector3(-6, 1.5, 2)
	viewport.add_child(wall)
	await physics_frame
	await physics_frame
	check(not interaction.can_access_slot(camera, 11), "A new wall revokes previously valid site access")
	viewport.free()
	print("Field menu: %d checks, %d failures" % [checks, failures])
	quit(1 if failures else 0)

func _capture(viewport: SubViewport, filename: String) -> void:
	await process_frame
	await process_frame
	await RenderingServer.frame_post_draw
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path("res://.tmp"))
	viewport.get_texture().get_image().save_png("res://.tmp/" + filename)
