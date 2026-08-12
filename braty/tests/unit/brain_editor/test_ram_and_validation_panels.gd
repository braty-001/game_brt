extends GutTest

const BlockKind = preload("res://src/programming/domain/block_kind.gd")
const EditorBlockStateScript = preload("res://src/brain_editor/editor_block_state.gd")
const EditorConnectionStateScript = preload("res://src/brain_editor/editor_connection_state.gd")
const EditorGraphStateScript = preload("res://src/brain_editor/editor_graph_state.gd")
const ProgramGraphBuilderScript = preload("res://src/brain_editor/program_graph_builder.gd")
const RamPanelScript = preload("res://src/brain_editor/ram_panel.gd")
const ValidationPanelScript = preload("res://src/brain_editor/validation_panel.gd")

func test_ram_summary_uses_reachable_blocks() -> void:
	var graph = EditorGraphStateScript.new()
	graph.start_block_id = "walk"
	graph.add_block(EditorBlockStateScript.new("walk", BlockKind.Value.WALK))
	graph.add_block(EditorBlockStateScript.new("jump", BlockKind.Value.JUMP))
	graph.add_block(EditorBlockStateScript.new("unused", BlockKind.Value.RUN))
	graph.add_connection(EditorConnectionStateScript.new("walk", "next", "jump"))
	var program = ProgramGraphBuilderScript.new().build(graph)

	var summary: Dictionary = RamPanelScript.new().summary_for_program(program)

	assert_eq(summary["used"], 2)
	assert_eq(summary["limit"], 5)
	assert_true(summary["is_within_limit"])
	assert_eq(summary["label"], "2/5 RAM")

func test_validation_summary_reports_invalid_program_messages() -> void:
	var graph = EditorGraphStateScript.new()
	var program = ProgramGraphBuilderScript.new().build(graph)

	var summary: Dictionary = ValidationPanelScript.new().summary_for_program(program)

	assert_false(summary["is_valid"])
	assert_gt(summary["messages"].size(), 0)
