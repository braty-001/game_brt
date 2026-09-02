class_name BrainEditorPseudocodePanel
extends PanelContainer

const Tokens = preload("res://src/ui/design_tokens.gd")

var text_label: TextEdit

func _ready() -> void:
	if text_label != null:
		return
	name = "PseudocodePanel"
	position = Vector2(190, 54)
	custom_minimum_size = Vector2(380, 250)
	Tokens.apply_panel(self, Color("202d33"))
	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 8)
	add_child(box)
	var header := HBoxContainer.new()
	box.add_child(header)
	var title := Label.new()
	title.text = "PSEUDOCODIGO"
	title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	title.add_theme_color_override("font_color", Tokens.TEAL)
	header.add_child(title)
	var close_button := Button.new()
	close_button.text = "x"
	close_button.tooltip_text = "Fechar pseudocodigo"
	close_button.pressed.connect(func() -> void: hide())
	header.add_child(close_button)
	text_label = TextEdit.new()
	text_label.editable = false
	text_label.wrap_mode = TextEdit.LINE_WRAPPING_BOUNDARY
	text_label.size_flags_vertical = Control.SIZE_EXPAND_FILL
	text_label.add_theme_font_size_override("font_size", 14)
	text_label.add_theme_color_override("font_readonly_color", Tokens.TEXT)
	box.add_child(text_label)

func show_text(value: String) -> void:
	if text_label == null:
		_ready()
	text_label.text = value
	show()
