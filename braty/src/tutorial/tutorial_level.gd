class_name TutorialLevel
extends Node2D

@export var spawn_position := Vector2(80, 248)
@export var gap_start_x := 320.0
@export var gap_end_x := 440.0
@export var goal_position := Vector2(760, 248)
@export var fall_limit_y := 420.0

func required_nodes_present() -> bool:
	return (
		has_node("StartPoint")
		and has_node("Goal")
		and has_node("FallZone")
		and has_node("StartPlatform")
		and has_node("EndPlatform")
	)
