extends GutTest

const ActionDispatchResultScript = preload("res://src/programming/runtime/action_dispatch_result.gd")
const BlockKind = preload("res://src/programming/domain/block_kind.gd")
const DispatcherScript = preload("res://src/buneko/runtime/buneko_action_dispatcher.gd")
const MotorScript = preload("res://src/buneko/runtime/buneko_motor.gd")

class FakeMotor:
	var calls: Array[String] = []
	var jump_allowed := true
	var direction := 1

	func walk() -> bool:
		calls.append("walk")
		return true

	func run() -> bool:
		calls.append("run")
		return true

	func jump() -> bool:
		calls.append("jump")
		return jump_allowed

	func turn() -> bool:
		calls.append("turn")
		direction *= -1
		return true

func test_dispatches_action_blocks_to_motor() -> void:
	var motor := FakeMotor.new()
	var dispatcher = DispatcherScript.new(motor)

	assert_eq(dispatcher.dispatch(BlockKind.Value.WALK), ActionDispatchResultScript.Value.YIELDED)
	assert_eq(dispatcher.dispatch(BlockKind.Value.RUN), ActionDispatchResultScript.Value.YIELDED)
	assert_eq(dispatcher.dispatch(BlockKind.Value.JUMP), ActionDispatchResultScript.Value.YIELDED)
	assert_eq(dispatcher.dispatch(BlockKind.Value.TURN), ActionDispatchResultScript.Value.YIELDED)
	assert_eq(motor.calls, ["walk", "run", "jump", "turn"])

func test_jump_without_ground_reports_no_progress() -> void:
	var motor := FakeMotor.new()
	motor.jump_allowed = false
	var dispatcher = DispatcherScript.new(motor)

	assert_eq(dispatcher.dispatch(BlockKind.Value.JUMP), ActionDispatchResultScript.Value.NO_PROGRESS)
	assert_eq(motor.calls, ["jump"])

func test_turn_updates_motor_direction() -> void:
	var motor = MotorScript.new()
	var dispatcher = DispatcherScript.new(motor)

	dispatcher.dispatch(BlockKind.Value.TURN)

	assert_eq(motor.direction, MotorScript.Direction.LEFT)

func test_unknown_action_or_missing_motor_has_no_progress() -> void:
	var dispatcher_without_motor = DispatcherScript.new()
	var dispatcher = DispatcherScript.new(FakeMotor.new())

	assert_eq(dispatcher_without_motor.dispatch(BlockKind.Value.WALK), ActionDispatchResultScript.Value.NO_PROGRESS)
	assert_eq(dispatcher.dispatch(BlockKind.Value.IF), ActionDispatchResultScript.Value.NO_PROGRESS)
