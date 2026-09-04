class_name TutorialMissionFlow
extends RefCounted

const EvaluatorScript = preload("res://src/tutorial/tutorial_objective_evaluator.gd")

var evaluator

func _init(flow_evaluator = null) -> void:
	evaluator = flow_evaluator if flow_evaluator != null else EvaluatorScript.new()

func enter_assembly(current_assembly = null, current_program = null) -> void:
	evaluator.enter_assembly(current_assembly, current_program)

func enter_editing(current_assembly, current_program) -> bool:
	if current_assembly == null:
		return false
	evaluator.enter_editing(current_assembly, current_program)
	return true

func start_attempt(current_program) -> bool:
	return evaluator.start_attempt(current_program)

func fail_by_fall() -> bool:
	return evaluator.fail_by_fall()

func fail_by_execution_limit() -> bool:
	return evaluator.fail_by_execution_limit()

func fail_by_program_end() -> bool:
	return evaluator.fail_by_program_end()

func complete_goal() -> bool:
	return evaluator.complete_goal()
