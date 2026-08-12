class_name TutorialMissionState
extends RefCounted

enum Value {
	ASSEMBLY,
	EDITING,
	RUNNING,
	FAILED,
	COMPLETED,
}

static func can_edit(value: int) -> bool:
	return value == Value.ASSEMBLY or value == Value.EDITING or value == Value.FAILED
