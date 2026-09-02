class_name TutorialReferenceProgram
extends RefCounted

const BlockKindScript = preload("res://src/programming/domain/block_kind.gd")
const ConditionCatalogScript = preload("res://src/programming/domain/condition_catalog.gd")
const ProgramBlockScript = preload("res://src/programming/domain/program_block.gd")
const ProgramConditionScript = preload("res://src/programming/domain/program_condition.gd")
const ProgramConnectionScript = preload("res://src/programming/domain/program_connection.gd")
const ProgramDefinitionScript = preload("res://src/programming/domain/program_definition.gd")
const MovementPaceScript = preload("res://src/programming/domain/movement_pace.gd")

enum Example {
	IF_GAP,
	WHILE_PATH_CLEAR,
}

static func build_program() -> ProgramDefinition:
	return build_while_example()

static func build_example(example: int) -> ProgramDefinition:
	match example:
		Example.IF_GAP:
			return build_if_example()
		Example.WHILE_PATH_CLEAR:
			return build_while_example()
		_:
			return build_while_example()

static func build_if_example() -> ProgramDefinition:
	var program := ProgramDefinitionScript.new()
	var path_condition := ProgramConditionScript.new(
		ConditionCatalogScript.Modality.VISION,
		ConditionCatalogScript.Query.PATH_CLEAR_AHEAD
	)
	var gap_condition := ProgramConditionScript.new(
		ConditionCatalogScript.Modality.VISION,
		ConditionCatalogScript.Query.GAP_AHEAD
	)

	program.start_block_id = "while_path_clear"
	program.add_block(ProgramBlockScript.new("while_path_clear", BlockKindScript.Value.WHILE, path_condition))
	program.add_block(ProgramBlockScript.new("walk_clear_path", BlockKindScript.Value.WALK))
	program.add_block(ProgramBlockScript.new("if_gap", BlockKindScript.Value.IF, gap_condition))
	program.add_block(ProgramBlockScript.new("jump_gap", BlockKindScript.Value.JUMP))
	program.add_block(ProgramBlockScript.new(
		"walk_fast_goal",
		BlockKindScript.Value.WALK,
		null,
		{MovementPaceScript.PARAMETER_KEY: MovementPaceScript.Value.FAST}
	))
	program.add_connection(ProgramConnectionScript.new("while_path_clear", "body", "walk_clear_path"))
	program.add_connection(ProgramConnectionScript.new("while_path_clear", "next", "if_gap"))
	program.add_connection(ProgramConnectionScript.new("if_gap", "true", "jump_gap"))
	program.add_connection(ProgramConnectionScript.new("jump_gap", "next", "walk_fast_goal"))
	return program

static func build_while_example() -> ProgramDefinition:
	var program := ProgramDefinitionScript.new()
	var path_condition := ProgramConditionScript.new(
		ConditionCatalogScript.Modality.VISION,
		ConditionCatalogScript.Query.PATH_CLEAR_AHEAD
	)
	var goal_path_condition := ProgramConditionScript.new(
		ConditionCatalogScript.Modality.VISION,
		ConditionCatalogScript.Query.PATH_CLEAR_AHEAD
	)

	program.start_block_id = "while_path_clear"
	program.add_block(ProgramBlockScript.new("while_path_clear", BlockKindScript.Value.WHILE, path_condition))
	program.add_block(ProgramBlockScript.new("walk_clear_path", BlockKindScript.Value.WALK))
	program.add_block(ProgramBlockScript.new("jump_gap", BlockKindScript.Value.JUMP))
	program.add_block(ProgramBlockScript.new("while_goal_path_clear", BlockKindScript.Value.WHILE, goal_path_condition))
	program.add_block(ProgramBlockScript.new(
		"walk_fast_goal",
		BlockKindScript.Value.WALK,
		null,
		{MovementPaceScript.PARAMETER_KEY: MovementPaceScript.Value.FAST}
	))
	program.add_connection(ProgramConnectionScript.new("while_path_clear", "body", "walk_clear_path"))
	program.add_connection(ProgramConnectionScript.new("while_path_clear", "next", "jump_gap"))
	program.add_connection(ProgramConnectionScript.new("jump_gap", "next", "while_goal_path_clear"))
	program.add_connection(ProgramConnectionScript.new("while_goal_path_clear", "body", "walk_fast_goal"))
	return program
