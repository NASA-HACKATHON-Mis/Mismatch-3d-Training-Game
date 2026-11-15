extends PanelContainer
## OPS-D contract v1. Display-only; callers revalidate requests before execution.
signal action_requested(action_id: String)

const UI = preload("res://scripts/ui/ui_style.gd")
const ALLOWED_ACTIONS := ["place", "remove", "inspect"]
const ICON_PATH := "res://assets/ui/operations/facilities/"
const ACTION_LABELS := {"place":"Build here", "remove":"Remove", "inspect":"View in 3D"}

var _column: VBoxContainer
var _model: Dictionary = {}
var _generation := 0
var _context: Array = []
var _expanded := false
var _details_button: Button
var _details_label: Label
var _action_buttons: Dictionary = {}
var _enabled_actions: Dictionary = {}


func _init() -> void:
	custom_minimum_size.x = 280
	size_flags_horizontal = Control.SIZE_EXPAND_FILL
	UI.use_korean_theme(self)
	add_theme_stylebox_override("panel", UI.box(UI.CARD, UI.LINE, 12, 14))
	_column = UI.column(self, 10)
	set_view_model({})


func set_view_model(data: Dictionary) -> void:
	if _generation > 0 and data == _model: return
	_model = data.duplicate(true)
	_generation += 1
	var slot: int = _model.get("slot_id", -1) if _model.get("slot_id", -1) is int else -1
	var kind := _text(_model.get("kind", ""))
	var next_context := [slot, kind]
	var context_changed := next_context != _context
	if context_changed: _expanded = false
	_context = next_context
	var focused_details := is_instance_valid(_details_button) and _details_button.has_focus() and not context_changed
	var focused_action := ""
	for id in _action_buttons:
		if is_instance_valid(_action_buttons[id]) and _action_buttons[id].has_focus(): focused_action = id
	for child in _column.get_children():
		_column.remove_child(child)
		child.queue_free()
	_action_buttons.clear()
	_enabled_actions.clear()
	_details_button = null
	_details_label = null
	UI.label(_column, "Pad %02d" % (slot + 1) if slot >= 0 else "Selected facility", 16, UI.CYAN, true)
	var empty := kind in ["", "empty"]
	UI.label(_column, _text(_model.get("title"), "Empty pad" if empty and slot >= 0 else "Facility info"), 24, UI.TEXT, true)
	UI.label(_column, _text(_model.get("summary"), "Select a pad to see its details." if slot < 0 else "Choose an available action below."), 18, UI.TEXT, true)
	var effects = _model.get("effects", [])
	if effects is Array:
		for effect in effects:
			if not effect is Dictionary: continue
			var label := _text(effect.get("label"))
			var value := _text(effect.get("value_text"))
			if label.is_empty() and value.is_empty(): continue
			var row := UI.row(_column, 8)
			var icon := TextureRect.new()
			icon.custom_minimum_size = Vector2(26,26)
			icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
			icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
			icon.size_flags_vertical = Control.SIZE_SHRINK_BEGIN
			icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
			icon.texture = load(ICON_PATH + _icon_name(_text(effect.get("icon_id"))) + ".svg")
			row.add_child(icon)
			var copy := UI.column(row, 2)
			copy.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			if not label.is_empty(): UI.label(copy, label, 16, UI.MUTED, true)
			if not value.is_empty(): UI.label(copy, value, 18, UI.TEXT, true)
	var cost := _text(_model.get("cost_text"))
	if not cost.is_empty(): UI.label(_column, cost, 18, UI.AMBER, true)
	var actions = _model.get("actions", [])
	if actions is Array:
		for action in actions:
			if not action is Dictionary: continue
			var id := _text(action.get("id"))
			if id not in ALLOWED_ACTIONS or _action_buttons.has(id): continue
			var enabled: bool = action.get("enabled") is bool and action.get("enabled", false) == true
			_enabled_actions[id] = enabled
			var button := UI.button(_column, _text(action.get("label"), ACTION_LABELS[id]), _request.bind(id, _generation), UI.CYAN, 44)
			button.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
			button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			button.disabled = not enabled
			button.focus_mode = Control.FOCUS_ALL if enabled else Control.FOCUS_NONE
			_action_buttons[id] = button
			if not enabled:
				var reason := _text(action.get("reason"), "Unavailable right now.")
				button.tooltip_text = reason
				UI.label(_column, reason, 16, UI.ALERT, true)
	var details := _text(_model.get("details"))
	if not details.is_empty():
		_details_button = UI.button(_column, "", _toggle_details.bind(_generation), UI.MUTED, 40)
		_details_button.toggle_mode = true
		_details_label = UI.label(_column, details, 16, UI.MUTED, true)
		_update_details()
	else: _expanded = false
	if focused_details and is_instance_valid(_details_button):
		_details_button.call_deferred("grab_focus")
	elif not context_changed and _action_buttons.has(focused_action) and not _action_buttons[focused_action].disabled:
		_action_buttons[focused_action].call_deferred("grab_focus")


func _request(id: String, generation: int) -> void:
	if generation == _generation and id in ALLOWED_ACTIONS and _enabled_actions.get(id, false):
		action_requested.emit(id)


func _toggle_details(generation: int) -> void:
	if generation != _generation: return
	_expanded = not _expanded
	_update_details()


func _update_details() -> void:
	_details_button.text = "Hide details" if _expanded else "Show details"
	_details_button.set_pressed_no_signal(_expanded)
	_details_label.visible = _expanded


func _text(value, fallback: String = "") -> String:
	return value.strip_edges() if value is String and not value.strip_edges().is_empty() else fallback


func _icon_name(id: String) -> String:
	match id:
		"energy", "power", "generator": return "energy"
		"oxygen", "air", "habitat": return "oxygen"
		"food", "greenhouse": return "food"
		"capacity", "battery", "storage": return "storage"
		"safety", "shelter", "shield": return "shield"
		"cost", "tokens", "budget": return "cost"
	return "info"
