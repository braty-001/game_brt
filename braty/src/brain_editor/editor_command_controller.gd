class_name BrainEditorCommandController
extends RefCounted

const CommandResultScript = preload("res://src/brain_editor/editor_command_result.gd")

enum ErrorCode {
	NONE,
	MISSING_DEPENDENCY,
	INVALID_BLOCK,
	UNKNOWN_BLOCK,
	CONNECTION_REJECTED,
}

var graph_state
var block_factory
var connection_controller

func configure(next_graph_state, next_block_factory, next_connection_controller) -> void:
	graph_state = next_graph_state
	block_factory = next_block_factory
	connection_controller = next_connection_controller

func insert_block(kind: int, position: Vector2) -> CommandResultScript:
	if graph_state == null or block_factory == null:
		return _result(false, null, ErrorCode.MISSING_DEPENDENCY)

	var block_state = block_factory.create_block(kind, position)
	if block_state == null or not graph_state.add_block(block_state):
		return _result(false, null, ErrorCode.INVALID_BLOCK)
	if graph_state.start_block_id.is_empty():
		graph_state.set_start_block(block_state.id)
	return _result(true, block_state)

func insert_connected_block(kind: int, position: Vector2, from_block_id: String, from_port: String) -> CommandResultScript:
	if graph_state == null or not graph_state.begin_batch():
		return _result(false, null, ErrorCode.MISSING_DEPENDENCY)

	var insert_result: CommandResultScript = insert_block(kind, position)
	if not insert_result.is_success:
		graph_state.discard_batch()
		return insert_result
	var block_state = insert_result.value
	var connection_result: CommandResultScript = connect_blocks(from_block_id, from_port, block_state.id)
	if connection_result.is_success:
		graph_state.commit_batch()
		return insert_result
	graph_state.remove_block(block_state.id)
	graph_state.discard_batch()
	return _result(false, null, connection_result.error_code, connection_result.connection_error)

func remove_block(block_id: String) -> CommandResultScript:
	if graph_state == null or not graph_state.remove_block(block_id):
		return _result(false, null, ErrorCode.UNKNOWN_BLOCK)
	return _result(true)

func move_block(block_id: String, position: Vector2) -> CommandResultScript:
	if graph_state == null or not graph_state.move_block(block_id, position):
		return _result(false, null, ErrorCode.UNKNOWN_BLOCK)
	return _result(true)

func connect_blocks(from_block_id: String, from_port: String, to_block_id: String) -> CommandResultScript:
	if connection_controller == null:
		return _result(false, null, ErrorCode.MISSING_DEPENDENCY)
	if not connection_controller.connect_blocks(graph_state, from_block_id, from_port, to_block_id):
		return _result(false, null, ErrorCode.CONNECTION_REJECTED, connection_controller.last_error)
	return _result(true)

func disconnect_output(from_block_id: String, from_port: String) -> CommandResultScript:
	if connection_controller == null:
		return _result(false, 0, ErrorCode.MISSING_DEPENDENCY)
	var removed_count: int = connection_controller.disconnect_output(graph_state, from_block_id, from_port)
	return _result(removed_count > 0, removed_count, ErrorCode.NONE if removed_count > 0 else ErrorCode.CONNECTION_REJECTED)

func set_condition(block_id: String, condition: ProgramCondition) -> CommandResultScript:
	if graph_state == null or not graph_state.set_block_condition(block_id, condition):
		return _result(false, null, ErrorCode.UNKNOWN_BLOCK)
	return _result(true)

func set_parameter(block_id: String, key: String, value) -> CommandResultScript:
	if graph_state == null or not graph_state.set_block_parameter(block_id, key, value):
		return _result(false, null, ErrorCode.UNKNOWN_BLOCK)
	return _result(true)

func _result(is_success: bool, value: Variant = null, error_code := ErrorCode.NONE, connection_error := -1) -> CommandResultScript:
	return CommandResultScript.new(is_success, value, error_code, connection_error)
