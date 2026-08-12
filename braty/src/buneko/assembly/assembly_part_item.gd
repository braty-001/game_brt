class_name AssemblyPartItem
extends Button

const Tokens = preload("res://src/ui/design_tokens.gd")

var slot := -1
var installed := false

func configure(slot_value: int, title: String, detail: String) -> void:
	slot = slot_value
	text = "%s\n%s" % [title, detail]
	alignment = HORIZONTAL_ALIGNMENT_LEFT
	custom_minimum_size.y = 54.0
	tooltip_text = "Clique para instalar ou selecionar esta peca"
	Tokens.apply_secondary_button(self)

func set_installed(value: bool) -> void:
	installed = value
	if installed:
		add_theme_color_override("font_color", Tokens.SUCCESS)
	else:
		add_theme_color_override("font_color", Tokens.TEXT)

func _get_drag_data(_at_position: Vector2):
	var preview := Label.new()
	preview.text = text.get_slice("\n", 0)
	preview.add_theme_color_override("font_color", Tokens.TEAL)
	preview.add_theme_stylebox_override("normal", Tokens.panel_style(Tokens.SURFACE_RAISED, 5, Tokens.TEAL))
	set_drag_preview(preview)
	return {"buneko_part_slot": slot}
