class_name ProgramBlock
extends RefCounted

const MovementPaceScript = preload("res://src/programming/domain/movement_pace.gd")

var id: String
var kind: int
var condition: ProgramCondition
var parameters: Dictionary

func _init(
	block_id: String,
	block_kind: int,
	block_condition: ProgramCondition = null,
	block_parameters: Dictionary = {}
) -> void:
	id = block_id
	kind = block_kind
	condition = block_condition
	parameters = block_parameters.duplicate(true)

func is_valid() -> bool:
	if id.is_empty() or not ProgramBlockKind.is_valid(kind):
		return false

	if ProgramBlockKind.requires_condition(kind):
		return condition != null and condition.is_valid() and parameters.is_empty()

	if kind == ProgramBlockKind.Value.WALK:
		return condition == null and MovementPaceScript.parameters_are_valid(parameters)

	return condition == null and parameters.is_empty()
