extends GutTest

const ActionDispatchResultScript = preload("res://src/programming/runtime/action_dispatch_result.gd")
const ActionDispatcherScript = preload("res://src/programming/runtime/action_dispatcher.gd")
const BlockKind = preload("res://src/programming/domain/block_kind.gd")
const ConditionCatalogScript = preload("res://src/programming/domain/condition_catalog.gd")
const ProgramBlockScript = preload("res://src/programming/domain/program_block.gd")
const ProgramConditionScript = preload("res://src/programming/domain/program_condition.gd")
const ProgramConnectionScript = preload("res://src/programming/domain/program_connection.gd")
const ProgramDefinitionScript = preload("res://src/programming/domain/program_definition.gd")
const ProgramRuntimeScript = preload("res://src/programming/runtime/program_runtime.gd")
const RuntimeFailureReasonScript = preload("res://src/programming/runtime/runtime_failure_reason.gd")
const RuntimeStateScript = preload("res://src/programming/runtime/runtime_state.gd")
const SensorReaderScript = preload("res://src/programming/runtime/sensor_reader.gd")

class FakeSensorReader extends SensorReader:
	var values: Dictionary = {}

	func evaluate(condition: ProgramCondition) -> bool:
		return values.get(_condition_key(condition), false)

	func set_value(condition: ProgramCondition, value: bool) -> void:
		values[_condition_key(condition)] = value

	func _condition_key(condition: ProgramCondition) -> String:
		return "%s:%s" % [condition.modality, condition.query]

class FakeActionDispatcher extends ActionDispatcher:
	var action_kinds: Array[int] = []
	var results: Array[int] = []

	func dispatch(block: ProgramBlock) -> int:
		action_kinds.append(block.kind)
		if results.is_empty():
			return ActionDispatchResult.Value.YIELDED

		var result: int = results.pop_front()
		return result

func test_executes_linear_actions_across_ticks() -> void:
	var dispatcher := FakeActionDispatcher.new()
	var runtime := _create_runtime(FakeSensorReader.new(), dispatcher)
	var program := _linear_program([BlockKind.Value.WALK, BlockKind.Value.JUMP])

	assert_true(runtime.prepare(program))
	assert_true(runtime.start())
	runtime.tick()
	runtime.tick()

	assert_eq(dispatcher.action_kinds, [BlockKind.Value.WALK, BlockKind.Value.JUMP])
	assert_eq(runtime.state, RuntimeStateScript.Value.RUNNING)

func test_finished_linear_program_does_not_restart_from_its_first_block() -> void:
	var dispatcher := FakeActionDispatcher.new()
	var runtime := _create_runtime(FakeSensorReader.new(), dispatcher)

	assert_true(runtime.prepare(_linear_program([BlockKind.Value.WALK])))
	assert_true(runtime.start())
	runtime.tick()
	runtime.tick()

	assert_eq(dispatcher.action_kinds, [BlockKind.Value.WALK])
	assert_true(runtime.current_block_id.is_empty())
	assert_true(runtime.has_finished_execution())

func test_runtime_only_reports_finished_while_running_at_the_end_of_graph() -> void:
	var runtime := _create_runtime(FakeSensorReader.new(), FakeActionDispatcher.new())

	assert_false(runtime.has_finished_execution())
	assert_true(runtime.prepare(_linear_program([BlockKind.Value.WALK])))
	assert_false(runtime.has_finished_execution())
	assert_true(runtime.start())
	runtime.tick()
	assert_true(runtime.has_finished_execution())
	assert_true(runtime.stop())
	assert_false(runtime.has_finished_execution())

func test_if_uses_true_and_false_branches() -> void:
	var condition := _gap_condition()
	var sensor_reader := FakeSensorReader.new()
	var dispatcher := FakeActionDispatcher.new()
	var runtime := _create_runtime(sensor_reader, dispatcher)
	var program := ProgramDefinitionScript.new()
	program.start_block_id = "if"
	program.add_block(ProgramBlockScript.new("if", BlockKind.Value.IF, condition))
	program.add_block(ProgramBlockScript.new("jump", BlockKind.Value.JUMP))
	program.add_block(ProgramBlockScript.new("walk", BlockKind.Value.WALK))
	program.add_connection(ProgramConnectionScript.new("if", "true", "jump"))
	program.add_connection(ProgramConnectionScript.new("if", "false", "walk"))

	sensor_reader.set_value(condition, true)
	assert_true(runtime.prepare(program))
	assert_true(runtime.start())
	runtime.tick()
	assert_eq(dispatcher.action_kinds, [BlockKind.Value.JUMP])

	assert_true(runtime.restart())
	sensor_reader.set_value(condition, false)
	runtime.tick()
	assert_eq(dispatcher.action_kinds, [BlockKind.Value.JUMP, BlockKind.Value.WALK])

func test_while_returns_to_its_condition_after_body_ends() -> void:
	var condition := _gap_condition()
	var sensor_reader := FakeSensorReader.new()
	var dispatcher := FakeActionDispatcher.new()
	var runtime := _create_runtime(sensor_reader, dispatcher)
	var program := ProgramDefinitionScript.new()
	program.start_block_id = "while"
	program.add_block(ProgramBlockScript.new("while", BlockKind.Value.WHILE, condition))
	program.add_block(ProgramBlockScript.new("walk", BlockKind.Value.WALK))
	program.add_block(ProgramBlockScript.new("turn", BlockKind.Value.TURN))
	program.add_connection(ProgramConnectionScript.new("while", "body", "walk"))
	program.add_connection(ProgramConnectionScript.new("while", "next", "turn"))

	sensor_reader.set_value(condition, true)
	assert_true(runtime.prepare(program))
	assert_true(runtime.start())
	runtime.tick()
	runtime.tick()

	sensor_reader.set_value(condition, false)
	runtime.tick()
	assert_eq(
		dispatcher.action_kinds,
		[BlockKind.Value.WALK, BlockKind.Value.WALK, BlockKind.Value.TURN]
	)

func test_pause_resume_stop_and_restart_follow_valid_transitions() -> void:
	var runtime := _create_runtime(FakeSensorReader.new(), FakeActionDispatcher.new())
	assert_true(runtime.prepare(_linear_program([BlockKind.Value.WALK])))
	assert_true(runtime.start())
	assert_true(runtime.pause())
	assert_false(runtime.pause())
	assert_true(runtime.resume())
	assert_true(runtime.stop())
	assert_false(runtime.resume())
	assert_true(runtime.restart())
	assert_eq(runtime.state, RuntimeStateScript.Value.RUNNING)

func test_invalid_program_cannot_start() -> void:
	var runtime := _create_runtime(FakeSensorReader.new(), FakeActionDispatcher.new())
	var invalid_program := ProgramDefinitionScript.new()

	assert_false(runtime.prepare(invalid_program))
	assert_false(runtime.start())
	assert_eq(runtime.failure_reason, RuntimeFailureReasonScript.Value.INVALID_PROGRAM)

func test_external_failure_and_completion_preserve_program() -> void:
	var runtime := _create_runtime(FakeSensorReader.new(), FakeActionDispatcher.new())
	var program := _linear_program([BlockKind.Value.WALK])
	assert_true(runtime.prepare(program))
	assert_true(runtime.start())
	assert_true(runtime.fail_externally())
	assert_eq(runtime.state, RuntimeStateScript.Value.FAILED)
	assert_eq(runtime.failure_reason, RuntimeFailureReasonScript.Value.EXTERNAL_FAILURE)
	assert_true(runtime.restart())
	assert_true(runtime.complete())
	assert_eq(runtime.state, RuntimeStateScript.Value.COMPLETED)

func test_empty_while_body_fails_at_instruction_limit() -> void:
	var condition := _gap_condition()
	var sensor_reader := FakeSensorReader.new()
	sensor_reader.set_value(condition, true)
	var runtime := _create_runtime(sensor_reader, FakeActionDispatcher.new())
	runtime.instruction_limit = 3

	var program := ProgramDefinitionScript.new()
	program.start_block_id = "while"
	program.add_block(ProgramBlockScript.new("while", BlockKind.Value.WHILE, condition))

	assert_true(runtime.prepare(program))
	assert_true(runtime.start())
	runtime.tick()
	assert_eq(runtime.state, RuntimeStateScript.Value.FAILED)
	assert_eq(runtime.failure_reason, RuntimeFailureReasonScript.Value.EXECUTION_LIMIT)

func test_refused_action_records_block_and_fails_after_limit() -> void:
	var dispatcher := FakeActionDispatcher.new()
	dispatcher.results = [
		ActionDispatchResultScript.Value.NO_PROGRESS,
		ActionDispatchResultScript.Value.NO_PROGRESS,
	]
	var runtime := _create_runtime(FakeSensorReader.new(), dispatcher)
	runtime.instruction_limit = 2

	var condition := _gap_condition()
	var program := ProgramDefinitionScript.new()
	program.start_block_id = "while"
	program.add_block(ProgramBlockScript.new("while", BlockKind.Value.WHILE, condition))
	program.add_block(ProgramBlockScript.new("jump", BlockKind.Value.JUMP))
	program.add_connection(ProgramConnectionScript.new("while", "body", "jump"))
	var sensor_reader := FakeSensorReader.new()
	sensor_reader.set_value(condition, true)
	runtime.sensor_reader = sensor_reader
	assert_true(runtime.prepare(program))
	assert_true(runtime.start())
	runtime.tick()
	runtime.tick()
	runtime.tick()
	runtime.tick()

	assert_eq(runtime.last_refused_action_block_id, "jump")
	assert_eq(runtime.last_refused_action_kind, BlockKind.Value.JUMP)
	assert_eq(runtime.state, RuntimeStateScript.Value.FAILED)
	assert_eq(runtime.failure_reason, RuntimeFailureReasonScript.Value.EXECUTION_LIMIT)

func _create_runtime(sensor_reader: SensorReader, dispatcher: ActionDispatcher) -> ProgramRuntime:
	return ProgramRuntimeScript.new(sensor_reader, dispatcher)

func _linear_program(block_kinds: Array[int]) -> ProgramDefinition:
	var program := ProgramDefinitionScript.new()
	for index in block_kinds.size():
		var block_id := "block_%s" % index
		program.add_block(ProgramBlockScript.new(block_id, block_kinds[index]))
		if index == 0:
			program.start_block_id = block_id
		else:
			program.add_connection(
				ProgramConnectionScript.new("block_%s" % (index - 1), "next", block_id)
			)
	return program

func _gap_condition() -> ProgramCondition:
	return ProgramConditionScript.new(
		ConditionCatalogScript.Modality.VISION,
		ConditionCatalogScript.Query.GAP_AHEAD
	)
