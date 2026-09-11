class_name TutorialAttemptSession
extends "res://src/buneko/runtime/program_attempt_session.gd"

const WorldSensorScript = preload("res://src/tutorial/tutorial_world_sensor.gd")

func start(session_program, session_buneko, level) -> bool:
	if level == null:
		return false
	var sensor = WorldSensorScript.new()
	sensor.gap_start_x = level.gap_start_x
	sensor.gap_end_x = level.gap_end_x
	sensor.goal_position = level.goal_position
	return begin(session_program, session_buneko, sensor)
