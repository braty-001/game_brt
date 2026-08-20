extends GutTest

const ActionDispatchResultScript = preload("res://src/programming/runtime/action_dispatch_result.gd")
const ActionDispatcherScript = preload("res://src/programming/runtime/action_dispatcher.gd")
const BlockKindScript = preload("res://src/programming/domain/block_kind.gd")
const ConditionCatalogScript = preload("res://src/programming/domain/condition_catalog.gd")
const ProgramRamCalculatorScript = preload("res://src/programming/domain/program_ram_calculator.gd")
const ProgramRuntimeScript = preload("res://src/programming/runtime/program_runtime.gd")
const ProgramValidatorScript = preload("res://src/programming/domain/program_validator.gd")
const SensorReaderScript = preload("res://src/programming/runtime/sensor_reader.gd")
const TutorialReferenceProgramScript = preload("res://src/tutorial/tutorial_reference_program.gd")

class FakeSensorReader extends SensorReader:
	var gap_ahead := false
	var path_clear_ahead := false

	func evaluate(condition: ProgramCondition) -> bool:
		if condition.modality != ConditionCatalog.Modality.VISION:
			return false
		if condition.query == ConditionCatalog.Query.GAP_AHEAD:
			return gap_ahead
		if condition.query == ConditionCatalog.Query.PATH_CLEAR_AHEAD:
			return path_clear_ahead

		return false

class FakeActionDispatcher extends ActionDispatcher:
	var action_kinds: Array[int] = []

	func dispatch(action_kind: int) -> int:
		action_kinds.append(action_kind)
		return ActionDispatchResult.Value.YIELDED

func test_reference_program_is_valid_and_within_ram_limit() -> void:
	var program := TutorialReferenceProgramScript.build_if_example()

	assert_eq(ProgramValidatorScript.validate(program).size(), 0)
	assert_eq(ProgramRamCalculatorScript.used_ram(program), 5)

	var while_program := TutorialReferenceProgramScript.build_while_example()

	assert_eq(ProgramValidatorScript.validate(while_program).size(), 0)
	assert_eq(ProgramRamCalculatorScript.used_ram(while_program), 5)

func test_if_reference_program_walks_until_gap_then_jumps_and_runs() -> void:
	var sensor_reader := FakeSensorReader.new()
	var dispatcher := FakeActionDispatcher.new()
	var runtime := ProgramRuntimeScript.new(sensor_reader, dispatcher)

	assert_true(runtime.prepare(TutorialReferenceProgramScript.build_if_example()))
	assert_true(runtime.start())
	sensor_reader.path_clear_ahead = true
	runtime.tick()
	sensor_reader.path_clear_ahead = false
	sensor_reader.gap_ahead = true
	runtime.tick()
	runtime.tick()

	assert_eq(dispatcher.action_kinds, [
		BlockKindScript.Value.WALK,
		BlockKindScript.Value.JUMP,
		BlockKindScript.Value.RUN,
	])

func test_while_reference_program_walks_while_clear_then_jumps() -> void:
	var sensor_reader := FakeSensorReader.new()
	var dispatcher := FakeActionDispatcher.new()
	var runtime := ProgramRuntimeScript.new(sensor_reader, dispatcher)

	assert_true(runtime.prepare(TutorialReferenceProgramScript.build_while_example()))
	assert_true(runtime.start())
	sensor_reader.path_clear_ahead = true
	runtime.tick()
	runtime.tick()
	sensor_reader.path_clear_ahead = false
	sensor_reader.gap_ahead = true
	runtime.tick()

	assert_eq(dispatcher.action_kinds, [
		BlockKindScript.Value.WALK,
		BlockKindScript.Value.WALK,
		BlockKindScript.Value.JUMP,
	])
