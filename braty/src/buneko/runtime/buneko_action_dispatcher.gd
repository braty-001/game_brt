class_name BunekoActionDispatcher
extends ActionDispatcher

const MovementPaceScript = preload("res://src/programming/domain/movement_pace.gd")

var motor

func _init(dispatcher_motor = null) -> void:
	motor = dispatcher_motor

func dispatch(block: ProgramBlock) -> int:
	if motor == null or block == null:
		return ActionDispatchResult.Value.NO_PROGRESS

	match block.kind:
		ProgramBlockKind.Value.WALK:
			return _dispatch_motor_call("walk", [MovementPaceScript.from_parameters(block.parameters)])
		ProgramBlockKind.Value.JUMP:
			return _dispatch_motor_call("jump")
		ProgramBlockKind.Value.TURN:
			return _dispatch_motor_call("turn")
		_:
			return ActionDispatchResult.Value.NO_PROGRESS

func _dispatch_motor_call(method_name: String, arguments: Array = []) -> int:
	if not motor.has_method(method_name):
		return ActionDispatchResult.Value.NO_PROGRESS

	if motor.callv(method_name, arguments):
		return ActionDispatchResult.Value.YIELDED

	return ActionDispatchResult.Value.NO_PROGRESS
