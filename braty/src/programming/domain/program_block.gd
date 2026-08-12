class_name ProgramBlock
extends RefCounted

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
		return condition != null and condition.is_valid()

	return condition == null
