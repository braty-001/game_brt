class_name OccludedVision
extends RefCounted

const EPSILON := 0.001
const ANGULAR_EPSILON := 0.000001
const DEFAULT_HALF_ANGLE := PI / 3.0
const BOUNDARY_SEGMENTS := 120

var origin := Vector2.ZERO
var radius := 240.0
var facing_direction := 1
var half_angle := DEFAULT_HALF_ANGLE
var occluders: Array[Rect2] = []

func can_see(target: Vector2) -> bool:
	if not _is_inside_cone(target):
		return false
	return has_clear_line(target, radius)

func has_clear_line(target: Vector2, maximum_distance := -1.0) -> bool:
	var limit := radius if maximum_distance < 0.0 else maximum_distance
	var distance := origin.distance_to(target)
	if limit <= 0 or distance > limit + EPSILON:
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
	var offsets: Array[float] = []
	for index in BOUNDARY_SEGMENTS + 1:
		offsets.append(-half_angle + (half_angle * 2.0 * index / BOUNDARY_SEGMENTS))
	var forward_angle := _forward_vector().angle()
	for rect in occluders:
		for corner in [rect.position, Vector2(rect.end.x, rect.position.y), rect.end, Vector2(rect.position.x, rect.end.y)]:
			var relative_angle := wrapf((corner - origin).angle() - forward_angle, -PI, PI)
			if absf(relative_angle) > half_angle + ANGULAR_EPSILON:
				continue
			for offset in [-0.0001, 0.0, 0.0001]:
				offsets.append(clampf(relative_angle + offset, -half_angle, half_angle))
	offsets.sort()
	var points := PackedVector2Array()
	for offset in offsets:
		var direction := Vector2.from_angle(forward_angle + offset)
		points.append(origin + direction * ray_distance(direction, radius))
	return points

func _is_inside_cone(target: Vector2) -> bool:
	var offset := target - origin
	if offset.length_squared() < EPSILON * EPSILON:
		return true
	var cosine_limit := cos(clampf(half_angle, 0.0, PI))
	return offset.normalized().dot(_forward_vector()) >= cosine_limit - ANGULAR_EPSILON

func _forward_vector() -> Vector2:
	return Vector2.LEFT if facing_direction < 0 else Vector2.RIGHT

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
