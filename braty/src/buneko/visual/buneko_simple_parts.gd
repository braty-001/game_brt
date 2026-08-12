class_name BunekoSimpleParts
extends RefCounted

const OUTLINE := Color("223039")
const FACE := Color("f5c85d")
const BODY := Color("56b6c2")
const LEG := Color("7c5cff")
const SHADOW := Color("000000", 0.16)
const EYE := Color("172129")
const CHEEK := Color("f07f7f")

static func draw_head(canvas: CanvasItem, rect: Rect2) -> void:
	var center := rect.get_center()
	var radius: float = minf(rect.size.x, rect.size.y) * 0.34
	_draw_ear(canvas, center + Vector2(-radius * 0.72, -radius * 0.7), radius, -1.0)
	_draw_ear(canvas, center + Vector2(radius * 0.72, -radius * 0.7), radius, 1.0)
	canvas.draw_circle(center + Vector2(2, 3), radius, SHADOW)
	canvas.draw_circle(center, radius, FACE)
	canvas.draw_arc(center, radius, 0.0, TAU, 48, OUTLINE, 3.0)
	canvas.draw_circle(center + Vector2(-radius * 0.34, -radius * 0.1), radius * 0.11, EYE)
	canvas.draw_circle(center + Vector2(radius * 0.34, -radius * 0.1), radius * 0.11, EYE)
	canvas.draw_line(center + Vector2(-radius * 0.1, radius * 0.24), center + Vector2(radius * 0.1, radius * 0.24), EYE, 2.0)
	canvas.draw_circle(center + Vector2(-radius * 0.54, radius * 0.16), radius * 0.08, CHEEK)
	canvas.draw_circle(center + Vector2(radius * 0.54, radius * 0.16), radius * 0.08, CHEEK)

static func draw_body(canvas: CanvasItem, rect: Rect2) -> void:
	var body_rect := rect.grow(-rect.size.x * 0.22)
	body_rect.position.y += rect.size.y * 0.06
	body_rect.size.y *= 1.08
	canvas.draw_rect(_offset_rect(body_rect, Vector2(2, 3)), SHADOW, true)
	canvas.draw_rect(body_rect, BODY, true)
	canvas.draw_rect(body_rect, OUTLINE, false, 3.0)
	var heart := PackedVector2Array([
		body_rect.get_center() + Vector2(0, -7),
		body_rect.get_center() + Vector2(9, 1),
		body_rect.get_center() + Vector2(0, 12),
		body_rect.get_center() + Vector2(-9, 1),
	])
	canvas.draw_colored_polygon(heart, FACE)

static func draw_locomotion(canvas: CanvasItem, rect: Rect2) -> void:
	var center := rect.get_center()
	var foot_size := Vector2(rect.size.x * 0.34, rect.size.y * 0.22)
	var left_foot := Rect2(center + Vector2(-foot_size.x - 4, -foot_size.y * 0.2), foot_size)
	var right_foot := Rect2(center + Vector2(4, -foot_size.y * 0.2), foot_size)
	canvas.draw_line(center + Vector2(-14, -28), left_foot.get_center() + Vector2(0, -2), OUTLINE, 5.0)
	canvas.draw_line(center + Vector2(14, -28), right_foot.get_center() + Vector2(0, -2), OUTLINE, 5.0)
	_draw_foot(canvas, left_foot)
	_draw_foot(canvas, right_foot)
	canvas.draw_line(center + Vector2(-22, -34), center + Vector2(22, -34), OUTLINE, 4.0)

static func draw_complete(canvas: CanvasItem, origin: Vector2, scale_factor: float = 1.0) -> void:
	draw_head(canvas, Rect2(origin + Vector2(-36, -80) * scale_factor, Vector2(72, 62) * scale_factor))
	draw_body(canvas, Rect2(origin + Vector2(-30, -31) * scale_factor, Vector2(60, 54) * scale_factor))
	draw_locomotion(canvas, Rect2(origin + Vector2(-33, 9) * scale_factor, Vector2(66, 42) * scale_factor))

static func _draw_ear(canvas: CanvasItem, center: Vector2, radius: float, direction: float) -> void:
	var points := PackedVector2Array([
		center + Vector2(-radius * 0.22 * direction, radius * 0.16),
		center + Vector2(radius * 0.1 * direction, -radius * 0.66),
		center + Vector2(radius * 0.5 * direction, radius * 0.18),
	])
	canvas.draw_colored_polygon(points, FACE)
	canvas.draw_polyline(PackedVector2Array([points[0], points[1], points[2], points[0]]), OUTLINE, 3.0)

static func _draw_foot(canvas: CanvasItem, rect: Rect2) -> void:
	canvas.draw_rect(_offset_rect(rect, Vector2(2, 2)), SHADOW, true)
	canvas.draw_rect(rect, LEG, true)
	canvas.draw_rect(rect, OUTLINE, false, 3.0)

static func _offset_rect(rect: Rect2, offset: Vector2) -> Rect2:
	return Rect2(rect.position + offset, rect.size)
