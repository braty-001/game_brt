extends GutTest

const BlockKind = preload("res://src/programming/domain/block_kind.gd")
const ConditionCatalogScript = preload("res://src/programming/domain/condition_catalog.gd")
const ConnectionControllerScript = preload("res://src/brain_editor/connection_controller.gd")
const EditorBlockStateScript = preload("res://src/brain_editor/editor_block_state.gd")
const EditorGraphStateScript = preload("res://src/brain_editor/editor_graph_state.gd")
const EditorLayoutControllerScript = preload("res://src/brain_editor/editor_layout_controller.gd")
const ProgramConditionScript = preload("res://src/programming/domain/program_condition.gd")

func test_positions_flow_and_branches_deterministically() -> void:
	var graph = EditorGraphStateScript.new()
	var controller = ConnectionControllerScript.new()
	var condition = ProgramConditionScript.new(
		ConditionCatalogScript.Modality.VISION,
		ConditionCatalogScript.Query.GAP_AHEAD
	)
	graph.add_block(EditorBlockStateScript.new("if", BlockKind.Value.IF, Vector2.ZERO, condition))
	graph.add_block(EditorBlockStateScript.new("jump", BlockKind.Value.JUMP))
	graph.add_block(EditorBlockStateScript.new("walk", BlockKind.Value.WALK))
	graph.set_start_block("if")
	assert_true(controller.connect_blocks(graph, "if", "true", "jump"))
	assert_true(controller.connect_blocks(graph, "if", "false", "walk"))

	var layout = EditorLayoutControllerScript.new()
	var positions: Dictionary = layout.positions_for(graph)

	assert_eq(positions["if"], layout.ORIGIN)
	assert_eq(positions["jump"], layout.ORIGIN + layout.TRUE_OFFSET)
	assert_eq(positions["walk"], layout.ORIGIN + layout.FALSE_OFFSET)
	assert_eq(graph.connections.size(), 2)

func test_empty_graph_has_no_layout_positions() -> void:
	var positions = EditorLayoutControllerScript.new().positions_for(EditorGraphStateScript.new())

	assert_true(positions.is_empty())
