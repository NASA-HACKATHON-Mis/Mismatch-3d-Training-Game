extends SceneTree
## Exercise real mission signal wiring, immutable data context and rewind together.
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

func _run() -> void:
	OS.set_environment("LUNAR_OFFLINE", "1")
	var game = Mission.instantiate()
	root.add_child(game)
	game.set_physics_process(false)
	game.player.set_physics_process(false)
	await settle()
	game._set_mode("terminal")
	var weather: Dictionary = game._weather_context.duplicate(true)
	check(weather.mode == "archive" and weather.event_id == "2016-01-01T23:10:00-FLR-001", "offline mission shows genuine archived observation")
	check(game.help._weather_text.text.contains(weather.observed_at) and game.help._weather_text.text.contains(weather.fetched_at), "help separates observation and retrieval dates")
	check(game.help._weather_text.text.contains("교육용"), "help keeps educational scenario label")
	game.terminal.advice_request_changed.emit(true)
	check(game.session.advice_requested and game.session.state.E == 20, "UI request signal selects without charging")
	check(not game.terminal._cancel.disabled, "request-only change can be cancelled")
	check(game.terminal._preview_detail.text.contains("조언 요청 전력 1"), "visible turn preview includes communication energy")
	game.terminal.advice_request_changed.emit(false)
	check(not game.session.advice_requested and game.session.state.E == 20, "UI cancellation is free")
	game.terminal.advice_request_changed.emit(true)
	game.terminal.cancelled.emit()
	check(not game.session.advice_requested and game.session.state.E == 20, "cancel all changes resets pending UI request")
	game.terminal.advice_request_changed.emit(true)
	game.terminal.advanced.emit("")
	check(game.session.state.turn_id == 2 and game.session.state.E == 13, "advance signal commits one energy communication cost")
	check(game.session.state.communication.pending == {"requested_turn": 1, "reply_turn": 2}, "mission commits delayed reply")
	check(game.terminal._communication_label.text.contains("T2"), "UI uses pending reply turn contract")
	check(not game.session.advice_requested, "mission clears confirmed request")
	game.terminal.advice_request_changed.emit(true)
	check(not game.session.advice_requested and game.session.state.E == 13, "mission rejects request while awaiting reply")
	game.terminal.advanced.emit("conserve")
	var reply: Dictionary = game.session.state.communication.duplicate(true)
	check(game.session.state.turn_id == 3 and game.session.state.E == 7, "next turn charges no extra communication energy")
	check(reply.pending.is_empty() and reply.response_turn == 2 and not reply.message.is_empty(), "next commit publishes contextual reply")
	game.terminal.advice_request_changed.emit(true)
	game.terminal.advanced.emit("")
	check(game.session.state.phase == "failed_power" and game.session.state.E == 0, "request cost can trigger normal power failure")
	check(game.terminal._communication_label.text.contains("되감") and game.terminal._advice_toggle.text == "통신 중단", "failed turn does not promise unreachable reply")
	game.terminal.rewound.emit(2)
	check(game.session.state.turn_id == 2 and game.session.state.E == 13 and not game.session.state.communication.pending.is_empty(), "rewind restores power and pending reply together")
	game.terminal.advanced.emit("conserve")
	check(game.session.state.communication == reply and game.session.state.E == 7, "replay preserves exact advice and cost")
	game.terminal.rewound.emit(1)
	check(game.session.state.E == 20 and game.session.state.communication.pending.is_empty() and game.session.state.communication.message.is_empty(), "rewind before request removes reply and cost")
	check(not game.session.advice_requested and game.session.draft.is_empty(), "rewind clears all uncommitted edits")
	check(game._weather_context == weather and game._weather.get_context() == weather, "commits and rewinds retain frozen observation context")
	game._pause()
	game._start_exploring()
	game._update_capture(0.016, true)
	check(game.mode == "explore" and game._weather_context == weather, "exploration resumes without changing source case")
	game._pause()
	game.queue_free()
	await settle()
	print("FEED integration: %d checks / %d failures" % [checks, failures])
	quit(1 if failures else 0)
