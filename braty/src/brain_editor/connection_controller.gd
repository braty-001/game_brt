class_name BrainEditorConnectionController
extends RefCounted

const EditorConnectionStateScript = preload("res://src/brain_editor/editor_connection_state.gd")

enum ErrorCode {
	NONE,
	MISSING_GRAPH,
	UNKNOWN_SOURCE,
	UNKNOWN_TARGET,
	INVALID_OUTPUT_PORT,
	INVALID_INPUT_PORT,
	DUPLICATE_OUTPUT,
	DUPLICATE_INPUT,
}

var last_error: int = ErrorCode.NONE

func connect_blocks(
	graph_state,
	from_block_id: String,
	from_port: String,
	to_block_id: String,
	to_port: String = "input"
) -> bool:
	last_error = _validate_connection(graph_state, from_block_id, from_port, to_block_id, to_port)
	if last_error != ErrorCode.NONE:
		return false

	return graph_state.add_connection(
		EditorConnectionStateScript.new(from_block_id, from_port, to_block_id, to_port)
	)

func disconnect_output(graph_state, from_block_id: String, from_port: String) -> int:
	if graph_state == null:
		last_error = ErrorCode.MISSING_GRAPH
		return 0

	last_error = ErrorCode.NONE
	return graph_state.remove_connection(from_block_id, from_port)

func _validate_connection(
	graph_state,
	from_block_id: String,
	from_port: String,
	to_block_id: String,
	to_port: String
) -> int:
	if graph_state == null:
		return ErrorCode.MISSING_GRAPH
	if not graph_state.blocks.has(from_block_id):
		return ErrorCode.UNKNOWN_SOURCE
	if not graph_state.blocks.has(to_block_id):
		return ErrorCode.UNKNOWN_TARGET
	if to_port != "input":
		return ErrorCode.INVALID_INPUT_PORT

	var source_block = graph_state.blocks[from_block_id]
	if not ProgramBlockKind.output_ports(source_block.kind).has(from_port):
		return ErrorCode.INVALID_OUTPUT_PORT

	for connection in graph_state.connections:
		if connection.from_block_id == from_block_id and connection.from_port == from_port:
			return ErrorCode.DUPLICATE_OUTPUT
		if connection.to_block_id == to_block_id:
			return ErrorCode.DUPLICATE_INPUT

	return ErrorCode.NONE
