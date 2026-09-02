class_name BrainEditorViewportController
extends RefCounted

const MIN_ZOOM := 0.6
const MAX_ZOOM := 1.6
const DEFAULT_ZOOM := 1.0

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

func world_to_viewport(world_position: Vector2) -> Vector2:
	return world_position * zoom + pan

func viewport_to_world(viewport_position: Vector2) -> Vector2:
	return (viewport_position - pan) / zoom

func zoom_label() -> String:
	return "%d%%" % roundi(zoom * 100.0)
