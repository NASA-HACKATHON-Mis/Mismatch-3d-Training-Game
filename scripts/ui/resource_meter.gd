extends VBoxContainer
## Read-only resource display. The numeric value is never clamped or mutated.
const UI = preload("res://scripts/ui/ui_style.gd")

var caption: Label
var bar: ProgressBar

func _init() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	size_flags_horizontal = Control.SIZE_EXPAND_FILL
	add_theme_constant_override("separation", 4)
	caption = UI.label(self, "", 16, UI.TEXT)
	bar = ProgressBar.new()
	bar.mouse_filter = Control.MOUSE_FILTER_IGNORE
	bar.show_percentage = false
	bar.min_value = 0.0
	bar.max_value = 1.0
	bar.step = 0.0
	bar.custom_minimum_size.y = 10
	bar.add_theme_stylebox_override("background", UI.box(UI.DARK, UI.LINE, 4))
	add_child(bar)
	set_color(UI.CYAN)

func set_color(color: Color) -> void:
	bar.add_theme_stylebox_override("fill", UI.box(color, color, 4))

func set_values(label_text: String, current_value: int, maximum_value: int) -> void:
	if maximum_value <= 0:
		caption.text = "%s %d / 확인 불가" % [label_text, current_value]
		bar.value = 0.0
	else:
		caption.text = "%s %d/%d" % [label_text, current_value, maximum_value]
		bar.value = clampf(float(current_value) / maximum_value, 0.0, 1.0)
