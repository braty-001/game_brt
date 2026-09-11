extends GutTest

const MissionScene = preload("res://scenes/campaign/laboratory_mission.tscn")
const SessionScript = preload("res://src/campaign/campaign_session.gd")
const Examples = preload("res://src/campaign/laboratory/laboratory_example_provider.gd")
const Importer = preload("res://src/brain_editor/program_graph_importer.gd")
var previous_ticks: int
var previous_time_scale: float

func before_each() -> void:
	previous_ticks = Engine.physics_ticks_per_second
	previous_time_scale = Engine.time_scale
	# Mantem delta fisico de 1/60 e acelera apenas o relogio do teste headless.
	Engine.physics_ticks_per_second = 600
	Engine.time_scale = 10.0

func after_each() -> void:
	Engine.physics_ticks_per_second = previous_ticks
	Engine.time_scale = previous_time_scale

func test_reference_program_fits_exactly_ten_ram() -> void:
	var program = Examples.new().build_program()
	assert_eq(ProgramRamCalculator.used_ram(program), 10)
	assert_true(ProgramValidator.validate(program, 10).is_empty())
	assert_false(ProgramValidator.validate(program, 5).is_empty())

func test_reference_reaches_exit_ten_times_using_real_physics() -> void:
	for run in 10:
		var mission = _mission()
		var climbed_right := false
		var turned_left := false
		for frame in 1800:
			await get_tree().physics_frame
			climbed_right = climbed_right or (mission.buneko.position.x > 1100 and mission.buneko.position.y < 440)
			turned_left = turned_left or (mission.buneko.position.y < 440 and mission.buneko.controller.direction == -1)
			if not mission.outcome.is_empty():
				break
		assert_eq(mission.outcome, "escaped", "run=%s pos=%s block=%s" % [run, mission.buneko.position, mission.attempt.runtime.last_executed_block_id])
		assert_true(climbed_right)
		assert_true(turned_left)
		assert_eq(mission.attempt.runtime.state, RuntimeState.Value.COMPLETED)
		assert_lt(mission.buneko.position.x, 104.0)
		assert_lt(mission.buneko.position.y, 389.0)
		mission.queue_free()
		await get_tree().process_frame

func test_pause_mid_jump_freezes_physics_and_program_then_resumes_to_exit() -> void:
	var mission = _mission()
	for frame in 900:
		await get_tree().physics_frame
		if mission.attempt.is_waiting_for_jump_landing() and not mission.buneko.is_on_floor():
			break
	assert_true(mission.attempt.is_waiting_for_jump_landing())
	assert_false(mission.buneko.is_on_floor())
	mission.toggle_pause()
	var position: Vector2 = mission.buneko.position
	var velocity: Vector2 = mission.buneko.controller.velocity
	var instruction: String = mission.attempt.runtime.current_block_id
	for frame in 30:
		await get_tree().physics_frame
	assert_eq(mission.buneko.position, position)
	assert_eq(mission.buneko.controller.velocity, velocity)
	assert_eq(mission.attempt.runtime.current_block_id, instruction)
	assert_true(mission.paused)
	mission.toggle_pause()
	for frame in 1800:
		await get_tree().physics_frame
		if not mission.outcome.is_empty():
			break
	assert_eq(mission.outcome, "escaped")

func test_invalid_and_over_ram_programs_never_spawn_actor() -> void:
	for program in [ProgramDefinition.new(), _over_ram_program()]:
		var session = SessionScript.new()
		session.complete_tutorial(BaseBunekoParts.complete_assembly(), Importer.new().import_program(program))
		session.preparation_confirmed = true
		var mission = MissionScene.instantiate()
		mission.configure_session(session)
		add_child_autofree(mission)
		assert_eq(mission.outcome, "invalid")
		assert_null(mission.buneko)
		assert_true(mission.pause_button.disabled)

func test_finished_program_and_execution_guard_leave_editor_reachable() -> void:
	for empty_loop in [false, true]:
		var program := ProgramDefinition.new()
		program.start_block_id = "start"
		if empty_loop:
			program.add_block(ProgramBlock.new("start", ProgramBlockKind.Value.WHILE,
				ProgramCondition.new(ConditionCatalog.Modality.VISION, ConditionCatalog.Query.PATH_CLEAR_AHEAD)))
		else:
			program.add_block(ProgramBlock.new("start", ProgramBlockKind.Value.TURN))
		var session = SessionScript.new()
		session.complete_tutorial(BaseBunekoParts.complete_assembly(), Importer.new().import_program(program))
		session.preparation_confirmed = true
		var mission = MissionScene.instantiate()
		mission.configure_session(session)
		add_child_autofree(mission)
		for frame in 60:
			await get_tree().physics_frame
			if not mission.outcome.is_empty():
				break
		assert_eq(mission.outcome, "guard" if empty_loop else "finished")
		watch_signals(mission)
		mission.edit_button.pressed.emit()
		assert_signal_emitted(mission, "editing_requested")

func test_world_scales_uniformly_and_controls_fit_supported_sizes() -> void:
	for target in [Vector2i(960, 540), Vector2i(1440, 810), Vector2i(1600, 900)]:
		var viewport := SubViewport.new()
		viewport.size = target
		add_child_autofree(viewport)
		var mission = MissionScene.instantiate()
		viewport.add_child(mission)
		for frame in 6:
			await get_tree().process_frame
		assert_eq(mission.display.scale.x, mission.display.scale.y)
		var extent: Vector2 = Vector2(mission.world.size) * mission.display.scale
		assert_gt(extent.y, 0.0)
		assert_lte(extent.x, mission.stage.size.x + 0.01)
		assert_lte(extent.y, mission.stage.size.y + 0.01)
		for control in [mission.pause_button, mission.edit_button, mission.status_label]:
			assert_true(Rect2(Vector2.ZERO, Vector2(target)).encloses(control.get_global_rect()))

func _over_ram_program():
	var program = Examples.new().build_program()
	program.add_block(ProgramBlock.new("extra", ProgramBlockKind.Value.TURN))
	program.add_connection(ProgramConnection.new("escape", "next", "extra"))
	return program

func _mission():
	var session = SessionScript.new()
	session.complete_tutorial(BaseBunekoParts.complete_assembly(), Importer.new().import_program(Examples.new().build_program()))
	session.baton_checkpoint_active = true
	session.baton_checkpoint_intro_seen = true
	session.preparation_confirmed = true
	var mission = MissionScene.instantiate()
	mission.configure_session(session)
	add_child_autofree(mission)
	return mission
