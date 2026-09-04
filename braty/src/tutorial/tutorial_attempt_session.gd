class_name TutorialAttemptSession
extends RefCounted

const BlockKind = preload("res://src/programming/domain/block_kind.gd")
const BunekoActionDispatcherScript = preload("res://src/buneko/runtime/buneko_action_dispatcher.gd")
const BunekoSensorReaderScript = preload("res://src/buneko/runtime/buneko_sensor_reader.gd")
const ProgramRuntimeScript = preload("res://src/programming/runtime/program_runtime.gd")
const RuntimeFailureReasonScript = preload("res://src/programming/runtime/runtime_failure_reason.gd")
const WorldSensorScript = preload("res://src/tutorial/tutorial_world_sensor.gd")

enum TickResult {
	NONE,
	EXECUTION_LIMIT,
	PROGRAM_FINISHED,
}

signal action_pulse_requested(action_kind: int, refused: bool)

var runtime
var world_sensor
var buneko
var program
var _last_visual_action_kind := -1
var _waiting_for_jump_landing := false
var _jump_has_left_ground := false

func start(session_program, session_buneko, level) -> bool:
	if session_program == null or session_buneko == null or level == null:
		return false

	program = session_program
	buneko = session_buneko
	world_sensor = WorldSensorScript.new()
	world_sensor.gap_start_x = level.gap_start_x
	world_sensor.gap_end_x = level.gap_end_x
	world_sensor.goal_position = level.goal_position
	var sensor_reader = BunekoSensorReaderScript.new(world_sensor)
	var dispatcher = BunekoActionDispatcherScript.new(buneko)
	runtime = ProgramRuntimeScript.new(sensor_reader, dispatcher)
	return runtime.prepare(program) and runtime.start()

func tick() -> int:
	if runtime == null or buneko == null:
		return TickResult.NONE

	world_sensor.update_from_buneko(buneko)
	if _is_waiting_for_landing():
		return TickResult.NONE

	var previous_block_id: String = runtime.last_executed_block_id
	var previous_refused_block_id: String = runtime.last_refused_action_block_id
	runtime.tick()
	_track_accepted_jump(previous_block_id)
	_present_action_pulse(previous_block_id, previous_refused_block_id)
	if runtime.failure_reason == RuntimeFailureReasonScript.Value.EXECUTION_LIMIT:
		return TickResult.EXECUTION_LIMIT
	if runtime.has_finished_execution() and buneko.is_motion_settled():
		return TickResult.PROGRAM_FINISHED
	return TickResult.NONE

func pause() -> bool:
	if runtime == null or not runtime.pause():
		return false
	_stop_motion()
	return true

func resume() -> bool:
	return runtime != null and runtime.resume()

func stop() -> bool:
	if runtime == null or not runtime.stop():
		return false
	_stop_motion()
	return true

func fail_externally() -> bool:
	return runtime != null and runtime.fail_externally()

func complete() -> bool:
	return runtime != null and runtime.complete()

func is_waiting_for_jump_landing() -> bool:
	return _waiting_for_jump_landing

func false_while_with_empty_next_block_id() -> String:
	if runtime == null or program == null:
		return ""
	if not runtime.has_last_condition_result or runtime.last_condition_result:
		return ""

	var block_id: String = runtime.last_executed_block_id
	if block_id.is_empty() or not program.blocks.has(block_id):
		return ""
	if program.blocks[block_id].kind != BlockKind.Value.WHILE:
		return ""

	for connection in program.connections:
		if connection.from_block_id == block_id and connection.from_port == "next":
			return ""
	return block_id

func _present_action_pulse(previous_block_id: String, previous_refused_block_id: String) -> void:
	if not runtime.last_refused_action_block_id.is_empty() and runtime.last_refused_action_block_id != previous_refused_block_id:
		action_pulse_requested.emit(runtime.last_refused_action_kind, true)
		return
	if runtime.last_executed_block_id == previous_block_id:
		return
	if program == null or not program.blocks.has(runtime.last_executed_block_id):
		return
	var action_kind: int = program.blocks[runtime.last_executed_block_id].kind
	if BlockKind.requires_condition(action_kind) or action_kind == _last_visual_action_kind:
		return
	_last_visual_action_kind = action_kind
	action_pulse_requested.emit(action_kind, false)

func _is_waiting_for_landing() -> bool:
	if not _waiting_for_jump_landing:
		return false
	if not buneko.is_on_floor():
		_jump_has_left_ground = true
		return true
	if not _jump_has_left_ground:
		return true
	_waiting_for_jump_landing = false
	_jump_has_left_ground = false
	return false

func _track_accepted_jump(previous_block_id: String) -> void:
	if runtime.last_executed_block_id == previous_block_id:
		return
	if program == null or not program.blocks.has(runtime.last_executed_block_id):
		return
	if program.blocks[runtime.last_executed_block_id].kind != BlockKind.Value.JUMP:
		return
	if runtime.last_refused_action_block_id == runtime.last_executed_block_id:
		return
	_waiting_for_jump_landing = true
	_jump_has_left_ground = false

func _stop_motion() -> void:
	if buneko != null and buneko.controller != null:
		buneko.controller.stop_horizontal()
