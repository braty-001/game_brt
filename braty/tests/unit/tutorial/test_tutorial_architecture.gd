extends GutTest

const BlockKind = preload("res://src/programming/domain/block_kind.gd")
const ConditionCatalogScript = preload("res://src/programming/domain/condition_catalog.gd")
const MissionFlowScript = preload("res://src/tutorial/tutorial_mission_flow.gd")
const MissionStateScript = preload("res://src/tutorial/mission_state.gd")
const ProgramBlockScript = preload("res://src/programming/domain/program_block.gd")
const ProgramConditionScript = preload("res://src/programming/domain/program_condition.gd")
const ProgramDefinitionScript = preload("res://src/programming/domain/program_definition.gd")
const RuntimeStateScript = preload("res://src/programming/runtime/runtime_state.gd")
const AttemptSessionScript = preload("res://src/tutorial/tutorial_attempt_session.gd")

func test_flow_owns_valid_mission_transitions() -> void:
	var flow = MissionFlowScript.new()

	assert_false(flow.enter_editing(null, null))
	assert_eq(flow.evaluator.state, MissionStateScript.Value.ASSEMBLY)
	assert_true(flow.enter_editing("assembly", "program"))
	assert_true(flow.start_attempt("program"))
	assert_true(flow.fail_by_program_end())
	flow.enter_assembly("assembly", "program")

	assert_eq(flow.evaluator.state, MissionStateScript.Value.ASSEMBLY)
	assert_eq(flow.evaluator.assembly, "assembly")
	assert_eq(flow.evaluator.program, "program")

func test_attempt_session_owns_runtime_adapters_and_controls() -> void:
	var context: Dictionary = await _ready_attempt_context()
	var session = AttemptSessionScript.new()
	var program = ProgramDefinitionScript.new()
	program.start_block_id = "walk"
	program.add_block(ProgramBlockScript.new("walk", BlockKind.Value.WALK))

	assert_true(session.start(program, context["buneko"], context["level"]))
	assert_eq(session.runtime.state, RuntimeStateScript.Value.RUNNING)
	assert_eq(session.runtime.action_dispatcher.motor, context["buneko"])
	assert_not_null(session.world_sensor)
	assert_true(session.pause())
	assert_eq(session.runtime.state, RuntimeStateScript.Value.PAUSED)
	assert_true(session.resume())
	assert_true(session.stop())
	assert_eq(session.runtime.state, RuntimeStateScript.Value.STOPPED)

func test_attempt_session_diagnoses_false_while_without_next() -> void:
	var context: Dictionary = await _ready_attempt_context()
	var session = AttemptSessionScript.new()
	var program = ProgramDefinitionScript.new()
	var condition = ProgramConditionScript.new(
		ConditionCatalogScript.Modality.VISION,
		ConditionCatalogScript.Query.GAP_AHEAD
	)
	program.start_block_id = "while"
	program.add_block(ProgramBlockScript.new("while", BlockKind.Value.WHILE, condition))
	context["buneko"].controller.grounded = true
	context["buneko"].controller.velocity = Vector2.ZERO

	assert_true(session.start(program, context["buneko"], context["level"]))
	assert_eq(session.tick(), AttemptSessionScript.TickResult.PROGRAM_FINISHED)
	assert_eq(session.false_while_with_empty_next_block_id(), "while")

func _ready_attempt_context() -> Dictionary:
	var level_scene: PackedScene = load("res://scenes/tutorial/tutorial_level.tscn")
	var buneko_scene: PackedScene = load("res://scenes/buneko/buneko.tscn")
	var level = level_scene.instantiate()
	add_child_autofree(level)
	var buneko = buneko_scene.instantiate()
	buneko.position = level.spawn_position
	level.add_child(buneko)
	await get_tree().process_frame
	return {"level": level, "buneko": buneko}
