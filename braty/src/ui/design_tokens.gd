class_name BunekoDesignTokens
extends RefCounted

const BACKGROUND := Color("182126")
const SURFACE := Color("243037")
const SURFACE_RAISED := Color("303e45")
const BORDER := Color("52636b")
const TEXT := Color("f4f0e6")
const TEXT_MUTED := Color("aebdc2")
const TEAL := Color("27c7bd")
const TEAL_DARK := Color("147c79")
const AMBER := Color("f6ad3c")
const SUCCESS := Color("5ed18a")
const ERROR := Color("ef6a67")
const ACTION := Color("2f91d3")
const CONTROL := Color("d578d2")
const SENSOR := Color("e1a33c")

static func panel_style(color: Color = SURFACE, radius: int = 6, border_color: Color = BORDER) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = color
	style.border_color = border_color
	style.set_border_width_all(1)
	style.set_corner_radius_all(radius)
	style.content_margin_left = 14.0
	style.content_margin_right = 14.0
	style.content_margin_top = 12.0
	style.content_margin_bottom = 12.0
	return style

static func button_style(color: Color, border_color: Color = BORDER) -> StyleBoxFlat:
	var style := panel_style(color, 5, border_color)
	style.content_margin_left = 14.0
	style.content_margin_right = 14.0
	style.content_margin_top = 9.0
	style.content_margin_bottom = 9.0
	return style

static func apply_panel(control: Control, color: Color = SURFACE) -> void:
	control.add_theme_stylebox_override("panel", panel_style(color))

static func apply_primary_button(button: Button) -> void:
	button.add_theme_color_override("font_color", Color("102528"))
	button.add_theme_color_override("font_hover_color", Color("081719"))
	button.add_theme_color_override("font_disabled_color", Color("728184"))
	button.add_theme_stylebox_override("normal", button_style(TEAL, TEAL))
	button.add_theme_stylebox_override("hover", button_style(Color("54ddd2"), Color("54ddd2")))
	button.add_theme_stylebox_override("pressed", button_style(TEAL_DARK, TEAL))
	button.add_theme_stylebox_override("disabled", button_style(Color("39484d"), Color("46565c")))

static func apply_secondary_button(button: Button) -> void:
	button.add_theme_color_override("font_color", TEXT)
	button.add_theme_color_override("font_hover_color", TEXT)
	button.add_theme_stylebox_override("normal", button_style(SURFACE_RAISED))
	button.add_theme_stylebox_override("hover", button_style(Color("3b4c54"), TEAL))
	button.add_theme_stylebox_override("pressed", button_style(Color("1d292e"), TEAL))

static func apply_compact_secondary_button(button: Button) -> void:
	button.add_theme_color_override("font_color", TEXT)
	button.add_theme_color_override("font_hover_color", TEXT)
	button.add_theme_font_size_override("font_size", 14)
	var normal := button_style(SURFACE_RAISED)
	var hover := button_style(Color("3b4c54"), TEAL)
	var pressed := button_style(Color("1d292e"), TEAL)
	for style in [normal, hover, pressed]:
		style.content_margin_top = 5.0
		style.content_margin_bottom = 5.0
	button.add_theme_stylebox_override("normal", normal)
	button.add_theme_stylebox_override("hover", hover)
	button.add_theme_stylebox_override("pressed", pressed)

static func category_color(kind: int) -> Color:
	if kind == ProgramBlockKind.Value.IF or kind == ProgramBlockKind.Value.WHILE:
		return CONTROL
	return ACTION
