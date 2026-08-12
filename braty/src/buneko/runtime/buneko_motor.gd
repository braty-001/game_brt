class_name BunekoMotor
extends RefCounted

enum Direction {
	LEFT = -1,
	RIGHT = 1,
}

var direction: int = Direction.RIGHT
var can_jump: bool = true

func walk() -> bool:
	return true

func run() -> bool:
	return true

func jump() -> bool:
	if not can_jump:
		return false

	return true

func turn() -> bool:
	direction *= -1
	return true
