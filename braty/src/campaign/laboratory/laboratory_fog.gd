class_name LaboratoryFog
extends Node2D

var vision
var world_extent := 2200.0
var _last_origin := Vector2.INF

func _process(_delta: float) -> void:
	if vision != null and not vision.origin.is_equal_approx(_last_origin):
		_last_origin = vision.origin
		queue_redraw()

func _draw() -> void:
	if vision == null:
		return
	var boundary: PackedVector2Array = vision.boundary()
	for index in boundary.size():
		var next := (index + 1) % boundary.size()
		var first := boundary[index]
		var second := boundary[next]
		var outer_first = vision.origin + (first - vision.origin).normalized() * world_extent
		var outer_second = vision.origin + (second - vision.origin).normalized() * world_extent
		if first.is_equal_approx(second):
			continue
		draw_colored_polygon(PackedVector2Array([first, outer_first, outer_second, second]), Color("080e13"))
