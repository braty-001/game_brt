extends GutTest

const RuntimeFailureReasonScript = preload("res://src/programming/runtime/runtime_failure_reason.gd")
const RuntimeStatePresenterScript = preload("res://src/brain_editor/runtime_state_presenter.gd")
const RuntimeStateScript = preload("res://src/programming/runtime/runtime_state.gd")

func test_labels_runtime_states() -> void:
	var presenter = RuntimeStatePresenterScript.new()

	assert_eq(presenter.label_for_state(RuntimeStateScript.Value.EDITING), "Editando")
	assert_eq(presenter.label_for_state(RuntimeStateScript.Value.READY), "Pronto")
	assert_eq(presenter.label_for_state(RuntimeStateScript.Value.RUNNING), "Executando")
	assert_eq(
		presenter.label_for_state(
			RuntimeStateScript.Value.FAILED,
			RuntimeFailureReasonScript.Value.EXECUTION_LIMIT
		),
		"Falhou: execucao excessiva"
	)

func test_controls_follow_runtime_transitions() -> void:
	var presenter = RuntimeStatePresenterScript.new()

	var running_controls: Dictionary = presenter.controls_for_state(RuntimeStateScript.Value.RUNNING, true)
	assert_false(running_controls["can_edit"])
	assert_false(running_controls["can_start"])
	assert_true(running_controls["can_pause"])
	assert_true(running_controls["can_stop"])

	var paused_controls: Dictionary = presenter.controls_for_state(RuntimeStateScript.Value.PAUSED, true)
	assert_false(paused_controls["can_edit"])
	assert_true(paused_controls["can_resume"])
	assert_true(paused_controls["can_stop"])

func test_start_requires_ready_state_and_valid_program() -> void:
	var presenter = RuntimeStatePresenterScript.new()

	var ready_valid: Dictionary = presenter.controls_for_state(RuntimeStateScript.Value.READY, true)
	var ready_invalid: Dictionary = presenter.controls_for_state(RuntimeStateScript.Value.READY, false)
	var editing_valid: Dictionary = presenter.controls_for_state(RuntimeStateScript.Value.EDITING, true)

	assert_true(ready_valid["can_start"])
	assert_false(ready_invalid["can_start"])
	assert_true(editing_valid["can_start"])
