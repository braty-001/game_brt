extends GutTest

const BlockKind = preload("res://src/programming/domain/block_kind.gd")
const MovementPaceScript = preload("res://src/programming/domain/movement_pace.gd")
const ProgramBlockScript = preload("res://src/programming/domain/program_block.gd")
const ProgramDefinitionScript = preload("res://src/programming/domain/program_definition.gd")
const ProgramRamCalculatorScript = preload("res://src/programming/domain/program_ram_calculator.gd")
const ProgramValidatorScript = preload("res://src/programming/domain/program_validator.gd")

func test_empty_parameters_mean_normal_pace() -> void:
	assert_eq(MovementPaceScript.from_parameters({}), MovementPaceScript.Value.NORMAL)
	assert_eq(MovementPaceScript.speed_multiplier(MovementPaceScript.Value.NORMAL), 1.0)
	assert_eq(MovementPaceScript.speed_multiplier(MovementPaceScript.Value.FAST), 2.0)

func test_walk_accepts_only_known_pace_parameter() -> void:
	assert_true(ProgramBlockScript.new("normal", BlockKind.Value.WALK).is_valid())
	assert_true(ProgramBlockScript.new(
		"fast",
		BlockKind.Value.WALK,
		null,
		{MovementPaceScript.PARAMETER_KEY: MovementPaceScript.Value.FAST}
	).is_valid())
	assert_false(ProgramBlockScript.new(
		"invalid",
		BlockKind.Value.WALK,
		null,
		{MovementPaceScript.PARAMETER_KEY: 99}
	).is_valid())
	assert_false(ProgramBlockScript.new(
		"unexpected",
		BlockKind.Value.JUMP,
		null,
		{MovementPaceScript.PARAMETER_KEY: MovementPaceScript.Value.FAST}
	).is_valid())

func test_pace_parameter_does_not_change_ram_cost() -> void:
	var program = ProgramDefinitionScript.new()
	program.start_block_id = "walk"
	program.add_block(ProgramBlockScript.new(
		"walk",
		BlockKind.Value.WALK,
		null,
		{MovementPaceScript.PARAMETER_KEY: MovementPaceScript.Value.FAST}
	))

	assert_eq(ProgramValidatorScript.validate(program).size(), 0)
	assert_eq(ProgramRamCalculatorScript.used_ram(program), 1)

func test_removed_run_identifier_is_reserved_and_invalid() -> void:
	assert_false(BlockKind.is_valid(1))
