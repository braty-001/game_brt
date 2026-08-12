extends GutTest

const EvaluatorScript = preload("res://src/tutorial/tutorial_objective_evaluator.gd")
const MissionResultScript = preload("res://src/tutorial/mission_result.gd")
const MissionStateScript = preload("res://src/tutorial/mission_state.gd")

func test_goal_completion_requires_running_state() -> void:
	var evaluator = EvaluatorScript.new()

	assert_false(evaluator.complete_goal())
	evaluator.enter_editing("assembly", "program")
	assert_true(evaluator.start_attempt())
	assert_true(evaluator.complete_goal())

	assert_eq(evaluator.state, MissionStateScript.Value.COMPLETED)
	assert_true(evaluator.result.is_completed())

func test_fall_failure_preserves_assembly_and_program() -> void:
	var evaluator = EvaluatorScript.new()
	evaluator.enter_editing("assembly", "program")
	evaluator.start_attempt()

	assert_true(evaluator.fail_by_fall())

	assert_eq(evaluator.state, MissionStateScript.Value.FAILED)
	assert_true(evaluator.result.is_failure())
	assert_eq(evaluator.result.kind, MissionResultScript.Kind.FAILED_BY_FALL)
	assert_eq(evaluator.assembly, "assembly")
	assert_eq(evaluator.program, "program")

func test_return_to_editing_after_failure_preserves_data() -> void:
	var evaluator = EvaluatorScript.new()
	evaluator.enter_editing("assembly", "program")
	evaluator.start_attempt()
	evaluator.fail_by_execution_limit()

	assert_true(evaluator.return_to_editing())

	assert_eq(evaluator.state, MissionStateScript.Value.EDITING)
	assert_eq(evaluator.assembly, "assembly")
	assert_eq(evaluator.program, "program")

func test_events_out_of_order_are_rejected() -> void:
	var evaluator = EvaluatorScript.new()

	assert_false(evaluator.start_attempt())
	assert_false(evaluator.fail_by_fall())
	assert_false(evaluator.return_to_editing())
