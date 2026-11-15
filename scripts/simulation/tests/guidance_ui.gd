extends SceneTree
const Fixture = preload("res://scripts/simulation/tests/ui_fixture.gd")
## State/geometry checks also run headless. --render writes real viewport images.
const Mission = preload("res://scenes/main.tscn")
var checks := 0
var failures := 0
var render := false
var preview_mode := false
var capture_directory := "res://logs/ux12/"
const UI = preload("res://scripts/ui/ui_style.gd")

func _initialize() -> void:
	render = "--render" in OS.get_cmdline_user_args()
	preview_mode = "--preview" in OS.get_cmdline_user_args()
	if preview_mode: capture_directory = "res://logs/ux13/"
	call_deferred("_run")

func check(ok: bool, message: String) -> void:
	checks += 1
	if not ok:
		failures += 1
		push_error(message)

func settle() -> void:
	for i in 5: await process_frame
	if render: await RenderingServer.frame_post_draw

func capture(view: SubViewport, name: String) -> void:
	if not render: return
	await RenderingServer.frame_post_draw
	var image := view.get_texture().get_image()
	check(not image.is_empty(), "Rendered image " + name)
	image.save_png(capture_directory + name + ".png")

func _geometry(view: SubViewport, ui: Control, phase: String) -> void:
	var area := Rect2(Vector2.ZERO, Vector2(view.size))
	for item in ui.find_children("*", "ScrollContainer", true, false):
		if not item.is_visible_in_tree(): continue
		check(area.encloses(item.get_global_rect()), phase + " scroll frame fits viewport " + str(item.get_global_rect()))
		for child in item.get_children():
			if child is Control:
				check(child.get_combined_minimum_size().x <= item.size.x + 1, phase + " scroll content fits width " + str(child.get_combined_minimum_size()))
	for item in ui.find_children("*", "Label", true, false):
		if not item.is_visible_in_tree(): continue
		check(item.get_theme_font_size("font_size") >= 16, phase + " label size: " + item.text.left(20))
		var font: Font = item.get_theme_font("font")
		var glyphs := true
		for character in item.text:
			if character not in ["\n", "\t"] and not font.has_char(character.unicode_at(0)): glyphs = false
		check(glyphs, phase + " glyphs: " + item.text.left(30))

func luminance(color: Color) -> float:
	var linear := color.srgb_to_linear()
	return 0.2126 * linear.r + 0.7152 * linear.g + 0.0722 * linear.b

func _run() -> void:
	for text_color in [UI.TEXT, UI.MUTED, UI.CYAN, UI.AMBER, UI.PURPLE, UI.ALERT]:
		check((luminance(text_color) + 0.05) / (luminance(UI.CARD) + 0.05) >= 4.5, "Shared text contrast at least 4.5:1")
	check((luminance(Color("#9aaec8")) + 0.05) / (luminance(Color("#111c2d")) + 0.05) >= 4.5, "Disabled label contrast")
	DirAccess.make_dir_recursive_absolute(capture_directory)
	for dimensions in [Vector2i(1920,1080), Vector2i(1280,720), Vector2i(1024,768), Vector2i(800,900), Vector2i(1100,720), Vector2i(1152,720)]:
		var view := SubViewport.new()
		view.size = dimensions
		view.render_target_update_mode = SubViewport.UPDATE_ALWAYS
		root.add_child(view)
		var game = Mission.instantiate()
		view.add_child(game)
		game.set_physics_process(false)
		game.player.set_physics_process(false)
		await settle()
		var tag := "%dx%d" % [dimensions.x, dimensions.y]
		_geometry(view, game.hud, tag + " start")
		check(game.hud._intro.get_global_rect().encloses(game.hud._intro_scroll.get_global_rect()), tag + " start scroll contained")
		await capture(view, tag + "-start")
		var initial_pose: Dictionary = game.player.pose()
		check(view.get_camera_3d() == game._start_camera, "First camera frames robot")
		game._set_mode("explore")
		check(view.get_camera_3d() == game.player.camera and game.player.pose() == initial_pose, "First start restores player camera without moving")
		game._pause()
		check(view.get_camera_3d() == game.player.camera, "Pause keeps exploration camera")
		var original: Dictionary = game.session.state.duplicate(true)
		var attempt: int = game.session.attempt_id
		game.hud._toggle_guidance()
		check(not game.terminal.guidance_enabled and not game.hud._first_step.visible, "Skip is shared with console")
		game.terminal._toggle_guidance()
		check(game.hud.guidance_enabled and game.terminal._guide_body.visible, "Guide reopens")
		check(game.session.state == original and game.session.attempt_id == attempt and game.session.draft.is_empty(), "Guide only changes presentation")
		game._set_mode("terminal")
		await settle()
		check(game.terminal._guide_text.text.contains("가까이 가서 1"), "T1 directs construction to the physical site")
		check(not game.terminal._history_body.visible and game.terminal._history_empty.visible, "Empty history explained")
		_geometry(view, game.terminal, tag + " console")
		await capture(view, tag + "-console")
		Fixture.edit(game, "place",0,"generator")
		check(game.terminal._guide_text.text.contains("이번 턴 진행"), "Prepared placement advances guidance")
		game._commit("")
		check(game.session.state.turn_id == 2 and game.terminal._guide_text.text.contains("대응"), "T2 requests event choice")
		await settle()
		_geometry(view, game.terminal, tag + " T2 event")
		await capture(view, tag + "-event")
		if preview_mode:
			var cell_height: float = game.terminal._slots[0].size.y
			game.terminal._toggle_preview()
			await settle()
			_geometry(view,game.terminal,tag + " conditional preview")
			check(is_equal_approx(game.terminal._slots[0].size.y, cell_height), tag + " preview keeps map cells compact")
			var scroll: ScrollContainer = game.terminal.find_children("*","ScrollContainer",true,false)[0]
			scroll.ensure_control_visible(game.terminal._preview_detail)
			await settle()
			await capture(view,tag + "-preview")
			scroll.scroll_vertical = 0
		game.terminal._toggle_history()
		await settle()
		_geometry(view, game.terminal, tag + " history")
		game.terminal._choose_event(0)
		check(game.terminal._guide_text.text.begins_with("3"), "T2 selected next action")
		game._restore(1)
		check(game.session.state.turn_id == 1 and game.terminal._choice.is_empty(), "Rewind clears event choice")
		var interrupted := {"turn_id":3,"phase":"failed_power","state_after":{"E":0,"O":60,"F":24,"facilities":[]}, "stats":{"generation":0,"demand":10,"harvest":0,"supply":0}, "not_applied_steps":["growth","supply"]}
		var explanation: String = game.terminal._result_text(interrupted)
		check(explanation.contains("전력 생산") and explanation.contains("계산 전 중단") and not explanation.contains("수확 0"), "Named results do not turn skipped values into zero")
		game._open_help()
		await settle()
		_geometry(view, game.help, tag + " help")
		await capture(view, tag + "-help")
		game.free()
		view.queue_free()
		await process_frame
	print("UX-R02 guidance UI: %d checks, %d failures" % [checks, failures])
	quit(1 if failures else 0)
