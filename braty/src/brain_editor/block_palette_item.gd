class_name BrainEditorBlockPaletteItem
extends Button

const Tokens = preload("res://src/ui/design_tokens.gd")

var block_kind: int

func configure(kind: int, label: String) -> void:
	block_kind = kind
	text = "+  %s" % label
	alignment = HORIZONTAL_ALIGNMENT_LEFT
	custom_minimum_size.y = 34.0
	tooltip_text = "Adicionar bloco %s" % label
	Tokens.apply_compact_secondary_button(self)
	add_theme_color_override("font_color", Tokens.category_color(kind))
