class_name BunekoAssemblyPreview
extends Control

const SlotScript = preload("res://src/buneko/domain/part_slot.gd")
const SimpleParts = preload("res://src/buneko/visual/buneko_simple_parts.gd")
const Tokens = preload("res://src/ui/design_tokens.gd")

signal part_dropped(slot: int)

var assembly
var selected_slot := -1
var highlighted_slot := -1

func _ready() -> void:
	custom_minimum_size = Vector2(280, 240)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	queue_redraw()

func set_assembly(value) -> void:
	assembly = value
	queue_redraw()

func set_selected_slot(value: int) -> void:
	selected_slot = value
	queue_redraw()

func set_highlighted_slot(value: int) -> void:
	highlighted_slot = value
	queue_redraw()

func _can_drop_data(_at_position: Vector2, data) -> bool:
	if data is not Dictionary or not data.has("buneko_part_slot"):
		return false
	var slot: int = data["buneko_part_slot"]
	set_highlighted_slot(slot)
	return SlotScript.is_valid(slot)

func _drop_data(_at_position: Vector2, data) -> void:
	var slot: int = data["buneko_part_slot"]
	set_highlighted_slot(-1)
	part_dropped.emit(slot)

func installed_count() -> int:
	if assembly == null:
		return 0
	return assembly.parts_by_slot.size()

func _notification(what: int) -> void:
	if what == NOTIFICATION_RESIZED:
		queue_redraw()

func _draw() -> void:
	var scale_factor: float = minf(size.x / 360.0, size.y / 410.0)
	var origin := Vector2((size.x - 360.0 * scale_factor) * 0.5, (size.y - 410.0 * scale_factor) * 0.5)
	_draw_workbench(origin, scale_factor)
	_draw_slot(SlotScript.Value.HEAD, Rect2(origin + Vector2(70, 22) * scale_factor, Vector2(220, 135) * scale_factor))
	_draw_slot(SlotScript.Value.BODY, Rect2(origin + Vector2(100, 150) * scale_factor, Vector2(160, 130) * scale_factor))
	_draw_slot(SlotScript.Value.LOCOMOTION, Rect2(origin + Vector2(88, 275) * scale_factor, Vector2(184, 128) * scale_factor))

func _draw_workbench(origin: Vector2, scale_factor: float) -> void:
	var pad_rect := Rect2(origin + Vector2(42, 6) * scale_factor, Vector2(276, 397) * scale_factor)
	draw_style_box(Tokens.panel_style(Color("1d292e"), 12, Color("405158")), pad_rect)
	draw_line(origin + Vector2(58, 394) * scale_factor, origin + Vector2(302, 394) * scale_factor, Tokens.TEAL_DARK, 3.0)

func _draw_slot(slot: int, destination: Rect2) -> void:
	var installed := assembly != null and assembly.part_for_slot(slot) != null
	if not installed:
		var color := Tokens.BORDER
		if highlighted_slot == slot:
			color = Tokens.TEAL
		elif selected_slot == slot:
			color = Tokens.AMBER
		draw_style_box(_slot_style(color), destination.grow(-4.0))
		var label := _slot_label(slot)
		draw_string(ThemeDB.fallback_font, destination.get_center() + Vector2(-42, 5), label, HORIZONTAL_ALIGNMENT_CENTER, 84, 14, Tokens.TEXT_MUTED)
	else:
		match slot:
			SlotScript.Value.HEAD:
				SimpleParts.draw_head(self, destination)
			SlotScript.Value.BODY:
				SimpleParts.draw_body(self, destination)
			SlotScript.Value.LOCOMOTION:
				SimpleParts.draw_locomotion(self, destination)

	if selected_slot == slot:
		draw_arc(destination.get_center(), max(destination.size.x, destination.size.y) * 0.53, 0.0, TAU, 48, Tokens.AMBER, 3.0)

func _slot_style(color: Color) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = Color(color, 0.08)
	style.border_color = Color(color, 0.75)
	style.set_border_width_all(2)
	style.set_corner_radius_all(10)
	return style

func _slot_label(slot: int) -> String:
	match slot:
		SlotScript.Value.HEAD:
			return "CABECA"
		SlotScript.Value.BODY:
			return "CORPO"
		SlotScript.Value.LOCOMOTION:
			return "PERNAS"
		_:
			return ""
