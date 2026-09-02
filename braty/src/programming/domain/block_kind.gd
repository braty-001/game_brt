class_name ProgramBlockKind
extends RefCounted

enum Value {
	WALK = 0,
	JUMP = 2,
	TURN = 3,
	IF = 4,
	WHILE = 5,
}

static func is_valid(value: int) -> bool:
	return value in [Value.WALK, Value.JUMP, Value.TURN, Value.IF, Value.WHILE]

static func requires_condition(value: int) -> bool:
	return value == Value.IF or value == Value.WHILE

static func output_ports(value: int) -> PackedStringArray:
	match value:
		Value.IF:
			return PackedStringArray(["true", "false"])
		Value.WHILE:
			return PackedStringArray(["body", "next"])
		_:
			return PackedStringArray(["next"])
