class_name BrainEditorViewportController
extends RefCounted

const MIN_ZOOM := 0.6
const MAX_ZOOM := 1.6
const DEFAULT_ZOOM := 1.0
const FRAME_MARGIN := 32.0

var zoom := DEFAULT_ZOOM
var pan := Vector2.ZERO

func zoom_in() -> bool:
	return set_zoom(zoom + 0.2)

func zoom_out() -> bool:
	return set_zoom(zoom - 0.2)

func set_zoom(next_zoom: float) -> bool:
	var clamped_zoom := clampf(next_zoom, MIN_ZOOM, MAX_ZOOM)
	if is_equal_approx(zoom, clamped_zoom):
		return false
	zoom = clamped_zoom
	return true

func pan_by(delta: Vector2) -> bool:
	if delta.is_zero_approx():
		return false
	pan += delta
	return true

func center() -> bool:
	var changed := not pan.is_zero_approx() or not is_equal_approx(zoom, DEFAULT_ZOOM)
	zoom = DEFAULT_ZOOM
	pan = Vector2.ZERO
	return changed

func frame(bounds: Rect2, viewport_size: Vector2) -> bool:
	if bounds.size.x <= 0.0 or bounds.size.y <= 0.0 or viewport_size.x <= FRAME_MARGIN * 2.0 or viewport_size.y <= FRAME_MARGIN * 2.0:
		return false
	var available := viewport_size - Vector2.ONE * FRAME_MARGIN * 2.0
	var next_zoom: float = clampf(minf(1.0, minf(available.x / bounds.size.x, available.y / bounds.size.y)), MIN_ZOOM, DEFAULT_ZOOM)
	var next_pan := Vector2.ZERO
	if next_zoom < DEFAULT_ZOOM or bounds.end.x > available.x or bounds.end.y > available.y:
		next_pan = viewport_size * 0.5 - bounds.get_center() * next_zoom
		var scaled := bounds.size * next_zoom
		if scaled.x > available.x:
			next_pan.x = FRAME_MARGIN - bounds.position.x * next_zoom
		if scaled.y > available.y:
			next_pan.y = FRAME_MARGIN - bounds.position.y * next_zoom
	var changed := not is_equal_approx(zoom, next_zoom) or not pan.is_equal_approx(next_pan)
	zoom = next_zoom
	pan = next_pan
	return changed

func world_to_viewport(world_position: Vector2) -> Vector2:
	return world_position * zoom + pan

func viewport_to_world(viewport_position: Vector2) -> Vector2:
	return (viewport_position - pan) / zoom

func zoom_label() -> String:
	return "%d%%" % roundi(zoom * 100.0)
