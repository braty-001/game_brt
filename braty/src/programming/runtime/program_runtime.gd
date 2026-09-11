class_name ProgramRuntime
extends RefCounted

const DEFAULT_INSTRUCTION_LIMIT := 32

var sensor_reader: SensorReader
var action_dispatcher: ActionDispatcher
var state: int = RuntimeState.Value.EDITING
var failure_reason: int = RuntimeFailureReason.Value.NONE
var validation_errors: Array[ProgramValidationError] = []
var current_block_id: String
var last_executed_block_id: String
var last_refused_action_block_id: String
var last_refused_action_kind := -1
var has_last_condition_result := false
var last_condition_result := false
var instruction_limit: int = DEFAULT_INSTRUCTION_LIMIT
var ram_capacity: int = ProgramRamCalculator.RAM_LIMIT

var _program: ProgramDefinition
var _frames: Array[RuntimeFrame] = []
var _instructions_without_progress := 0

func _init(
	runtime_sensor_reader: SensorReader,
	runtime_action_dispatcher: ActionDispatcher,
	runtime_ram_capacity: int = ProgramRamCalculator.RAM_LIMIT
) -> void:
	sensor_reader = runtime_sensor_reader
	action_dispatcher = runtime_action_dispatcher
	ram_capacity = runtime_ram_capacity

func prepare(program: ProgramDefinition) -> bool:
	_program = program
	validation_errors = ProgramValidator.validate(program, ram_capacity)
	if not validation_errors.is_empty():
		state = RuntimeState.Value.EDITING
		failure_reason = RuntimeFailureReason.Value.INVALID_PROGRAM
		return false

	_reset_execution()
	state = RuntimeState.Value.READY
	failure_reason = RuntimeFailureReason.Value.NONE
	return true

func start() -> bool:
	if state != RuntimeState.Value.READY:
		return false

	state = RuntimeState.Value.RUNNING
	return true

func pause() -> bool:
	if state != RuntimeState.Value.RUNNING:
		return false

	state = RuntimeState.Value.PAUSED
	return true

func resume() -> bool:
	if state != RuntimeState.Value.PAUSED:
		return false

	state = RuntimeState.Value.RUNNING
	return true

func stop() -> bool:
	if state != RuntimeState.Value.READY and state != RuntimeState.Value.RUNNING and state != RuntimeState.Value.PAUSED:
		return false

	state = RuntimeState.Value.STOPPED
	return true

func restart() -> bool:
	if _program == null or not prepare(_program):
		return false

	return start()

func fail_externally() -> bool:
	if state != RuntimeState.Value.RUNNING and state != RuntimeState.Value.PAUSED:
		return false

	_fail(RuntimeFailureReason.Value.EXTERNAL_FAILURE)
	return true

func complete() -> bool:
	if state != RuntimeState.Value.RUNNING and state != RuntimeState.Value.PAUSED:
		return false

	state = RuntimeState.Value.COMPLETED
	return true

func has_finished_execution() -> bool:
	return state == RuntimeState.Value.RUNNING and current_block_id.is_empty()

func tick() -> void:
	if state != RuntimeState.Value.RUNNING:
		return

	var instructions_this_tick := 0
	while state == RuntimeState.Value.RUNNING:
		if instructions_this_tick >= instruction_limit or _instructions_without_progress >= instruction_limit:
			_fail(RuntimeFailureReason.Value.EXECUTION_LIMIT)
			return

		if current_block_id.is_empty():
			return

		var block: ProgramBlock = _program.blocks[current_block_id]
		last_executed_block_id = block.id
		instructions_this_tick += 1
		_instructions_without_progress += 1

		if ProgramBlockKind.requires_condition(block.kind):
			_execute_control_block(block)
			continue

		if _execute_action_block(block):
			return

func _execute_control_block(block: ProgramBlock) -> void:
	var condition_is_true := sensor_reader.evaluate(block.condition)
	has_last_condition_result = true
	last_condition_result = condition_is_true
	if block.kind == ProgramBlockKind.Value.IF:
		if condition_is_true:
			_move_to_output(block.id, "true")
		else:
			_move_to_output(block.id, "false")
		return

	if condition_is_true:
		var body_target := _output_target(block.id, "body")
		if body_target.is_empty():
			current_block_id = block.id
			return

		_frames.append(RuntimeFrame.new(RuntimeFrame.Kind.REPEAT_WHILE, block.id))
		current_block_id = body_target
	else:
		_move_to_output(block.id, "next")

func _execute_action_block(block: ProgramBlock) -> bool:
	has_last_condition_result = false
	var result := action_dispatcher.dispatch(block)
	_move_to_output(block.id, "next")
	if result == ActionDispatchResult.Value.YIELDED:
		last_refused_action_block_id = ""
		last_refused_action_kind = -1
		_instructions_without_progress = 0
		return true

	last_refused_action_block_id = block.id
	last_refused_action_kind = block.kind
	return true

func _move_to_output(block_id: String, port: String) -> void:
	var target := _output_target(block_id, port)
	if target.is_empty():
		_resume_after_terminal()
	else:
		current_block_id = target

func _output_target(block_id: String, port: String) -> String:
	for connection in _program.connections:
		if connection.from_block_id == block_id and connection.from_port == port:
			return connection.to_block_id

	return ""

func _resume_after_terminal() -> void:
	if _frames.is_empty():
		current_block_id = ""
		return

	var frame: RuntimeFrame = _frames.pop_back()
	if frame.kind == RuntimeFrame.Kind.REPEAT_WHILE:
		current_block_id = frame.block_id

func _reset_execution() -> void:
	current_block_id = _program.start_block_id
	last_executed_block_id = ""
	last_refused_action_block_id = ""
	last_refused_action_kind = -1
	has_last_condition_result = false
	last_condition_result = false
	_frames.clear()
	_instructions_without_progress = 0

func _fail(reason: int) -> void:
	state = RuntimeState.Value.FAILED
	failure_reason = reason
