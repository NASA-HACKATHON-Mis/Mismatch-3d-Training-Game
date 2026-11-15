extends SceneTree
## API example: var card = Card.new(); card.set_view_model(vm)
## card.action_requested.connect(handler) -- handler revalidates current selection.
const Card = preload("res://scripts/ui/facility_info_card.gd")
var checks := 0
var failures := 0
var render := false
var received: Array[String] = []
func _initialize() -> void:
	render = "--render" in OS.get_cmdline_user_args()
	call_deferred("_run")
func check(ok: bool, message: String) -> void:
	checks += 1
	if not ok:
		failures += 1
		push_error(message)
func settle() -> void:
	for i in 5: await process_frame
func requested(id: String) -> void: received.append(id)
func vm() -> Dictionary:
	return {"slot_id":11,"kind":"battery","title":"배터리","summary":"남는 전력을 담아 두는 저장고예요.","cost_text":"건설 비용 · 토큰 2개","effects":[{"icon_id":"storage","label":"저장 공간","value_text":"전력 저장 한도 +20"},{"icon_id":"energy","label":"전력 만들기","value_text":"전력은 만들지 않아요."}],"details":"배터리를 지으면 기지 전체의 전력 저장 공간이 늘어나요. 현재 전력은 그대로이며, 이번 턴 진행 후 예상값은 운영 화면에서 확인해요.","actions":[{"id":"inspect","label":"3D로 살펴보기","enabled":true,"reason":""},{"id":"remove","label":"철거하기","enabled":false,"reason":"현재 턴이 끝났어요. 과거 기록으로 돌아가면 배치를 바꿀 수 있어요."}]}
func labels(card) -> String:
	var text := ""
	for node in card.find_children("*","Label",true,false): text += node.text + "\n"
	return text
func geometry(card, width: int) -> void:
	check(card.get_combined_minimum_size().x <= width+0.5,"Card minimum width fits %d" % width)
	check(card.size.x <= width+0.5,"Card width fits %d" % width)
	for node in card.find_children("*","Control",true,false):
		if not node.is_visible_in_tree(): continue
		check(node.get_global_rect().position.x >= card.global_position.x-0.5 and node.get_global_rect().end.x <= card.get_global_rect().end.x+0.5,"Child stays within card width: " + node.get_class())
		if node is TextureRect: check(node.texture != null,"Local vector icon resolves")
func capture(view, tag: String) -> void:
	if not render: return
	await RenderingServer.frame_post_draw
	var image: Image = view.get_texture().get_image()
	check(not image.is_empty(),"Rendered " + tag)
	image.save_png("res://logs/ops-d/"+tag+".png")
func _run() -> void:
	DirAccess.make_dir_recursive_absolute("res://logs/ops-d")
	var card = Card.new()
	root.add_child(card)
	card.action_requested.connect(requested)
	check(labels(card).contains("칸을 고르면"),"Missing data produces safe empty state")
	for malformed in [{"effects":null,"actions":null},{"effects":[null,5,"bad",{}, {"label":7}],"actions":[false,{}, {"id":"explode","enabled":true}]},{"slot_id":"bad","title":7,"summary":[],"cost_text":true,"details":{},"effects":"bad","actions":{}}]:
		card.set_view_model(malformed)
		check(card._action_buttons.is_empty(),"Malformed child data produces no unsafe action")
	var data := vm()
	var original := data.duplicate(true)
	card.set_view_model(data)
	check(data == original,"View model input is never mutated")
	data.effects[0].value_text = "caller mutation"
	check(card._model.effects[0].value_text == original.effects[0].value_text and not labels(card).contains("caller mutation"),"Nested model copy is independent from caller mutation")
	check(not card._details_label.visible,"Details start collapsed")
	check(labels(card).contains("배터리") and labels(card).contains("전력 저장 한도 +20"),"Caller title and effect are displayed without recalculation")
	check(labels(card).contains("현재 턴이 끝났어요"),"Disabled reason is visible in card")
	card._action_buttons.remove.pressed.emit()
	card._request("remove",card._generation)
	card._request("unknown",card._generation)
	check(received.is_empty(),"Disabled and unknown handlers cannot emit")
	card._action_buttons.inspect.pressed.emit()
	check(received == ["inspect"],"Allowed enabled action emits only its id")
	card._details_button.pressed.emit()
	check(card._details_label.visible,"Details expand")
	var expanded_model := vm()
	expanded_model.cost_text = "토큰 2개 · 비용 표시 갱신"
	card.set_view_model(expanded_model)
	check(card._details_label.visible,"Same selection refresh preserves expanded details")
	var old_action = card._action_buttons.inspect
	var old_toggle = card._details_button
	var replacement := vm()
	replacement.slot_id = 12
	replacement.actions = [{"id":"place","label":"여기에 짓기","enabled":true}]
	card.set_view_model(replacement)
	old_action.pressed.emit()
	old_toggle.pressed.emit()
	check(received == ["inspect"] and not card._details_label.visible,"Stale controls cannot act on new selection")
	check(card._action_buttons.keys() == ["place"],"Refresh removes old action ids")
	data.effects[0].value_text = "caller mutation"
	check(not labels(card).contains("caller mutation"),"Caller later mutation cannot mutate displayed copy")
	card.set_view_model({"actions":[{"id":"place","enabled":true},{"id":"place","enabled":true},{"id":"remove","enabled":true},{"id":"inspect","enabled":true},{"id":"commit","enabled":true}]})
	check(card._action_buttons.size() == 3,"Only three allowed unique actions")
	for id in ["place","remove","inspect"]: card._action_buttons[id].pressed.emit()
	check(received == ["inspect","place","remove","inspect"],"All allowed action ids supported")
	card.set_view_model({"actions":[{"id":"place","enabled":"true"}]})
	check(card._action_buttons.place.disabled,"Non-boolean enabled value fails closed")
	card.queue_free()
	await settle()
	for width in [280,360,520]:
		var view := SubViewport.new()
		view.size = Vector2i(width+32,1000)
		view.render_target_update_mode = SubViewport.UPDATE_ALWAYS
		root.add_child(view)
		var margin := MarginContainer.new()
		margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		for side in ["left","top","right","bottom"]: margin.add_theme_constant_override("margin_"+side,16)
		view.add_child(margin)
		var scroll := ScrollContainer.new()
		scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
		margin.add_child(scroll)
		var column := VBoxContainer.new()
		column.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		scroll.add_child(column)
		card = Card.new()
		column.add_child(card)
		card.action_requested.connect(requested)
		card.set_view_model({"slot_id":0,"kind":"empty","title":"빈 칸","summary":"필요한 시설을 골라 여기에 지어요.","cost_text":"비용은 고른 시설에 따라 달라요.","effects":[{"icon_id":"unknown","label":"칸 특징","value_text":"일조 · 차폐"}],"actions":[{"id":"place","label":"선택한 시설을 여기에 짓기","enabled":true}]})
		await settle()
		geometry(card,width)
		await capture(view,str(width)+"-empty")
		card.set_view_model(vm())
		await settle()
		geometry(card,width)
		await capture(view,str(width)+"-facility")
		var count_before := received.size()
		card._action_buttons.inspect.grab_focus()
		for pressed in [true,false]:
			var event := InputEventKey.new()
			event.keycode = KEY_ENTER
			event.pressed = pressed
			view.push_input(event,true)
		await settle()
		check(received.size() == count_before+1 and received.back() == "inspect","Keyboard Enter invokes focused action")
		var tab := InputEventKey.new()
		tab.keycode = KEY_TAB
		tab.pressed = true
		view.push_input(tab,true)
		await settle()
		check(card._details_button.has_focus(),"Tab skips disabled action and reaches details")
		var refresh_data := vm()
		refresh_data.cost_text = "토큰 2개 · 표시 갱신"
		card.set_view_model(refresh_data)
		await settle()
		check(card._details_button.has_focus(),"Same-context refresh preserves details keyboard focus")
		var long_data := vm()
		long_data.title = "아주 긴 이름의 시설도 잘 읽히는지 확인하는 정보 카드"
		long_data.effects.append({"icon_id":"food","label":"길게 쓴 효과 설명","value_text":"추가 효과는 전달받은 문구만 그대로 보여 주며 규칙을 계산하지 않아요."})
		long_data.actions[0].label = "현재 선택한 시설을 3D 화면에서 자세하게 살펴보기"
		card.set_view_model(long_data)
		card._details_button.pressed.emit()
		await settle()
		geometry(card,width)
		check(card._details_label.visible,"Long details expanded")
		scroll.scroll_vertical = 0
		await settle()
		await capture(view,str(width)+"-details")
		scroll.scroll_vertical = int(scroll.get_v_scroll_bar().max_value)
		await settle()
		await capture(view,str(width)+"-details-end")
		view.queue_free()
		await settle()
	print("OPS-D facility info card: %d checks, %d failures" % [checks,failures])
	quit(1 if failures else 0)
