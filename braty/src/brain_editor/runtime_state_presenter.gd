class_name RuntimeStatePresenter
extends RefCounted

func label_for_state(state: int, failure_reason: int = RuntimeFailureReason.Value.NONE) -> String:
	match state:
		RuntimeState.Value.EDITING:
			return "Editando"
		RuntimeState.Value.READY:
			return "Pronto"
		RuntimeState.Value.RUNNING:
			return "Executando"
		RuntimeState.Value.PAUSED:
			return "Pausado"
		RuntimeState.Value.STOPPED:
			return "Parado"
		RuntimeState.Value.FAILED:
			return _failure_label(failure_reason)
		RuntimeState.Value.COMPLETED:
			return "Concluido"
		_:
			return "Estado desconhecido"

func controls_for_state(state: int, program_is_valid: bool) -> Dictionary:
	return {
		"can_edit": can_edit(state),
		"can_start": can_edit(state) and program_is_valid,
		"can_pause": state == RuntimeState.Value.RUNNING,
		"can_resume": state == RuntimeState.Value.PAUSED,
		"can_stop": state == RuntimeState.Value.READY or state == RuntimeState.Value.RUNNING or state == RuntimeState.Value.PAUSED,
		"can_restart": state == RuntimeState.Value.STOPPED or state == RuntimeState.Value.FAILED or state == RuntimeState.Value.COMPLETED,
	}

func can_edit(state: int) -> bool:
	return (
		state == RuntimeState.Value.EDITING
		or state == RuntimeState.Value.READY
		or state == RuntimeState.Value.STOPPED
		or state == RuntimeState.Value.FAILED
		or state == RuntimeState.Value.COMPLETED
	)

func _failure_label(failure_reason: int) -> String:
	match failure_reason:
		RuntimeFailureReason.Value.INVALID_PROGRAM:
			return "Falhou: programa invalido"
		RuntimeFailureReason.Value.EXECUTION_LIMIT:
			return "Falhou: execucao excessiva"
		RuntimeFailureReason.Value.EXTERNAL_FAILURE:
			return "Falhou"
		_:
			return "Falhou"
