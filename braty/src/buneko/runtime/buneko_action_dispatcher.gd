class_name BunekoActionDispatcher
extends ActionDispatcher

var motor

func _init(dispatcher_motor = null) -> void:
	motor = dispatcher_motor

func dispatch(action_kind: int) -> int:
	if motor == null:
		return ActionDispatchResult.Value.NO_PROGRESS

	match action_kind:
		ProgramBlockKind.Value.WALK:
			return _dispatch_motor_call("walk")
		ProgramBlockKind.Value.RUN:
			return _dispatch_motor_call("run")
		ProgramBlockKind.Value.JUMP:
			motor.jump()
			return ActionDispatchResult.Value.YIELDED
		ProgramBlockKind.Value.TURN:
			return _dispatch_motor_call("turn")
		_:
			return ActionDispatchResult.Value.NO_PROGRESS

func _dispatch_motor_call(method_name: String) -> int:
	if not motor.has_method(method_name):
		return ActionDispatchResult.Value.NO_PROGRESS

	if motor.call(method_name):
		return ActionDispatchResult.Value.YIELDED

	return ActionDispatchResult.Value.NO_PROGRESS
