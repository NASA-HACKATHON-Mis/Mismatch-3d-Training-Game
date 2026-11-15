extends SceneTree
## Checks the shipped Korean guide with the actual offline data and game controls.

const Mission = preload("res://scenes/main.tscn")
const Learning = preload("res://resources/content/learning.gd")

var _checks := 0
var _failures := 0


func _initialize() -> void:
	call_deferred("_run")


func _check(value: bool, message: String) -> void:
	_checks += 1
	if not value:
		_failures += 1
		push_error(message)


func _run() -> void:
	var archive := Learning.archived_flare()
	_check(not archive.is_empty(), "The archived DONKI observation is available offline")
	if not archive.is_empty():
		var record: Dictionary = archive.record
		var meta: Dictionary = archive.metadata
		_check(record.flrID == "2016-01-01T23:10:00-FLR-001" and record.classType == "M2.3"
			and record.beginTime == "2016-01-01T23:10Z" and record.peakTime == "2016-01-02T00:11Z"
			and record.endTime == "2016-01-02T01:01Z", "The source card uses the archived event's ID, class, and UTC times")
		_check(int(record.versionId) == int(meta.data_version_id) and str(meta.retrieved_at).left(10) == "2026-11-14"
			and not meta.live_data and record.link == meta.event_link, "Source version, archived status, retrieval date and link")

	var game = Mission.instantiate()
	root.add_child(game)
	var guide: Control = game.help
	var font := guide.get_theme_default_font() as FontVariation
	_check(font != null and font.base_font.resource_path == "res://resources/fonts/NotoSansKR.ttf"
		and font.has_char(0xd55c) and font.has_char(0xb3c4), "Project theme uses bundled Hangul font")
	_check(Learning.FACILITIES.size() == 5 and Learning.EVENTS.keys() == [2, 4, 5], "The guide covers every facility and event")
	await process_frame

	var begin := {"phase": game.mode, "state": game.session.state.duplicate(true)}
	var launch_help: Button = game.hud.help_button
	launch_help.grab_focus()
	launch_help.pressed.emit()
	_check(guide.visible and not game.hud.visible and not game.terminal.visible, "Opening the guide hides other focusable controls")
	_check(guide.is_ancestor_of(root.gui_get_focus_owner()), "Focus moves to the guide")
	var sources: Button = _button(guide, "실제 자료")
	sources.pressed.emit()
	_check(_visible_text_has(guide, "M2.3") and _visible_text_has(guide, "2016-01-01 23:10 UTC")
		and _visible_text_has(guide, "게임 4턴 경보는 가상 사건"), "Real observation and fictional warning stay distinct on screen")
	_check(_button(guide, "NASA 사건 원문 ↗").is_visible_in_tree()
		and _button(guide, "캐나다 우주국 원문 ↗").is_visible_in_tree(), "NASA and CSA source buttons are visible")
	_esc(game)
	_check(not guide.visible and game.mode == begin.phase and root.gui_get_focus_owner() == launch_help,
		"Escape returns focus to the opener without capturing the cursor")

	game._set_mode("terminal")
	var terminal_help: Button = game.terminal.help_button
	terminal_help.grab_focus()
	terminal_help.pressed.emit()
	_esc(game)
	_check(game.mode == "terminal" and game.terminal.visible and root.gui_get_focus_owner() == terminal_help,
		"Escape closes help first and returns to the console")
	_check(game.session.state == begin.state, "Reading help does not advance a turn or change the game state")

	game._edit("place", 0, "generator")
	game._commit("")
	game._commit("normal")
	game._restore(2)
	game._edit("place", 11, "battery")
	game._commit("conserve")
	var compared: Dictionary = game.session.compare_turn(2)
	_check(not compared.is_empty() and Learning.comparison_prompt(compared).contains("배치와 대응"),
		"When the layout and response change, the prompt does not isolate a cause")
	_check(Learning.attempt_note(compared.previous).contains("재배 유지")
		and Learning.attempt_note(compared.current).contains("절전"),
		"Comparison text reports the choices from each real attempt")
	var stopped := {"phase": "failed_power", "stats": {"generation": 0, "demand": 6, "harvest": 0, "supply": 0},
		"not_applied_steps": ["oxygen", "growth", "supply", "food"]}
	var note := Learning.attempt_note(stopped)
	_check(note.contains("전력 필요 6") and not note.contains("수확 0") and note.contains("생략"),
		"An interrupted turn names skipped calculations without treating them as zero results")
	game.free()
	print("HH-005 learning UI: %d checks, %d failures" % [_checks, _failures])
	quit(1 if _failures else 0)


func _esc(game: Node) -> void:
	var event := InputEventKey.new()
	event.pressed = true
	event.keycode = KEY_ESCAPE
	game._input(event)


func _button(parent: Node, title: String) -> Button:
	for child in parent.find_children("*", "Button", true, false):
		if child.text == title:
			return child
	return null


func _visible_text_has(parent: Node, phrase: String) -> bool:
	for child in parent.find_children("*", "Label", true, false):
		if child.is_visible_in_tree() and child.text.contains(phrase):
			return true
	return false
