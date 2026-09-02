class_name BunekoSimpleParts
extends RefCounted

const OUTLINE := Color("223039")
const HEAD_FILL := Color("aeb6ba")
const BODY_FILL := Color("858f94")
const LOCOMOTION_FILL := Color("646f75")
const DIRECTION_MARKER := Color("e6ecef")

static func draw_head(canvas: CanvasItem, rect: Rect2) -> void:
	var box := _centered_box(rect, Vector2(0.58, 0.58))
	_draw_box(canvas, box, HEAD_FILL)
	var marker_size := Vector2(
		maxf(3.0, box.size.x * 0.10),
		maxf(5.0, box.size.y * 0.30)
	)
	var marker := Rect2(
		Vector2(box.end.x - marker_size.x - box.size.x * 0.08, box.get_center().y - marker_size.y * 0.5),
		marker_size
	)
	canvas.draw_rect(marker, DIRECTION_MARKER, true)

static func draw_body(canvas: CanvasItem, rect: Rect2) -> void:
	_draw_box(canvas, _centered_box(rect, Vector2(0.58, 0.72)), BODY_FILL)

static func draw_locomotion(canvas: CanvasItem, rect: Rect2) -> void:
	_draw_box(canvas, _centered_box(rect, Vector2(0.72, 0.42)), LOCOMOTION_FILL)

static func draw_complete(canvas: CanvasItem, origin: Vector2, scale_factor: float = 1.0) -> void:
	draw_head(canvas, Rect2(origin + Vector2(-36, -80) * scale_factor, Vector2(72, 62) * scale_factor))
	draw_body(canvas, Rect2(origin + Vector2(-30, -31) * scale_factor, Vector2(60, 54) * scale_factor))
	draw_locomotion(canvas, Rect2(origin + Vector2(-33, 9) * scale_factor, Vector2(66, 42) * scale_factor))

static func _centered_box(rect: Rect2, fill_ratio: Vector2) -> Rect2:
	var box_size := rect.size * fill_ratio
	return Rect2(rect.get_center() - box_size * 0.5, box_size)

static func _draw_box(canvas: CanvasItem, rect: Rect2, fill_color: Color) -> void:
	var outline_width := clampf(minf(rect.size.x, rect.size.y) * 0.045, 2.0, 4.0)
	canvas.draw_rect(rect, fill_color, true)
	canvas.draw_rect(rect, OUTLINE, false, outline_width)
