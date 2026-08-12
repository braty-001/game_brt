class_name ProgramBlockKind
extends RefCounted

enum Value {
	WALK,
	RUN,
	JUMP,
	TURN,
	IF,
	WHILE,
}

static func is_valid(value: int) -> bool:
	return value >= Value.WALK and value <= Value.WHILE

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
