extends GutTest

const BlockKind = preload("res://src/programming/domain/block_kind.gd")
const ConditionCatalogScript = preload("res://src/programming/domain/condition_catalog.gd")
const ConnectionControllerScript = preload("res://src/brain_editor/connection_controller.gd")
const EditorBlockStateScript = preload("res://src/brain_editor/editor_block_state.gd")
const EditorGraphStateScript = preload("res://src/brain_editor/editor_graph_state.gd")
const PresenterScript = preload("res://src/brain_editor/pseudocode_presenter.gd")
const ProgramConditionScript = preload("res://src/programming/domain/program_condition.gd")

func test_presents_a_valid_if_in_portuguese() -> void:
	var graph = EditorGraphStateScript.new()
	var controller = ConnectionControllerScript.new()
	graph.add_block(EditorBlockStateScript.new("if", BlockKind.Value.IF, Vector2.ZERO, _gap_condition()))
	graph.add_block(EditorBlockStateScript.new("jump", BlockKind.Value.JUMP))
	graph.add_block(EditorBlockStateScript.new("walk", BlockKind.Value.WALK))
	graph.set_start_block("if")
	controller.connect_blocks(graph, "if", "true", "jump")
	controller.connect_blocks(graph, "if", "false", "walk")

	var result: Dictionary = PresenterScript.new().present(graph)

	assert_true(result["is_valid"])
	assert_eq(result["text"], "SE BURACO A FRENTE ENTAO\n  PULAR\nSENAO\n  ANDAR NORMAL\nFIM")

func test_invalid_graph_returns_a_short_diagnostic() -> void:
	var result: Dictionary = PresenterScript.new().present(EditorGraphStateScript.new())

	assert_false(result["is_valid"])
	assert_true(result["text"].contains("Programa incompleto"))

func _gap_condition() -> ProgramCondition:
	return ProgramConditionScript.new(ConditionCatalogScript.Modality.VISION, ConditionCatalogScript.Query.GAP_AHEAD)
