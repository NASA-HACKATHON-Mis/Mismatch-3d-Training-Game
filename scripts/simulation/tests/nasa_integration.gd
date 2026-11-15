extends SceneTree
## Actual shipped NASA archive -> mission -> decisions, preview, results and replay.
const Mission = preload("res://scenes/main.tscn")
var checks := 0
var failures := 0

func _initialize() -> void: call_deferred("_run")
func check(ok: bool, label: String) -> void:
	checks += 1
	if not ok:
		failures += 1
		push_error(label)
func settle() -> void:
	for i in 8: await process_frame
func capture(view: SubViewport, label: String) -> void:
	if "--render" not in OS.get_cmdline_user_args(): return
	await RenderingServer.frame_post_draw
	view.get_texture().get_image().save_png("res://logs/nasa/" + label + ".png")

func _run() -> void:
	OS.set_environment("LUNAR_OFFLINE", "1")
	DirAccess.make_dir_recursive_absolute("res://logs/nasa")
	for dimensions in [Vector2i(960,600), Vector2i(1280,800)]:
		var view := SubViewport.new()
		view.size = dimensions
		view.render_target_update_mode = SubViewport.UPDATE_ALWAYS
		root.add_child(view)
		var game = Mission.instantiate()
		view.add_child(game)
		game.set_physics_process(false)
		game.player.set_physics_process(false)
		await settle()
		game._set_mode("terminal")
		var profile: Dictionary = game.session.state.weather.duplicate(true)
		check(profile.context.records.FLR.size() > 0 and profile.context.records.SEP.size() > 0 and profile.context.records.CME.size() > 0, "shipped actual archive contains all three NASA products")
		check(profile.protection_energy == 6 and profile.communication_delay == 2 and profile.shelter_required, "actual X-class/SEP/CME archives select training costs and delay")
		check(game.session.snapshot(1).weather == profile, "source and mapping stored in initial snapshot")
		var ui = game.terminal
		for entry in [[0,"generator"],[11,"battery"],[13,"greenhouse"],[24,"shelter"]]:
			ui.open_context(entry[0])
			ui._select_kind(entry[1])
			ui._place.pressed.emit()
		check(game.session.draft.size() == 4 and game.session.state.E == 20, "build actions edit draft without consuming resources")
		ui.advice_request_changed.emit(true)
		ui.advanced.emit("")
		check(game.session.state.E == 27 and game.session.state.communication.pending.reply_turn == 3, "CME case schedules T1 request at T3 and charges one energy")
		check(ui._communication_label.text.contains("T3"), "pending UI reports actual CME reply turn")
		ui.advanced.emit("normal")
		check(game.session.state.E == 17 and not game.session.state.communication.pending.is_empty(), "T2 cannot deliver delayed response early")
		ui.advanced.emit("")
		check(game.session.state.E == 7 and game.session.state.communication.response_turn == 3, "T3 delivers delayed advice without extra reward")
		ui._choose_event(0)
		ui._toggle_preview()
		await settle()
		for action: Control in [ui._advance, ui._event_buttons[0], ui._event_buttons[1]]:
			check(Rect2(Vector2.ZERO, Vector2(dimensions)).encloses(action.get_global_rect()) and action.is_visible_in_tree(), "NASA event action remains visible")
		await capture(view, "%dx%d-T4" % [dimensions.x,dimensions.y])
		ui.advanced.emit("shelter")
		var result: Dictionary = game.session.result_at(4)
		check(result.stats.protection_energy == 6 and result.state_after.E == 13, "actual archived NASA profile changes T4 protection cost")
		check(result.state_after.weather == profile, "result retains exact source and rule provenance")
		ui.rewound.emit(4)
		check(game.session.state.weather == profile and game._weather_context == profile.context, "rewind retains frozen NASA source and conditions")
		ui.advanced.emit("shelter")
		check(game.session.result_at(4).state_after == result.state_after, "same inputs replay identical NASA-driven outcome")
		ui.advanced.emit("acknowledge")
		check(ui._advice_toggle.disabled, "T6 request disabled when CME reply would miss T7")
		ui.advanced.emit("")
		ui.advanced.emit("")
		check(game.session.state.phase == "completed" and game.session.state.E == 37 and game.session.state.F == 42, "real archived profile remains playable across seven turns")
		view.queue_free()
		await settle()
	print("NASA integration: %d checks / %d failures" % [checks, failures])
	quit(1 if failures else 0)
