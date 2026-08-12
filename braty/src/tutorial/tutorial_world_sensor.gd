class_name TutorialWorldSensor
extends RefCounted

var buneko_position := Vector2.ZERO
var buneko_direction := 1
var gap_start_x := 320.0
var gap_end_x := 440.0
var goal_position := Vector2(720, 240)
var vision_range := 40.0
var path_decision_distance := 40.0
var obstacles: Array[Vector2] = []
var signal_heard := false

func is_path_clear_ahead() -> bool:
	var direction := _normalized_direction()
	var decision_edge := buneko_position.x + path_decision_distance * direction
	if _has_gap_between(buneko_position.x, decision_edge):
		return false
	if _has_obstacle_between(buneko_position.x, decision_edge):
		return false

	return true

func has_gap_ahead() -> bool:
	if buneko_direction >= 0:
		return buneko_position.x < gap_start_x and gap_start_x - buneko_position.x <= vision_range

	return buneko_position.x > gap_end_x and buneko_position.x - gap_end_x <= vision_range

func can_see_goal() -> bool:
	var distance_x := goal_position.x - buneko_position.x
	if buneko_direction >= 0:
		return distance_x >= 0.0 and distance_x <= vision_range

	return distance_x <= 0.0 and abs(distance_x) <= vision_range

func heard_signal() -> bool:
	return signal_heard

func update_from_buneko(buneko) -> void:
	if buneko == null:
		return

	buneko_position = buneko.global_position
	if buneko.controller != null:
		buneko_direction = buneko.controller.direction

func _normalized_direction() -> float:
	return 1.0 if buneko_direction >= 0 else -1.0

func _has_gap_between(from_x: float, to_x: float) -> bool:
	var left: float = min(from_x, to_x)
	var right: float = max(from_x, to_x)
	return left < gap_end_x and right > gap_start_x

func _has_obstacle_between(from_x: float, to_x: float) -> bool:
	var left: float = min(from_x, to_x)
	var right: float = max(from_x, to_x)
	for obstacle_position in obstacles:
		if obstacle_position.x >= left and obstacle_position.x <= right:
			return true

	return false
