class_name OccludedVision
extends RefCounted

const EPSILON := 0.001

var origin := Vector2.ZERO
var radius := 240.0
var occluders: Array[Rect2] = []

func can_see(target: Vector2) -> bool:
	var distance := origin.distance_to(target)
	if radius <= 0 or distance > radius + EPSILON:
		return false
	if distance < EPSILON:
		return true
	return ray_distance((target - origin) / distance, distance) >= distance - EPSILON

func ray_distance(direction: Vector2, maximum: float) -> float:
	var nearest := maximum
	for rect in occluders:
		nearest = minf(nearest, _rect_hit(rect, direction, maximum))
	return nearest

func boundary() -> PackedVector2Array:
	var angles: Array[float] = []
	for index in 180:
		angles.append(TAU * index / 180.0)
	for rect in occluders:
		for corner in [rect.position, Vector2(rect.end.x, rect.position.y), rect.end, Vector2(rect.position.x, rect.end.y)]:
			var angle: float = fposmod((corner - origin).angle(), TAU)
			for offset in [-0.0001, 0.0, 0.0001]:
				angles.append(fposmod(angle + offset, TAU))
	angles.sort()
	var points := PackedVector2Array()
	for angle in angles:
		var direction := Vector2.from_angle(angle)
		points.append(origin + direction * ray_distance(direction, radius))
	return points

func _rect_hit(rect: Rect2, direction: Vector2, maximum: float) -> float:
	var entry := 0.0
	var exit_distance := maximum
	for axis in 2:
		if absf(direction[axis]) < 0.000001:
			if origin[axis] < rect.position[axis] or origin[axis] > rect.end[axis]:
				return maximum
			continue
		var near_distance := (rect.position[axis] - origin[axis]) / direction[axis]
		var far_distance := (rect.end[axis] - origin[axis]) / direction[axis]
		if near_distance > far_distance:
			var swap := near_distance
			near_distance = far_distance
			far_distance = swap
		entry = maxf(entry, near_distance)
		exit_distance = minf(exit_distance, far_distance)
		if entry > exit_distance:
			return maximum
	return clampf(entry, 0.0, maximum)
