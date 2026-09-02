class_name TutorialMissionResult
extends RefCounted

enum Kind {
	NONE,
	FAILED_BY_FALL,
	FAILED_BY_EXECUTION_LIMIT,
	FAILED_BEFORE_OBJECTIVE,
	FAILED_EXTERNALLY,
	COMPLETED,
}

var kind: int
var message: String

func _init(result_kind: int = Kind.NONE, result_message: String = "") -> void:
	kind = result_kind
	message = result_message

func is_failure() -> bool:
	return (
		kind == Kind.FAILED_BY_FALL
		or kind == Kind.FAILED_BY_EXECUTION_LIMIT
		or kind == Kind.FAILED_BEFORE_OBJECTIVE
		or kind == Kind.FAILED_EXTERNALLY
	)

func is_completed() -> bool:
	return kind == Kind.COMPLETED
