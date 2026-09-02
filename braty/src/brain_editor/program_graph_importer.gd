class_name ProgramGraphImporter
extends RefCounted

const EditorBlockStateScript = preload("res://src/brain_editor/editor_block_state.gd")
const EditorConnectionStateScript = preload("res://src/brain_editor/editor_connection_state.gd")
const EditorGraphStateScript = preload("res://src/brain_editor/editor_graph_state.gd")
const ProgramConditionScript = preload("res://src/programming/domain/program_condition.gd")

func import_program(program: ProgramDefinition):
	var graph = EditorGraphStateScript.new()
	if program == null:
		return graph

	for block_id in program.blocks:
		var block: ProgramBlock = program.blocks[block_id]
		graph.add_block(EditorBlockStateScript.new(
			block.id,
			block.kind,
			Vector2.ZERO,
			_clone_condition(block.condition),
			block.parameters
		))

	graph.set_start_block(program.start_block_id)
	for connection in program.connections:
		graph.add_connection(EditorConnectionStateScript.new(
			connection.from_block_id,
			connection.from_port,
			connection.to_block_id,
			connection.to_port
		))

	return graph

func _clone_condition(condition: ProgramCondition) -> ProgramCondition:
	if condition == null:
		return null
	return ProgramConditionScript.new(condition.modality, condition.query)
