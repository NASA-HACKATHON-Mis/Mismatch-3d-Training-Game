extends SceneTree
const Overview = preload("res://scripts/ui/resource_overview.gd")
var checks := 0
var failures := 0
func _initialize() -> void: call_deferred("_run")
func check(ok: bool, message: String) -> void:
	checks += 1
	if not ok:
		failures += 1
		push_error(message)
func settle() -> void:
	for i in 6: await process_frame
func _run() -> void:
	var overview := Overview.new()
	root.add_child(overview)
	var data := {"resources":[
		{"id":"energy","label":"전력","current":10,"capacity":20,"preview":10,"preview_capacity":40},
		{"id":"oxygen","label":"산소","current":0,"capacity":100,"preview":100,"preview_capacity":100},
		{"id":"food","label":"식량","current":120,"capacity":100,"preview":-5,"preview_capacity":100}],"show_preview":true}
	var before := data.duplicate(true)
	overview.set_view_model(data)
	check(data == before,"Input view model is unchanged")
	check(is_equal_approx(overview._cards.energy.current_bar.value,0.5),"Current 10/20 half")
	check(is_equal_approx(overview._cards.energy.preview_bar.value,0.25),"Preview 10/40 quarter")
	check(overview._cards.oxygen.current_bar.value == 0 and overview._cards.oxygen.preview_bar.value == 1,"Empty/full")
	check(overview._cards.food.current_bar.value == 1 and overview._cards.food.preview_bar.value == 0,"Out of range bars clamp")
	check("120" in overview._cards.food.current.text and "-5" in overview._cards.food.preview.text,"Numbers are not clamped")
	check("현재" in overview._cards.energy.current.text and "예상" in overview._cards.energy.preview.text,"Current and preview have different labels")
	for bad in [0,-1,null,"bad",NAN]:
		overview.set_view_model({"resources":[{"id":"energy","current":10,"capacity":bad}],"show_preview":true})
		check(overview._cards.energy.current_bar.value == 0 and "확인 불가" in overview._cards.energy.current.text,"Invalid capacity "+str(bad))
	overview.set_view_model({})
	for id: String in overview.IDS:
		check("확인 불가" in overview._cards[id].current.text and not overview._cards[id].preview_box.visible,"Missing entry safe "+id)
	overview.set_view_model({"resources":[null,12,{"id":"unknown"}],"show_preview":true})
	check(overview._cards.energy.current_bar.value == 0,"Malformed entries ignored")
	overview.queue_free()
	await settle()
	DirAccess.make_dir_recursive_absolute("res://logs/ops-c")
	for width in [280,840]:
		var view := SubViewport.new()
		view.size = Vector2i(width,500)
		view.render_target_update_mode = SubViewport.UPDATE_ALWAYS
		root.add_child(view)
		var background := ColorRect.new()
		background.color = Color("#0a1424")
		background.size = view.size
		view.add_child(background)
		var card := Overview.new()
		view.add_child(card)
		card.size.x = width
		card.set_view_model(data)
		await settle()
		check(card.columns == (3 if width >= 840 else 1),"Responsive columns "+str(width))
		check(card.size.x <= width,"Fits width "+str(width))
		for child in card.get_children():
			check(Rect2(Vector2.ZERO,Vector2(view.size)).encloses(child.get_global_rect()),"Card fits viewport")
		for id: String in card.IDS:
			check(card._cards[id].current.size.x >= card._cards[id].current.get_minimum_size().x,"Current caption fits")
			check(card._cards[id].preview.size.x >= card._cards[id].preview.get_minimum_size().x,"Preview caption fits")
		if "--render" in OS.get_cmdline_user_args():
			await RenderingServer.frame_post_draw
			var capture := view.get_texture().get_image()
			check(not capture.is_empty(),"Actual rendered image")
			capture.save_png("res://logs/ops-c/overview-%d.png" % width)
		view.queue_free()
		await settle()
	print("OPS-C resource overview: %d checks, %d failures" % [checks,failures])
	quit(1 if failures else 0)
