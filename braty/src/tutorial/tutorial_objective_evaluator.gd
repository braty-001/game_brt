class_name TutorialObjectiveEvaluator
extends RefCounted

const MissionResultScript = preload("res://src/tutorial/mission_result.gd")
const MissionStateScript = preload("res://src/tutorial/mission_state.gd")

var state: int = MissionStateScript.Value.ASSEMBLY
var result = MissionResultScript.new()
var assembly
var program

func enter_editing(current_assembly = null, current_program = null) -> void:
	state = MissionStateScript.Value.EDITING
	result = MissionResultScript.new()
	if current_assembly != null:
		assembly = current_assembly
	if current_program != null:
		program = current_program

func start_attempt(current_program = null) -> bool:
	if state != MissionStateScript.Value.EDITING and state != MissionStateScript.Value.FAILED:
		return false

	if current_program != null:
		program = current_program
	state = MissionStateScript.Value.RUNNING
	result = MissionResultScript.new()
	return true

func complete_goal() -> bool:
	if state != MissionStateScript.Value.RUNNING:
		return false

	state = MissionStateScript.Value.COMPLETED
	result = MissionResultScript.new(MissionResultScript.Kind.COMPLETED, "Objetivo concluido")
	return true

func fail_by_fall() -> bool:
	if state != MissionStateScript.Value.RUNNING:
		return false

	state = MissionStateScript.Value.FAILED
	result = MissionResultScript.new(MissionResultScript.Kind.FAILED_BY_FALL, "Voce falhou: queda")
	return true

func fail_by_execution_limit() -> bool:
	if state != MissionStateScript.Value.RUNNING:
		return false

	state = MissionStateScript.Value.FAILED
	result = MissionResultScript.new(
		MissionResultScript.Kind.FAILED_BY_EXECUTION_LIMIT,
		"Voce falhou: execucao excessiva"
	)
	return true

func fail_by_program_end() -> bool:
	if state != MissionStateScript.Value.RUNNING:
		return false

	state = MissionStateScript.Value.FAILED
	result = MissionResultScript.new(
		MissionResultScript.Kind.FAILED_BEFORE_OBJECTIVE,
		"O programa terminou antes do objetivo"
	)
	return true

func return_to_editing() -> bool:
	if state != MissionStateScript.Value.FAILED:
		return false

	state = MissionStateScript.Value.EDITING
	return true
