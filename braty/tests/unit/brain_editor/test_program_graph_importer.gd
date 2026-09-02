extends GutTest

const GraphBuilderScript = preload("res://src/brain_editor/program_graph_builder.gd")
const GraphImporterScript = preload("res://src/brain_editor/program_graph_importer.gd")
const ProgramValidatorScript = preload("res://src/programming/domain/program_validator.gd")
const MovementPaceScript = preload("res://src/programming/domain/movement_pace.gd")
const TutorialReferenceProgramScript = preload("res://src/tutorial/tutorial_reference_program.gd")

func test_import_preserves_program_semantics_without_sharing_conditions() -> void:
	var source = TutorialReferenceProgramScript.build_if_example()
	var graph = GraphImporterScript.new().import_program(source)
	var rebuilt = GraphBuilderScript.new().build(graph)

	assert_eq(rebuilt.start_block_id, source.start_block_id)
	assert_eq(rebuilt.blocks.size(), source.blocks.size())
	assert_eq(rebuilt.connections.size(), source.connections.size())
	assert_eq(ProgramValidatorScript.validate(rebuilt).size(), 0)
	assert_eq(rebuilt.blocks["if_gap"].condition.query, source.blocks["if_gap"].condition.query)
	assert_ne(graph.blocks["if_gap"].condition, source.blocks["if_gap"].condition)
	assert_eq(
		MovementPaceScript.from_parameters(rebuilt.blocks["walk_fast_goal"].parameters),
		MovementPaceScript.Value.FAST
	)

func test_import_of_null_program_returns_an_empty_graph() -> void:
	var graph = GraphImporterScript.new().import_program(null)

	assert_true(graph.blocks.is_empty())
	assert_true(graph.connections.is_empty())
	assert_true(graph.start_block_id.is_empty())
