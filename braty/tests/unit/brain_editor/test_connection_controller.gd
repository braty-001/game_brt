extends GutTest

const BlockKind = preload("res://src/programming/domain/block_kind.gd")
const ConnectionControllerScript = preload("res://src/brain_editor/connection_controller.gd")
const EditorBlockStateScript = preload("res://src/brain_editor/editor_block_state.gd")
const EditorGraphStateScript = preload("res://src/brain_editor/editor_graph_state.gd")
const ProgramGraphBuilderScript = preload("res://src/brain_editor/program_graph_builder.gd")
const ProgramValidatorScript = preload("res://src/programming/domain/program_validator.gd")

func test_connects_valid_action_output_to_block_input() -> void:
	var graph = _graph_with_blocks()
	var controller = ConnectionControllerScript.new()

	assert_true(controller.connect_blocks(graph, "walk", "next", "jump"))

	assert_eq(graph.connections.size(), 1)
	assert_eq(controller.last_error, ConnectionControllerScript.ErrorCode.NONE)

func test_rejects_invalid_output_port() -> void:
	var graph = _graph_with_blocks()
	var controller = ConnectionControllerScript.new()

	assert_false(controller.connect_blocks(graph, "walk", "true", "jump"))

	assert_eq(controller.last_error, ConnectionControllerScript.ErrorCode.INVALID_OUTPUT_PORT)
	assert_eq(graph.connections.size(), 0)

func test_rejects_duplicate_output_and_input() -> void:
	var graph = _graph_with_blocks()
	var controller = ConnectionControllerScript.new()
	graph.add_block(EditorBlockStateScript.new("turn", BlockKind.Value.TURN))

	assert_true(controller.connect_blocks(graph, "walk", "next", "jump"))
	assert_false(controller.connect_blocks(graph, "walk", "next", "turn"))
	assert_eq(controller.last_error, ConnectionControllerScript.ErrorCode.DUPLICATE_OUTPUT)

	assert_false(controller.connect_blocks(graph, "turn", "next", "jump"))
	assert_eq(controller.last_error, ConnectionControllerScript.ErrorCode.DUPLICATE_INPUT)

func test_control_block_ports_build_valid_program() -> void:
	var graph = EditorGraphStateScript.new()
	graph.start_block_id = "if"
	graph.add_block(EditorBlockStateScript.new("if", BlockKind.Value.IF, Vector2.ZERO, _gap_condition()))
	graph.add_block(EditorBlockStateScript.new("jump", BlockKind.Value.JUMP))
	graph.add_block(EditorBlockStateScript.new("walk", BlockKind.Value.WALK))
	var controller = ConnectionControllerScript.new()

	assert_true(controller.connect_blocks(graph, "if", "true", "jump"))
	assert_true(controller.connect_blocks(graph, "if", "false", "walk"))

	var program = ProgramGraphBuilderScript.new().build(graph)
	assert_eq(ProgramValidatorScript.validate(program).size(), 0)

func test_disconnect_removes_output_connection() -> void:
	var graph = _graph_with_blocks()
	var controller = ConnectionControllerScript.new()
	controller.connect_blocks(graph, "walk", "next", "jump")

	assert_eq(controller.disconnect_output(graph, "walk", "next"), 1)

	assert_eq(graph.connections.size(), 0)

func _graph_with_blocks():
	var graph = EditorGraphStateScript.new()
	graph.start_block_id = "walk"
	graph.add_block(EditorBlockStateScript.new("walk", BlockKind.Value.WALK))
	graph.add_block(EditorBlockStateScript.new("jump", BlockKind.Value.JUMP))
	return graph

func _gap_condition():
	return load("res://src/programming/domain/program_condition.gd").new(
		load("res://src/programming/domain/condition_catalog.gd").Modality.VISION,
		load("res://src/programming/domain/condition_catalog.gd").Query.GAP_AHEAD
	)
