class_name EditorBlockState
extends RefCounted

var id: String
var kind: int
var position: Vector2
var condition: ProgramCondition

func _init(
	block_id: String,
	block_kind: int,
	block_position: Vector2 = Vector2.ZERO,
	block_condition: ProgramCondition = null
) -> void:
	id = block_id
	kind = block_kind
	position = block_position
	condition = block_condition

func to_program_block() -> ProgramBlock:
	return ProgramBlock.new(id, kind, _clone_condition(condition))

func _clone_condition(source_condition: ProgramCondition) -> ProgramCondition:
	if source_condition == null:
		return null

	return ProgramCondition.new(source_condition.modality, source_condition.query)
