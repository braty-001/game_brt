class_name LaboratoryFog
extends Node2D

var vision
var world_extent := 2200.0
var known_solids: Array[Rect2] = []
var _last_origin := Vector2.INF
var _last_facing_direction := 0

func _process(_delta: float) -> void:
	if vision != null and (
		not vision.origin.is_equal_approx(_last_origin)
		or vision.facing_direction != _last_facing_direction
	):
		_last_origin = vision.origin
		_last_facing_direction = vision.facing_direction
		queue_redraw()

func _draw() -> void:
	if vision == null:
		return
	var boundary: PackedVector2Array = vision.boundary()
	for index in maxi(0, boundary.size() - 1):
		var next := index + 1
		var first := boundary[index]
		var second := boundary[next]
		var outer_first = vision.origin + (first - vision.origin).normalized() * world_extent
		var outer_second = vision.origin + (second - vision.origin).normalized() * world_extent
		if first.is_equal_approx(second):
			continue
		draw_colored_polygon(PackedVector2Array([first, outer_first, outer_second, second]), Color("080e13"))
	_draw_outside_cone()
	_draw_known_structure()

func _draw_outside_cone() -> void:
	var forward_angle := 0.0 if vision.facing_direction >= 0 else PI
	var start_angle: float = forward_angle + vision.half_angle
	var outside_angle: float = TAU - vision.half_angle * 2.0
	var segments := 120
	for index in segments:
		var first_angle := start_angle + outside_angle * index / segments
		var second_angle := start_angle + outside_angle * (index + 1) / segments
		var outer_first: Vector2 = vision.origin + Vector2.from_angle(first_angle) * world_extent
		var outer_second: Vector2 = vision.origin + Vector2.from_angle(second_angle) * world_extent
		draw_colored_polygon(
			PackedVector2Array([vision.origin, outer_first, outer_second]),
			Color("080e13")
		)

func _draw_known_structure() -> void:
	var outline := Color("3a6570")
	for rect in known_solids:
		_draw_hidden_edge(rect.position, Vector2(rect.end.x, rect.position.y), Vector2.UP, outline)
		_draw_hidden_edge(Vector2(rect.end.x, rect.position.y), rect.end, Vector2.RIGHT, outline)
		_draw_hidden_edge(rect.end, Vector2(rect.position.x, rect.end.y), Vector2.DOWN, outline)
		_draw_hidden_edge(Vector2(rect.position.x, rect.end.y), rect.position, Vector2.LEFT, outline)

func _draw_hidden_edge(from: Vector2, to: Vector2, outside: Vector2, color: Color) -> void:
	var parts := maxi(1, ceili(from.distance_to(to) / 12.0))
	for index in parts:
		var first := from.lerp(to, float(index) / parts)
		var last := from.lerp(to, float(index + 1) / parts)
		if not vision.can_see((first + last) * 0.5 + outside * 2.0):
			draw_line(first, last, color, 2.0, true)
