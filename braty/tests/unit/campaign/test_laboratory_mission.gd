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
		assert_true(mission.milestone_overlay.visible)
		assert_true(mission.milestone_description.text.begins_with("Voce escapou do laboratorio.\n+10 moedas"))
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
		assert_false(mission.milestone_overlay.visible)

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
		assert_false(mission.milestone_overlay.visible)
		watch_signals(mission)
		mission.edit_button.pressed.emit()
		assert_signal_emitted(mission, "editing_requested")

func test_exit_notice_persists_without_simulation_or_background_navigation() -> void:
	var mission = _mission()
	mission.buneko.position = mission.level.exit_rect().get_center()
	for frame in 10:
		await get_tree().physics_frame
		if not mission.outcome.is_empty():
			break
	assert_eq(mission.outcome, "escaped")
	watch_signals(mission)
	var position: Vector2 = mission.buneko.position
	var health: int = mission.buneko.current_health()
	var enemy_positions: Array = mission.level.enemies.map(func(enemy): return enemy.position)
	mission.pause_button.pressed.emit()
	mission.edit_button.pressed.emit()
	for frame in 60:
		await get_tree().physics_frame
	assert_true(mission.milestone_overlay.visible)
	assert_true(mission.level.is_simulation_suspended())
	assert_eq(mission.attempt.runtime.state, RuntimeState.Value.COMPLETED)
	assert_eq(mission.buneko.position, position)
	assert_eq(mission.buneko.current_health(), health)
	assert_eq(mission.level.enemies.map(func(enemy): return enemy.position), enemy_positions)
	assert_signal_not_emitted(mission, "selection_requested")
	assert_signal_not_emitted(mission, "editing_requested")
	mission.milestone_primary.pressed.emit()
	mission.milestone_secondary.pressed.emit()
	mission.milestone_primary.pressed.emit()
	assert_signal_emit_count(mission, "selection_requested", 1)
	assert_signal_not_emitted(mission, "editing_requested")

func test_fall_does_not_show_victory() -> void:
	var mission = _mission()
	mission.buneko.position.y = mission.level.WORLD_SIZE.y + 70
	for frame in 10:
		await get_tree().physics_frame
		if not mission.outcome.is_empty():
			break
	assert_eq(mission.outcome, "fell")
	assert_false(mission.milestone_overlay.visible)
	assert_false(mission.edit_button.disabled)

func test_milestone_layout_and_keyboard_focus_fit_supported_sizes() -> void:
	for target in [Vector2i(960, 540), Vector2i(1440, 810), Vector2i(1600, 900)]:
		for victory in [false, true]:
			var viewport := SubViewport.new()
			viewport.size = target
			add_child_autofree(viewport)
			var session = SessionScript.new()
			session.complete_tutorial(BaseBunekoParts.complete_assembly(), Importer.new().import_program(Examples.new().build_program()))
			session.preparation_confirmed = true
			var mission = MissionScene.instantiate()
			mission.configure_session(session)
			viewport.add_child(mission)
			if victory:
				mission.buneko.position = mission.level.exit_rect().get_center()
				mission._physics_process(0.0)
			else:
				mission.level._on_baton_collected()
			for frame in 6:
				await get_tree().process_frame
			var bounds := Rect2(Vector2.ZERO, Vector2(target))
			var context := "size=%s victory=%s" % [target, victory]
			assert_true(mission.milestone_overlay.visible, context)
			assert_true(bounds.encloses(mission.milestone_panel.get_global_rect()), "%s panel=%s" % [context, mission.milestone_panel.get_global_rect()])
			for control in [mission.milestone_title, mission.milestone_description, mission.milestone_primary]:
				assert_true(mission.milestone_panel.get_global_rect().encloses(control.get_global_rect()), "%s control=%s rect=%s" % [context, control.name, control.get_global_rect()])
				assert_gt(control.size.y, 0.0)
			assert_true(mission.milestone_primary.has_focus(), "%s focus=%s" % [context, viewport.gui_get_focus_owner()])
			var next_focus: Control = mission.milestone_secondary if victory else mission.milestone_primary
			assert_same(mission.milestone_primary.find_next_valid_focus(), next_focus)
			if victory:
				assert_true(bounds.encloses(mission.milestone_secondary.get_global_rect()))
				assert_same(mission.milestone_secondary.find_next_valid_focus(), mission.milestone_primary)
			viewport.queue_free()
			await get_tree().process_frame

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
