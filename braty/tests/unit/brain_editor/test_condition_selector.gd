extends GutTest

const BlockKind = preload("res://src/programming/domain/block_kind.gd")
const ConditionCatalogScript = preload("res://src/programming/domain/condition_catalog.gd")
const ConditionSelectorScript = preload("res://src/brain_editor/condition_selector.gd")
const EditorBlockStateScript = preload("res://src/brain_editor/editor_block_state.gd")
const EditorGraphStateScript = preload("res://src/brain_editor/editor_graph_state.gd")

func test_available_options_include_vision_and_hearing() -> void:
	var selector = ConditionSelectorScript.new()

	var options = selector.available_options()

	assert_eq(options.size(), 4)
	assert_eq(options[0]["modality"], ConditionCatalogScript.Modality.VISION)
	assert_eq(options[0]["query"], ConditionCatalogScript.Query.PATH_CLEAR_AHEAD)
	assert_eq(options[3]["modality"], ConditionCatalogScript.Modality.HEARING)

func test_create_condition_rejects_invalid_combination() -> void:
	var selector = ConditionSelectorScript.new()

	assert_null(selector.create_condition(
		ConditionCatalogScript.Modality.HEARING,
		ConditionCatalogScript.Query.PATH_CLEAR_AHEAD
	))

func test_apply_condition_updates_control_block() -> void:
	var selector = ConditionSelectorScript.new()
	var graph = EditorGraphStateScript.new()
	graph.add_block(EditorBlockStateScript.new("while", BlockKind.Value.WHILE))

	assert_true(selector.apply_condition(
		graph,
		"while",
		ConditionCatalogScript.Modality.VISION,
		ConditionCatalogScript.Query.GAP_AHEAD
	))

	assert_eq(graph.blocks["while"].condition.query, ConditionCatalogScript.Query.GAP_AHEAD)
