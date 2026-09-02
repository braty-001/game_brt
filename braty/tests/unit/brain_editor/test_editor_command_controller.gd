extends GutTest

const BlockFactoryScript = preload("res://src/brain_editor/block_factory.gd")
const BlockKind = preload("res://src/programming/domain/block_kind.gd")
const ConnectionControllerScript = preload("res://src/brain_editor/connection_controller.gd")
const EditorCommandControllerScript = preload("res://src/brain_editor/editor_command_controller.gd")
const EditorGraphStateScript = preload("res://src/brain_editor/editor_graph_state.gd")
const MovementPaceScript = preload("res://src/programming/domain/movement_pace.gd")

func test_insert_connect_move_and_remove_keep_graph_consistent() -> void:
	var graph = EditorGraphStateScript.new()
	var controller = _controller_for(graph)

	var walk_result: Dictionary = controller.insert_block(BlockKind.Value.WALK, Vector2(40, 50))
	var jump_result: Dictionary = controller.insert_block(BlockKind.Value.JUMP, Vector2(180, 50))
	var walk = walk_result["value"]
	var jump = jump_result["value"]

	assert_true(walk_result["is_success"])
	assert_true(jump_result["is_success"])
	assert_eq(graph.start_block_id, walk.id)
	assert_true(controller.connect_blocks(walk.id, "next", jump.id)["is_success"])
	assert_true(controller.move_block(jump.id, Vector2(240, 120))["is_success"])
	assert_true(controller.set_parameter(
		walk.id,
		MovementPaceScript.PARAMETER_KEY,
		MovementPaceScript.Value.FAST
	)["is_success"])
	assert_eq(
		MovementPaceScript.from_parameters(graph.blocks[walk.id].parameters),
		MovementPaceScript.Value.FAST
	)
	assert_eq(graph.blocks[jump.id].position, Vector2(240, 120))
	assert_true(controller.remove_block(jump.id)["is_success"])
	assert_eq(graph.blocks.size(), 1)
	assert_eq(graph.connections.size(), 0)

func test_invalid_commands_leave_graph_unchanged() -> void:
	var graph = EditorGraphStateScript.new()
	var controller = _controller_for(graph)
	var walk = controller.insert_block(BlockKind.Value.WALK, Vector2.ZERO)["value"]

	var connection_result: Dictionary = controller.connect_blocks(walk.id, "true", "missing")
	assert_false(connection_result["is_success"])
	assert_eq(connection_result["error_code"], EditorCommandControllerScript.ErrorCode.CONNECTION_REJECTED)
	assert_false(controller.move_block("missing", Vector2.ONE)["is_success"])
	assert_false(controller.remove_block("missing")["is_success"])
	assert_eq(graph.blocks.size(), 1)
	assert_eq(graph.connections.size(), 0)

func _controller_for(graph):
	var controller = EditorCommandControllerScript.new()
	controller.configure(graph, BlockFactoryScript.new(), ConnectionControllerScript.new())
	return controller
