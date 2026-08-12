class_name ProgramValidationError
extends RefCounted

enum Code {
	MISSING_START,
	UNKNOWN_START,
	INVALID_BLOCK,
	UNKNOWN_CONNECTION_BLOCK,
	INVALID_OUTPUT_PORT,
	INVALID_INPUT_PORT,
	DUPLICATE_OUTPUT,
	DUPLICATE_INPUT,
	ARBITRARY_CYCLE,
	RAM_LIMIT_EXCEEDED,
}

var code: Code
var subject_id: String

func _init(error_code: Code, error_subject_id: String = "") -> void:
	code = error_code
	subject_id = error_subject_id
