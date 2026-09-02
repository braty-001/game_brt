class_name BunekoMotor
extends RefCounted

const MovementPaceScript = preload("res://src/programming/domain/movement_pace.gd")

enum Direction {
	LEFT = -1,
	RIGHT = 1,
}

var direction: int = Direction.RIGHT
var can_jump: bool = true
var last_movement_pace: int = MovementPaceScript.Value.NORMAL

func walk(pace: int = MovementPaceScript.Value.NORMAL) -> bool:
	if not MovementPaceScript.is_valid(pace):
		return false
	last_movement_pace = pace
	return true

func jump() -> bool:
	if not can_jump:
		return false

	return true

func turn() -> bool:
	direction *= -1
	return true
