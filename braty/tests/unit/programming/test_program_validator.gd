extends GutTest

const BlockKind = preload("res://src/programming/domain/block_kind.gd")
const ConditionCatalogScript = preload("res://src/programming/domain/condition_catalog.gd")
const ProgramBlockScript = preload("res://src/programming/domain/program_block.gd")
const ProgramConditionScript = preload("res://src/programming/domain/program_condition.gd")
const ProgramConnectionScript = preload("res://src/programming/domain/program_connection.gd")
const ProgramDefinitionScript = preload("res://src/programming/domain/program_definition.gd")
const ProgramRamCalculatorScript = preload("res://src/programming/domain/program_ram_calculator.gd")
const ProgramValidationErrorScript = preload("res://src/programming/domain/program_validation_error.gd")
const ProgramValidatorScript = preload("res://src/programming/domain/program_validator.gd")

func test_valid_program_uses_reachable_blocks_for_ram() -> void:
	var program := ProgramDefinitionScript.new()
	program.start_block_id = "walk"
	program.add_block(ProgramBlockScript.new("walk", BlockKind.Value.WALK))
	program.add_block(ProgramBlockScript.new("jump", BlockKind.Value.JUMP))
	program.add_block(ProgramBlockScript.new("unused", BlockKind.Value.RUN))
	program.add_connection(ProgramConnectionScript.new("walk", "next", "jump"))

	assert_eq(ProgramRamCalculatorScript.used_ram(program), 2)
	assert_eq(ProgramValidatorScript.validate(program).size(), 0)

func test_control_blocks_require_valid_sensor_conditions() -> void:
	var valid_condition := ProgramConditionScript.new(
		ConditionCatalogScript.Modality.VISION,
		ConditionCatalogScript.Query.GAP_AHEAD
	)
	var program := ProgramDefinitionScript.new()
	program.start_block_id = "if"
	program.add_block(ProgramBlockScript.new("if", BlockKind.Value.IF, valid_condition))

	assert_eq(ProgramValidatorScript.validate(program).size(), 0)

	var invalid_program := ProgramDefinitionScript.new()
	invalid_program.start_block_id = "while"
	invalid_program.add_block(ProgramBlockScript.new("while", BlockKind.Value.WHILE))

	assert_has_error(
		ProgramValidatorScript.validate(invalid_program),
		ProgramValidationErrorScript.Code.INVALID_BLOCK
	)

func test_hearing_condition_accepts_only_hearing_query() -> void:
	var condition := ProgramConditionScript.new(
		ConditionCatalogScript.Modality.HEARING,
		ConditionCatalogScript.Query.SIGNAL_HEARD
	)

	assert_true(condition.is_valid())

	var invalid_condition := ProgramConditionScript.new(
		ConditionCatalogScript.Modality.HEARING,
		ConditionCatalogScript.Query.GAP_AHEAD
	)
	assert_false(invalid_condition.is_valid())

func test_path_clear_is_valid_only_as_vision_condition() -> void:
	var condition := ProgramConditionScript.new(
		ConditionCatalogScript.Modality.VISION,
		ConditionCatalogScript.Query.PATH_CLEAR_AHEAD
	)

	assert_true(condition.is_valid())
	assert_true(ConditionCatalogScript.is_valid_combination(
		ConditionCatalogScript.Modality.VISION,
		ConditionCatalogScript.Query.PATH_CLEAR_AHEAD
	))
	assert_false(ConditionCatalogScript.is_valid_combination(
		ConditionCatalogScript.Modality.HEARING,
		ConditionCatalogScript.Query.PATH_CLEAR_AHEAD
	))

func test_rejects_missing_or_unknown_start() -> void:
	var missing_start := ProgramDefinitionScript.new()
	assert_has_error(
		ProgramValidatorScript.validate(missing_start),
		ProgramValidationErrorScript.Code.MISSING_START
	)

	var unknown_start := ProgramDefinitionScript.new()
	unknown_start.start_block_id = "unknown"
	assert_has_error(
		ProgramValidatorScript.validate(unknown_start),
		ProgramValidationErrorScript.Code.UNKNOWN_START
	)

func test_rejects_invalid_connections() -> void:
	var program := ProgramDefinitionScript.new()
	program.start_block_id = "walk"
	program.add_block(ProgramBlockScript.new("walk", BlockKind.Value.WALK))
	program.add_block(ProgramBlockScript.new("jump", BlockKind.Value.JUMP))
	program.add_connection(ProgramConnectionScript.new("walk", "true", "jump"))
	program.add_connection(ProgramConnectionScript.new("walk", "next", "jump", "wrong"))

	var errors := ProgramValidatorScript.validate(program)
	assert_has_error(errors, ProgramValidationErrorScript.Code.INVALID_OUTPUT_PORT)
	assert_has_error(errors, ProgramValidationErrorScript.Code.INVALID_INPUT_PORT)

func test_rejects_arbitrary_cycles() -> void:
	var program := ProgramDefinitionScript.new()
	program.start_block_id = "walk"
	program.add_block(ProgramBlockScript.new("walk", BlockKind.Value.WALK))
	program.add_block(ProgramBlockScript.new("turn", BlockKind.Value.TURN))
	program.add_connection(ProgramConnectionScript.new("walk", "next", "turn"))
	program.add_connection(ProgramConnectionScript.new("turn", "next", "walk"))

	assert_has_error(
		ProgramValidatorScript.validate(program),
		ProgramValidationErrorScript.Code.ARBITRARY_CYCLE
	)

func test_rejects_programs_above_five_ram() -> void:
	var program := ProgramDefinitionScript.new()
	program.start_block_id = "block_0"
	for index in range(6):
		var block_id := "block_%d" % index
		program.add_block(ProgramBlockScript.new(block_id, BlockKind.Value.WALK))
		if index > 0:
			program.add_connection(
				ProgramConnectionScript.new("block_%d" % (index - 1), "next", block_id)
			)

	assert_eq(ProgramRamCalculatorScript.used_ram(program), 6)
	assert_has_error(
		ProgramValidatorScript.validate(program),
		ProgramValidationErrorScript.Code.RAM_LIMIT_EXCEEDED
	)

func assert_has_error(errors: Array, expected_code: int) -> void:
	for error in errors:
		if error.code == expected_code:
			pass_test("Expected validation error was found.")
			return

	fail_test("Expected validation error was not found.")
