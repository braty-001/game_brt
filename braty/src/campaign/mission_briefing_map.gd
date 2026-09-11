class_name MissionBriefingMap
extends Control

const Catalog = preload("res://src/campaign/campaign_mission_catalog.gd")
const Tokens = preload("res://src/ui/design_tokens.gd")
const REFERENCE_SIZE := Vector2(600, 340)

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	resized.connect(queue_redraw)

func _draw() -> void:
	var scale_factor := minf(size.x / REFERENCE_SIZE.x, size.y / REFERENCE_SIZE.y)
	var origin := (size - REFERENCE_SIZE * scale_factor) * 0.5
	draw_set_transform(origin, 0.0, Vector2.ONE * scale_factor)
	draw_style_box(Tokens.panel_style(Color("142127"), 12), Rect2(Vector2.ZERO, REFERENCE_SIZE))
	draw_rect(Rect2(22, 22, 556, 292), Color("50646a"), false, 3.0)
	draw_line(Vector2(24, 176), Vector2(470, 176), Color("91a6ab"), 5.0)
	draw_line(Vector2(24, 305), Vector2(574, 305), Color("91a6ab"), 5.0)

	for index in 5:
		var step := Vector2(460 + index * 22, 288 - index * 27)
		draw_line(step, step + Vector2(24, 0), Tokens.TEAL, 5.0)
		draw_line(step + Vector2(24, 0), step + Vector2(24, -27), Tokens.TEAL, 3.0)
	_label(Vector2(468, 145), "SALTOS", Tokens.TEAL)

	for region in Catalog.approximate_enemy_regions():
		var rect := Rect2(region.position * REFERENCE_SIZE, region.size * REFERENCE_SIZE)
		draw_style_box(Tokens.panel_style(Color(0.85, 0.44, 0.30, 0.16), 18, Tokens.AMBER), rect)
		_label(rect.get_center() + Vector2(-5, 6), "?", Tokens.AMBER, 24)

	draw_line(Vector2(75, 286), Vector2(380, 286), Tokens.TEAL, 2.0)
	draw_line(Vector2(400, 153), Vector2(98, 153), Tokens.TEAL, 2.0)
	draw_line(Vector2(98, 153), Vector2(110, 145), Tokens.TEAL, 2.0)
	draw_line(Vector2(380, 286), Vector2(368, 278), Tokens.TEAL, 2.0)
	draw_circle(Vector2(63, 281), 8, Tokens.TEAL)
	draw_rect(Rect2(42, 121, 18, 39), Tokens.TEAL, false, 3.0)
	draw_rect(Rect2(133, 257, 15, 15), Tokens.AMBER)
	_label(Vector2(36, 243), "INICIO", Tokens.TEAL)
	_label(Vector2(120, 239), "BASTAO", Tokens.AMBER)
	_label(Vector2(120, 322), "CHECKPOINT", Tokens.AMBER, 14)
	_label(Vector2(34, 107), "SAIDA", Tokens.TEAL)
	_label(Vector2(34, 49), "PLANTA APROXIMADA", Tokens.TEXT_MUTED, 14)

func _label(at: Vector2, value: String, color: Color, font_size := 17) -> void:
	draw_string(get_theme_default_font(), at, value, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size, color)
