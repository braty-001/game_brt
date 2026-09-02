class_name MovementPace
extends RefCounted

const PARAMETER_KEY := "pace"

enum Value {
	NORMAL,
	FAST,
}

static func default_parameters() -> Dictionary:
	return {PARAMETER_KEY: Value.NORMAL}

static func from_parameters(parameters: Dictionary) -> int:
	return int(parameters.get(PARAMETER_KEY, Value.NORMAL))

static func parameters_are_valid(parameters: Dictionary) -> bool:
	if parameters.is_empty():
		return true
	if parameters.size() != 1 or not parameters.has(PARAMETER_KEY):
		return false
	return is_valid(parameters[PARAMETER_KEY])

static func is_valid(value) -> bool:
	return typeof(value) == TYPE_INT and (value == Value.NORMAL or value == Value.FAST)

static func speed_multiplier(value: int) -> float:
	return 2.0 if value == Value.FAST else 1.0

static func label(value: int) -> String:
	return "Rapido" if value == Value.FAST else "Normal"
