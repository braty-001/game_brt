extends GutTest

const BlockKind = preload("res://src/programming/domain/block_kind.gd")
const MissionStateScript = preload("res://src/tutorial/mission_state.gd")
const RuntimeStateScript = preload("res://src/programming/runtime/runtime_state.gd")
const TutorialReferenceProgramScript = preload("res://src/tutorial/tutorial_reference_program.gd")

func test_tutorial_mission_scene_starts_at_assembly() -> void:
	var mission = await _ready_mission()

	assert_eq(mission.evaluator.state, MissionStateScript.Value.ASSEMBLY)
	assert_not_null(mission.assembly_bench)
	assert_true(mission.feedback_label.text.contains("tres pecas"))
	assert_true(mission.hint_label.text.contains("pecas base"))
	assert_eq(mission.mission_header.step_label.text, "ETAPA 1/3  MONTAGEM")

func test_complete_assembly_enters_editor() -> void:
	var mission = await _ready_mission()

	mission.install_base_assembly()
	assert_true(mission.enter_editor())

	assert_eq(mission.evaluator.state, MissionStateScript.Value.EDITING)
	assert_not_null(mission.brain_editor)
	assert_eq(mission.current_assembly.is_complete(), true)

func test_confirm_button_advances_from_assembly_to_editor() -> void:
	var mission = await _ready_mission()

	mission.assembly_bench.install_all_base_parts()
	assert_true(mission.assembly_bench.confirm())
	await get_tree().process_frame

	assert_eq(mission.evaluator.state, MissionStateScript.Value.EDITING)
	assert_not_null(mission.brain_editor)

func test_start_attempt_requires_editor_and_shows_level() -> void:
	var mission = await _ready_mission()
	assert_false(mission.start_attempt())
	mission.install_base_assembly()
	mission.enter_editor()
	mission.brain_editor.create_block(BlockKind.Value.WALK)

	assert_true(mission.start_attempt())

	assert_eq(mission.evaluator.state, MissionStateScript.Value.RUNNING)
	assert_not_null(mission.level)
	assert_not_null(mission.buneko)
	assert_eq(mission.active_runtime.state, RuntimeStateScript.Value.RUNNING)
	assert_eq(mission.active_runtime.action_dispatcher.motor, mission.buneko)
	assert_not_null(mission.world_sensor)
	assert_not_null(mission.runtime_overlay)

func test_editor_execute_button_starts_real_mission_attempt() -> void:
	var mission = await _ready_mission()
	mission.install_base_assembly()
	mission.enter_editor()
	mission.brain_editor.create_block(BlockKind.Value.WALK)

	mission.brain_editor.start_button.pressed.emit()
	await get_tree().process_frame

	assert_eq(mission.evaluator.state, MissionStateScript.Value.RUNNING)
	assert_not_null(mission.buneko)
	assert_eq(mission.active_runtime.action_dispatcher.motor, mission.buneko)

func test_mission_header_tracks_editor_ram() -> void:
	var mission = await _ready_mission()
	mission.install_base_assembly()
	mission.enter_editor()

	mission.brain_editor.create_block(BlockKind.Value.WALK)

	assert_eq(mission.mission_header.ram_label.text, "1/5 RAM")

func test_return_to_assembly_preserves_graph_and_completed_parts() -> void:
	var mission = await _ready_mission()
	mission.install_base_assembly()
	mission.enter_editor()
	mission.brain_editor.create_block(BlockKind.Value.WALK)

	assert_true(mission.return_to_assembly())

	assert_eq(mission.evaluator.state, MissionStateScript.Value.ASSEMBLY)
	assert_true(mission.assembly_bench.assembly.is_complete())
	assert_eq(mission.current_graph_state.blocks.size(), 1)

func test_fall_returns_to_editor_preserving_program_and_assembly() -> void:
	var mission = await _ready_mission()
	mission.install_base_assembly()
	mission.enter_editor()
	mission.brain_editor.create_block(BlockKind.Value.WALK)
	mission.start_attempt()
	var assembly = mission.current_assembly
	var program = mission.current_program

	assert_true(mission.fail_by_fall())

	assert_eq(mission.evaluator.state, MissionStateScript.Value.FAILED)
	assert_not_null(mission.brain_editor)
	assert_eq(mission.current_assembly, assembly)
	assert_eq(mission.current_program, program)
	assert_eq(mission.brain_editor.graph_state.blocks.size(), 1)
	assert_eq(mission.brain_editor.block_nodes.size(), 1)
	assert_true(mission.feedback_label.text.contains("caiu"))
	assert_true(mission.hint_label.text.contains("sensor visual"))

func test_goal_completion_sets_completed_state() -> void:
	var mission = await _ready_mission()
	mission.install_base_assembly()
	mission.enter_editor()
	mission.brain_editor.create_block(BlockKind.Value.WALK)
	mission.start_attempt()

	assert_true(mission.complete_goal())

	assert_eq(mission.evaluator.state, MissionStateScript.Value.COMPLETED)
	assert_true(mission.feedback_label.text.contains("Objetivo concluido"))
	assert_eq(mission.active_runtime.state, RuntimeStateScript.Value.COMPLETED)
	assert_eq(mission.mission_header.status_label.text, "Concluido")

func test_reference_examples_complete_ten_attempts_each() -> void:
	for example in [
		TutorialReferenceProgramScript.Example.IF_GAP,
		TutorialReferenceProgramScript.Example.WHILE_PATH_CLEAR,
	]:
		for attempt in range(10):
			var mission = await _ready_mission()
			mission.install_base_assembly()
			assert_true(mission.enter_editor())
			mission.brain_editor.load_tutorial_example(example)
			assert_true(mission.start_attempt())

			await _run_attempt_until_terminal(mission)

			assert_eq(
				mission.evaluator.state,
				MissionStateScript.Value.COMPLETED,
				"Example %d attempt %d should complete. result=%d pos=%s last=%s failure=%d feedback=%s" % [
					example,
					attempt + 1,
					mission.evaluator.result.kind,
					str(mission.buneko.global_position) if mission.buneko != null else "none",
					mission.active_runtime.last_executed_block_id if mission.active_runtime != null else "none",
					mission.active_runtime.failure_reason if mission.active_runtime != null else -1,
					mission.feedback_label.text,
				]
			)
			mission.free()
			await get_tree().process_frame

func _ready_mission():
	var scene: PackedScene = load("res://scenes/tutorial/tutorial_mission.tscn")
	var mission = scene.instantiate()
	add_child_autofree(mission)
	await get_tree().process_frame
	return mission

func _run_attempt_until_terminal(mission) -> void:
	for frame in range(900):
		if mission.evaluator.state != MissionStateScript.Value.RUNNING:
			return
		await get_tree().physics_frame

	fail_test("Attempt did not finish within the frame budget.")
