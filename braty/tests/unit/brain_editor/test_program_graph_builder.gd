extends GutTest

const BlockKind = preload("res://src/programming/domain/block_kind.gd")
const ConditionCatalogScript = preload("res://src/programming/domain/condition_catalog.gd")
const EditorBlockStateScript = preload("res://src/brain_editor/editor_block_state.gd")
const EditorConnectionStateScript = preload("res://src/brain_editor/editor_connection_state.gd")
const EditorGraphStateScript = preload("res://src/brain_editor/editor_graph_state.gd")
const ProgramConditionScript = preload("res://src/programming/domain/program_condition.gd")
const ProgramGraphBuilderScript = preload("res://src/brain_editor/program_graph_builder.gd")
const ProgramRamCalculatorScript = preload("res://src/programming/domain/program_ram_calculator.gd")
const ProgramValidatorScript = preload("res://src/programming/domain/program_validator.gd")

func test_builds_linear_program_from_editor_graph() -> void:
	var graph = EditorGraphStateScript.new()
	graph.start_block_id = "walk"
	assert_true(graph.add_block(EditorBlockStateScript.new("walk", BlockKind.Value.WALK)))
	assert_true(graph.add_block(EditorBlockStateScript.new("jump", BlockKind.Value.JUMP)))
	assert_true(graph.add_connection(EditorConnectionStateScript.new("walk", "next", "jump")))

	var program = _build_program(graph)

	assert_eq(program.start_block_id, "walk")
	assert_true(program.blocks.has("walk"))
	assert_true(program.blocks.has("jump"))
	assert_eq(program.connections.size(), 1)
	assert_eq(ProgramValidatorScript.validate(program).size(), 0)

func test_disconnected_blocks_do_not_count_toward_ram() -> void:
	var graph = EditorGraphStateScript.new()
	graph.start_block_id = "walk"
	graph.add_block(EditorBlockStateScript.new("walk", BlockKind.Value.WALK))
	graph.add_block(EditorBlockStateScript.new("unused", BlockKind.Value.RUN))

	var program = _build_program(graph)

	assert_eq(program.blocks.size(), 2)
	assert_eq(ProgramRamCalculatorScript.used_ram(program), 1)

func test_control_blocks_keep_conditions_and_ports() -> void:
	var gap_condition: ProgramCondition = ProgramConditionScript.new(
		ConditionCatalogScript.Modality.VISION,
		ConditionCatalogScript.Query.GAP_AHEAD
	)
	var graph = EditorGraphStateScript.new()
	graph.start_block_id = "if"
	graph.add_block(EditorBlockStateScript.new("if", BlockKind.Value.IF, Vector2.ZERO, gap_condition))
	graph.add_block(EditorBlockStateScript.new("jump", BlockKind.Value.JUMP))
	graph.add_block(EditorBlockStateScript.new("while", BlockKind.Value.WHILE, Vector2.ZERO, gap_condition))
	graph.add_block(EditorBlockStateScript.new("run", BlockKind.Value.RUN))
	graph.add_connection(EditorConnectionStateScript.new("if", "true", "jump"))
	graph.add_connection(EditorConnectionStateScript.new("if", "false", "while"))
	graph.add_connection(EditorConnectionStateScript.new("while", "body", "run"))

	var program = _build_program(graph)

	assert_eq(program.connections.size(), 3)
	assert_eq(program.blocks["if"].condition.query, ConditionCatalogScript.Query.GAP_AHEAD)
	assert_eq(program.blocks["while"].condition.modality, ConditionCatalogScript.Modality.VISION)
	assert_eq(ProgramValidatorScript.validate(program).size(), 0)

func test_removing_block_removes_related_connections() -> void:
	var graph = EditorGraphStateScript.new()
	graph.start_block_id = "walk"
	graph.add_block(EditorBlockStateScript.new("walk", BlockKind.Value.WALK))
	graph.add_block(EditorBlockStateScript.new("jump", BlockKind.Value.JUMP))
	graph.add_block(EditorBlockStateScript.new("turn", BlockKind.Value.TURN))
	graph.add_connection(EditorConnectionStateScript.new("walk", "next", "jump"))
	graph.add_connection(EditorConnectionStateScript.new("jump", "next", "turn"))

	assert_true(graph.remove_block("jump"))

	assert_eq(graph.connections.size(), 0)

func test_moving_block_does_not_change_program_definition() -> void:
	var graph = EditorGraphStateScript.new()
	graph.start_block_id = "walk"
	graph.add_block(EditorBlockStateScript.new("walk", BlockKind.Value.WALK))
	var before_move = _build_program(graph)

	assert_true(graph.move_block("walk", Vector2(42, 13)))
	var after_move = _build_program(graph)

	assert_eq(before_move.start_block_id, after_move.start_block_id)
	assert_eq(before_move.blocks["walk"].kind, after_move.blocks["walk"].kind)
	assert_eq(after_move.connections.size(), 0)

func _build_program(graph) -> ProgramDefinition:
	var builder = ProgramGraphBuilderScript.new()
	return builder.build(graph)
