extends GutTest

const MissionScene = preload("res://scenes/campaign/laboratory_mission.tscn")
const LevelScene = preload("res://scenes/campaign/laboratory_level.tscn")
const SelectionScene = preload("res://scenes/campaign/campaign_selection.tscn")
const SessionScript = preload("res://src/campaign/campaign_session.gd")
const Examples = preload("res://src/campaign/laboratory/laboratory_example_provider.gd")
const Importer = preload("res://src/brain_editor/program_graph_importer.gd")
var previous_ticks: int
var previous_time_scale: float

func before_each() -> void:
	previous_ticks = Engine.physics_ticks_per_second
	previous_time_scale = Engine.time_scale
	Engine.physics_ticks_per_second = 600
	Engine.time_scale = 10.0

func after_each() -> void:
	Engine.physics_ticks_per_second = previous_ticks
	Engine.time_scale = previous_time_scale

func test_initial_pickup_equips_baton_marks_checkpoint_and_requests_editor() -> void:
	var session = _session(Examples.new().build_program())
	var mission = MissionScene.instantiate()
	mission.configure_session(session)
	add_child_autofree(mission)
	watch_signals(mission)
	for frame in 240:
		await get_tree().physics_frame
		if session.baton_checkpoint_active:
			break
	assert_true(session.baton_checkpoint_active)
	assert_true(session.baton_checkpoint_intro_seen)
	assert_true(mission.buneko.has_baton())
	assert_false(session.preparation_confirmed)
	await get_tree().process_frame
	assert_signal_emitted(mission, "editing_requested")
	assert_eq(mission.level.process_mode, Node.PROCESS_MODE_DISABLED)

func test_checkpoint_editor_unlocks_only_combat_capabilities_and_example() -> void:
	var before = SelectionScene.instantiate()
	var session = _session(Examples.new().build_program())
	before.configure_session(session)
	add_child_autofree(before)
	assert_true(before.open_preparation())
	assert_null(before.brain_editor.palette.item_for_kind(ProgramBlockKind.Value.ATTACK))
	assert_eq(before.brain_editor.condition_selector.available_options().size(), 4)
	before.queue_free()
	await get_tree().process_frame
	session.activate_baton_checkpoint()
	var after = SelectionScene.instantiate()
	after.configure_session(session)
	add_child_autofree(after)
	assert_true(after.open_preparation())
	assert_not_null(after.brain_editor.palette.item_for_kind(ProgramBlockKind.Value.ATTACK))
	assert_eq(after.brain_editor.condition_selector.available_options().size(), 6)
	assert_eq(after.brain_editor.example_selector.item_count, 3)
	assert_true(after.brain_editor.load_example(Examples.Example.MELEE))
	var snapshot = after.brain_editor.capture_snapshot()
	assert_eq(snapshot.ram, "2/10 RAM")
	assert_true(snapshot.is_valid)
	assert_true(snapshot.program.blocks.values().any(func(block): return block.kind == ProgramBlockKind.Value.ATTACK))

func test_combat_route_uses_exactly_ten_ram_kills_and_escapes_repeatedly() -> void:
	var program = Examples.new(true).build_program(Examples.Example.COMBAT_ROUTE)
	assert_eq(ProgramRamCalculator.used_ram(program), 10)
	assert_true(ProgramValidator.validate(program, 10).is_empty())
	for run in 5:
		var mission = _checkpoint_mission(program)
		var escape_observations: Array = []
		for frame in 2400:
			await get_tree().physics_frame
			if mission.attempt.runtime.last_executed_block_id == "escape" and mission.attempt.runtime.has_last_condition_result:
				escape_observations.append([mission.buneko.position, mission.attempt.runtime.last_condition_result, mission.buneko.is_on_floor(), mission.attempt.is_waiting_for_jump_landing()])
			if not mission.outcome.is_empty():
				break
		assert_eq(mission.outcome, "escaped", "run=%d pos=%s block=%s hp=%d dir=%d path=%s observations=%s" % [run, mission.buneko.position, mission.attempt.runtime.last_executed_block_id, mission.buneko.health.current, mission.buneko.controller.direction, mission.level.sensor.is_path_clear_ahead(), escape_observations])
		assert_lte(mission.level.living_enemy_count(), 2)
		assert_gt(mission.buneko.health.current, 0)
		mission.queue_free()
		await get_tree().process_frame

func test_melee_example_drops_one_enemy_with_one_hit_and_program_finishes() -> void:
	var mission = _checkpoint_mission(Examples.new(true).build_program(Examples.Example.MELEE))
	for frame in 900:
		await get_tree().physics_frame
		if not mission.outcome.is_empty():
			break
	assert_eq(mission.outcome, "finished")
	assert_eq(mission.level.living_enemy_count(), 2)
	assert_eq(mission.level.enemies[0].health.current, 0)
	assert_eq(mission.level.enemies[1].health.current, 2)
	assert_eq(mission.level.enemies[2].health.current, 2)
	assert_true(mission.buneko.health.current in [8, 10])

func test_same_physics_batch_allows_exchange_of_damage() -> void:
	var level = LevelScene.instantiate()
	add_child_autofree(level)
	var buneko = level.spawn(BaseBunekoParts.complete_assembly(), true)
	var enemy = level.enemies[0]
	buneko.position = Vector2(200, 594)
	enemy.position = Vector2(250, 594)
	buneko.controller.direction = 1
	enemy.direction = -1
	level._queue_strike(buneko)
	level._queue_strike(enemy)
	level._resolve_strikes()
	assert_eq(enemy.health.current, 0)
	assert_eq(buneko.health.current, 8)

func test_wall_between_bodies_blocks_melee_damage() -> void:
	var level = LevelScene.instantiate()
	add_child_autofree(level)
	var buneko = level.spawn(BaseBunekoParts.complete_assembly(), true)
	var enemy = level.enemies[0]
	buneko.position = Vector2(200, 594)
	enemy.position = Vector2(250, 594)
	buneko.controller.direction = 1
	level._combat_vision.occluders.assign([Rect2(220, 550, 10, 90)])
	level._queue_strike(buneko)
	level._resolve_strikes()
	assert_eq(enemy.health.current, 2)

func test_attack_program_is_rejected_before_weapon_and_allowed_after_checkpoint() -> void:
	var program = Examples.new(true).build_program(Examples.Example.MELEE)
	var session = _session(program)
	assert_false(session.program_can_run(program))
	session.activate_baton_checkpoint()
	assert_true(session.program_can_run(program))

func test_contact_without_strike_is_harmless() -> void:
	var level = LevelScene.instantiate()
	add_child_autofree(level)
	var buneko = level.spawn(BaseBunekoParts.complete_assembly(), true)
	var enemy = level.enemies[0]
	level.process_mode = Node.PROCESS_MODE_DISABLED
	buneko.position = enemy.position
	for frame in 10:
		await get_tree().physics_frame
	assert_eq(buneko.health.current, 10)
	assert_eq(enemy.health.current, 2)

func test_combat_sensor_requires_weapon_and_ignores_defeated_target() -> void:
	var level = LevelScene.instantiate()
	add_child_autofree(level)
	var buneko = level.spawn(BaseBunekoParts.complete_assembly(), false)
	buneko.position = Vector2(200, 594)
	buneko.controller.direction = 1
	level.enemies[0].position = Vector2(250, 594)
	level.enemies[1].position = Vector2(700, 354)
	level.enemies[2].position = Vector2(850, 354)
	level.sensor.update_from_buneko(buneko)
	assert_true(level.sensor.can_see_enemy())
	assert_false(level.sensor.has_enemy_in_melee_range())
	buneko.equip_baton()
	assert_true(level.sensor.has_enemy_in_melee_range())
	level.enemies[0].receive_damage(2)
	assert_false(level.sensor.can_see_enemy())
	assert_false(level.sensor.has_enemy_in_melee_range())

func test_defeat_restores_health_weapon_enemies_and_same_program_at_checkpoint() -> void:
	var program = Examples.new(true).build_program(Examples.Example.MELEE)
	var mission = _checkpoint_mission(program)
	var graph = mission.session.graph_state
	mission.buneko.receive_damage(10)
	for frame in 30:
		await get_tree().physics_frame
		if mission.restart_count == 1:
			break
	assert_eq(mission.restart_count, 1)
	assert_eq(mission.buneko.health.current, 10)
	assert_true(mission.buneko.has_baton())
	assert_eq(mission.level.living_enemy_count(), 3)
	assert_same(mission.session.graph_state, graph)
	assert_eq(mission.buneko.position, Vector2(180, 594))

func test_pause_freezes_enemy_ai_attack_and_health() -> void:
	var mission = _checkpoint_mission(Examples.new().build_program())
	for frame in 20:
		await get_tree().physics_frame
	mission.toggle_pause()
	var enemy_position: Vector2 = mission.level.enemies[0].position
	var enemy_attack_time: float = mission.level.enemies[0].melee.elapsed
	var health: int = mission.buneko.health.current
	for frame in 60:
		await get_tree().physics_frame
	assert_eq(mission.level.enemies[0].position, enemy_position)
	assert_eq(mission.level.enemies[0].melee.elapsed, enemy_attack_time)
	assert_eq(mission.buneko.health.current, health)
	mission.toggle_pause()
	assert_false(mission.paused)

func _checkpoint_mission(program):
	var session = _session(program)
	session.baton_checkpoint_active = true
	session.baton_checkpoint_intro_seen = true
	var mission = MissionScene.instantiate()
	mission.configure_session(session)
	add_child_autofree(mission)
	return mission

func _session(program):
	var session = SessionScript.new()
	session.complete_tutorial(BaseBunekoParts.complete_assembly(), Importer.new().import_program(program))
	session.preparation_confirmed = true
	return session
