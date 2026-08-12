class_name BunekoPartSlot
extends RefCounted

enum Value {
	HEAD,
	BODY,
	LOCOMOTION,
}

static func is_valid(value: int) -> bool:
	return value >= Value.HEAD and value <= Value.LOCOMOTION

static func all_slots() -> Array[int]:
	return [Value.HEAD, Value.BODY, Value.LOCOMOTION]

static func key(value: int) -> String:
	match value:
		Value.HEAD:
			return "head"
		Value.BODY:
			return "body"
		Value.LOCOMOTION:
			return "locomotion"
		_:
			return ""
