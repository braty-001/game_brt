extends GutTest

const MissionScene = preload("res://scenes/campaign/laboratory_mission.tscn")
const LevelScene = preload("res://scenes/campaign/laboratory_level.tscn")
const SelectionScene = preload("res://scenes/campaign/campaign_selection.tscn")
const SessionScript = preload("res://src/campaign/campaign_session.gd")
const Examples = preload("res://src/campaign/laboratory/laboratory_example_provider.gd")
const Importer = preload("res://src/brain_editor/program_graph_importer.gd")
const EnemyScene = preload("res://scenes/campaign/patrol_melee_enemy.tscn")
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

func test_initial_pickup_waits_for_confirmation_with_simulation_frozen() -> void:
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
	assert_signal_not_emitted(mission, "editing_requested")
	assert_true(mission.milestone_overlay.visible)
	assert_eq(mission.milestone_title.text, "Bastao adquirido!")
	assert_string_contains(mission.milestone_description.text, "Atacar")
	assert_string_contains(mission.milestone_description.text, "checkpoint")
	assert_false(mission.milestone_secondary.visible)
	assert_true(mission.pause_button.disabled)
	assert_true(mission.edit_button.disabled)
	assert_eq(mission.level.process_mode, Node.PROCESS_MODE_DISABLED)
	var position: Vector2 = mission.buneko.position
	var health: int = mission.buneko.current_health()
	var instruction: String = mission.attempt.runtime.current_block_id
	var enemy_positions: Array = mission.level.enemies.map(func(enemy): return enemy.position)
	var graph = session.graph_state
	mission.pause_button.pressed.emit()
	mission.edit_button.pressed.emit()
	for frame in 60:
		await get_tree().physics_frame
	assert_eq(mission.buneko.position, position)
	assert_eq(mission.buneko.current_health(), health)
	assert_eq(mission.attempt.runtime.current_block_id, instruction)
	assert_eq(mission.level.enemies.map(func(enemy): return enemy.position), enemy_positions)
	assert_eq(mission.attempt.runtime.state, RuntimeState.Value.STOPPED)
	assert_true(mission.level.is_simulation_suspended())
	assert_signal_not_emitted(mission, "editing_requested")
	assert_true(mission.milestone_overlay.visible)
	mission.milestone_primary.pressed.emit()
	mission.milestone_primary.pressed.emit()
	assert_signal_emit_count(mission, "editing_requested", 1)
	assert_same(session.graph_state, graph)

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
	assert_eq(snapshot.ram, "3/10 RAM")
	assert_true(snapshot.is_valid)
	assert_true(snapshot.program.blocks.values().any(func(block): return block.kind == ProgramBlockKind.Value.ATTACK))

func test_pickup_cancels_impact_without_resuming_behind_notice() -> void:
	var mission = MissionScene.instantiate()
	mission.configure_session(_session(Examples.new().build_program()))
	add_child_autofree(mission)
	var enemy = mission.level.enemies[0]
	enemy.position = mission.buneko.position + Vector2(50, 0)
	enemy.face_direction(-1)
	mission.level._queue_strike(enemy)
	mission.level._resolve_strikes()
	assert_true(mission.impact_pause_active)
	assert_eq(mission.buneko.current_health(), 8)
	mission.level._on_baton_collected()
	var position: Vector2 = mission.buneko.position
	await get_tree().create_timer(0.12, true, false, true).timeout
	assert_true(mission.milestone_overlay.visible)
	assert_false(mission.impact_pause_active)
	assert_true(mission.level.is_simulation_suspended())
	assert_eq(mission.buneko.position, position)
	assert_eq(mission.buneko.current_health(), 8)
	assert_eq(mission.attempt.runtime.state, RuntimeState.Value.STOPPED)
	assert_eq(mission.restart_count, 0)

func test_combat_route_uses_exactly_ten_ram_kills_and_escapes_repeatedly() -> void:
	var program = Examples.new(true).build_program(Examples.Example.COMBAT_ROUTE)
	assert_eq(ProgramRamCalculator.used_ram(program), 10)
	assert_true(ProgramValidator.validate(program, 10).is_empty())
	for run in 5:
		var mission = _checkpoint_mission(program)
		var crossing_jump_accepted := false
		var crossing_left_ground := false
		var crossing_landed := false
		var first_turn_observation: Array = []
		for frame in 2400:
			await get_tree().physics_frame
			if mission.attempt.runtime.last_executed_block_id == "turn" and first_turn_observation.is_empty():
				first_turn_observation = [
					mission.buneko.position,
					mission.level.sensor.has_step_ahead(),
					mission.level.sensor.is_path_clear_ahead(),
				]
			if mission.attempt.runtime.last_executed_block_id == "jump_back" and mission.attempt.is_waiting_for_jump_landing():
				crossing_jump_accepted = true
				crossing_left_ground = crossing_left_ground or not mission.buneko.is_on_floor()
			elif crossing_left_ground and mission.buneko.is_on_floor():
				crossing_landed = true
			if not mission.outcome.is_empty():
				break
		assert_true(crossing_jump_accepted, "run=%d never accepted jump_back" % run)
		assert_true(crossing_left_ground, "run=%d jump_back never left the floor" % run)
		assert_true(crossing_landed, "run=%d evaluated escape before landing" % run)
		assert_eq(mission.outcome, "escaped", "run=%d pos=%s block=%s hp=%d dir=%d path=%s turn=%s" % [run, mission.buneko.position, mission.attempt.runtime.last_executed_block_id, mission.buneko.current_health(), mission.buneko.facing_direction(), mission.level.sensor.is_path_clear_ahead(), first_turn_observation])
		assert_true(mission.milestone_overlay.visible)
		assert_eq(mission.milestone_title.text, "Missao concluida!")
		assert_lte(mission.level.living_enemy_count(), 2)
		assert_gt(mission.buneko.current_health(), 0)
		mission.queue_free()
		await get_tree().process_frame

func test_melee_example_drops_one_enemy_with_one_hit_and_program_finishes() -> void:
	var mission = _checkpoint_mission(Examples.new(true).build_program(Examples.Example.MELEE))
	for frame in 900:
		await get_tree().physics_frame
		if not mission.outcome.is_empty():
			break
	assert_eq(mission.outcome, "finished")
	assert_false(mission.milestone_overlay.visible)
	assert_eq(mission.level.living_enemy_count(), 2)
	assert_eq(mission.level.enemies[0].current_health(), 0)
	assert_eq(mission.level.enemies[1].current_health(), 2)
	assert_eq(mission.level.enemies[2].current_health(), 2)
	assert_true(mission.buneko.current_health() in [8, 10])

func test_same_physics_batch_allows_exchange_of_damage() -> void:
	var level = LevelScene.instantiate()
	add_child_autofree(level)
	var buneko = level.spawn(BaseBunekoParts.complete_assembly(), true)
	var enemy = level.enemies[0]
	buneko.position = Vector2(200, 594)
	enemy.position = Vector2(250, 594)
	buneko.face_direction(1)
	enemy.face_direction(-1)
	level._queue_strike(buneko)
	level._queue_strike(enemy)
	level._resolve_strikes()
	assert_eq(enemy.current_health(), 0)
	assert_eq(buneko.current_health(), 8)

func test_laboratory_exposes_only_buneko_visual_above_fog() -> void:
	var level = LevelScene.instantiate()
	add_child_autofree(level)
	var buneko = level.spawn(BaseBunekoParts.complete_assembly(), true)
	assert_gt(buneko.get_node("Visual").z_index, level.get_node("Fog").z_index)
	assert_lt(level.enemies[0].get_node("Visual").z_index, level.get_node("Fog").z_index)
	assert_eq(buneko.get_node("CollisionShape2D").z_index, 0)

func test_combat_events_distinguish_accepted_hit_miss_and_damage() -> void:
	var level = LevelScene.instantiate()
	add_child_autofree(level)
	var buneko = level.spawn(BaseBunekoParts.complete_assembly(), true)
	var enemy = level.enemies[0]
	level.process_mode = Node.PROCESS_MODE_DISABLED
	buneko.position = Vector2(200, 594)
	enemy.position = Vector2(250, 594)
	buneko.face_direction(1)
	watch_signals(buneko)
	watch_signals(enemy)
	watch_signals(level)
	assert_true(buneko.attack())
	assert_false(buneko.attack())
	assert_signal_emit_count(buneko, "attack_started", 1)
	level._queue_strike(buneko)
	level._resolve_strikes()
	assert_signal_emitted(enemy, "damage_received")
	var hit_results: Array = get_signal_parameters(level, "combat_batch_resolved")[0]
	assert_true(hit_results[0].hit)
	buneko.melee.reset()
	enemy.position = Vector2(400, 594)
	level._queue_strike(buneko)
	level._resolve_strikes()
	var miss_results: Array = get_signal_parameters(level, "combat_batch_resolved", 1)[0]
	assert_false(miss_results[0].hit)

func test_wall_between_bodies_blocks_melee_damage() -> void:
	var level = LevelScene.instantiate()
	add_child_autofree(level)
	var buneko = level.spawn(BaseBunekoParts.complete_assembly(), true)
	var enemy = level.enemies[0]
	buneko.position = Vector2(200, 594)
	enemy.position = Vector2(250, 594)
	buneko.face_direction(1)
	level._combat_vision.occluders.assign([Rect2(220, 550, 10, 90)])
	level._queue_strike(buneko)
	level._resolve_strikes()
	assert_eq(enemy.current_health(), 2)

func test_melee_occlusion_is_independent_from_visual_cone() -> void:
	var level = LevelScene.instantiate()
	add_child_autofree(level)
	var buneko = level.spawn(BaseBunekoParts.complete_assembly(), true)
	var enemy = level.enemies[0]
	level.process_mode = Node.PROCESS_MODE_DISABLED
	buneko.position = Vector2(200, 594)
	enemy.position = Vector2(250, 594)
	buneko.face_direction(1)
	assert_false(level.can_see_target(buneko.combat_position(), -1, enemy.combat_position()))
	level._queue_strike(buneko)
	level._resolve_strikes()
	assert_eq(enemy.current_health(), 0)

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
	assert_eq(buneko.current_health(), 10)
	assert_eq(enemy.current_health(), 2)

func test_combat_sensor_requires_weapon_and_ignores_defeated_target() -> void:
	var level = LevelScene.instantiate()
	add_child_autofree(level)
	var buneko = level.spawn(BaseBunekoParts.complete_assembly(), false)
	buneko.position = Vector2(200, 594)
	buneko.face_direction(1)
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
	var enemy_position: Vector2 = mission.level.enemies[0].position
	var enemy_attack_time: float = mission.level.enemies[0].attack_elapsed()
	mission.buneko.receive_damage(10)
	await get_tree().physics_frame
	assert_true(mission.defeat_presentation_active)
	assert_eq(mission.restart_count, 0)
	await get_tree().create_timer(0.25, true, false, true).timeout
	assert_eq(mission.level.enemies[0].position, enemy_position)
	assert_eq(mission.level.enemies[0].attack_elapsed(), enemy_attack_time)
	var wait_started := Time.get_ticks_msec()
	while mission.restart_count == 0 and Time.get_ticks_msec() - wait_started < 900:
		await get_tree().process_frame
	assert_eq(mission.restart_count, 1)
	assert_eq(mission.buneko.current_health(), 10)
	assert_true(mission.buneko.has_baton())
	assert_eq(mission.level.living_enemy_count(), 3)
	assert_same(mission.session.graph_state, graph)
	assert_eq(mission.last_restart_position, Vector2(180, 594))
	assert_false(mission.milestone_overlay.visible)

func test_confirmed_impact_pauses_once_and_miss_does_not_pause() -> void:
	var mission = _checkpoint_mission(Examples.new().build_program())
	var configured_time_scale := Engine.time_scale
	var enemy = mission.level.enemies[0]
	mission.buneko.position = Vector2(200, 594)
	enemy.position = Vector2(250, 594)
	mission.buneko.face_direction(1)
	mission.level._queue_strike(mission.buneko)
	mission.level._resolve_strikes()
	assert_true(mission.impact_pause_active)
	assert_true(mission.level.is_simulation_suspended())
	await _wait_for_impact_end(mission)
	assert_false(mission.impact_pause_active)
	assert_false(mission.level.is_simulation_suspended())
	assert_eq(Engine.time_scale, configured_time_scale)
	mission.buneko.melee.reset()
	enemy.position = Vector2(500, 594)
	mission.level._queue_strike(mission.buneko)
	mission.level._resolve_strikes()
	assert_false(mission.impact_pause_active)

func test_manual_pause_during_impact_prevents_automatic_resume() -> void:
	var mission = _checkpoint_mission(Examples.new().build_program())
	var enemy = mission.level.enemies[0]
	mission.buneko.position = Vector2(200, 594)
	enemy.position = Vector2(250, 594)
	mission.buneko.face_direction(1)
	mission.level._queue_strike(mission.buneko)
	mission.level._resolve_strikes()
	mission.toggle_pause()
	assert_true(mission.paused)
	await _wait_for_impact_end(mission)
	assert_true(mission.paused)
	assert_eq(mission.level.process_mode, Node.PROCESS_MODE_DISABLED)
	assert_eq(mission.attempt.runtime.state, RuntimeState.Value.PAUSED)
	mission.toggle_pause()
	assert_false(mission.paused)
	assert_eq(mission.level.process_mode, Node.PROCESS_MODE_INHERIT)

func test_simultaneous_defeat_uses_impact_then_waits_for_manual_pause() -> void:
	var mission = _checkpoint_mission(Examples.new().build_program())
	var enemy = mission.level.enemies[0]
	mission.buneko.position = Vector2(200, 594)
	enemy.position = Vector2(250, 594)
	mission.buneko.face_direction(1)
	enemy.face_direction(-1)
	mission.buneko.receive_damage(8)
	mission.level._queue_strike(mission.buneko)
	mission.level._queue_strike(enemy)
	mission.level._resolve_strikes()
	assert_true(mission.impact_pause_active)
	assert_eq(mission.buneko.current_health(), 0)
	assert_eq(enemy.current_health(), 0)
	mission.toggle_pause()
	assert_true(mission.paused)
	await get_tree().create_timer(0.75, true, false, true).timeout
	assert_eq(mission.restart_count, 0)
	assert_true(mission.defeat_presentation_active)
	assert_true(mission._defeat_ready_to_restart)
	mission.toggle_pause()
	assert_eq(mission.restart_count, 1)
	assert_false(mission.paused)
	await get_tree().process_frame

func test_editing_cancels_active_impact_without_delayed_resume() -> void:
	var mission = _checkpoint_mission(Examples.new().build_program())
	var enemy = mission.level.enemies[0]
	mission.buneko.position = Vector2(200, 594)
	enemy.position = Vector2(250, 594)
	mission.buneko.face_direction(1)
	mission.level._queue_strike(mission.buneko)
	mission.level._resolve_strikes()
	assert_true(mission.impact_pause_active)
	mission._request_editing()
	assert_false(mission.impact_pause_active)
	assert_false(mission.defeat_presentation_active)
	assert_eq(mission.level.process_mode, Node.PROCESS_MODE_DISABLED)
	await get_tree().create_timer(0.08, true, false, true).timeout
	assert_eq(mission.attempt.runtime.state, RuntimeState.Value.STOPPED)

func test_pause_freezes_enemy_ai_attack_and_health() -> void:
	var mission = _checkpoint_mission(Examples.new().build_program())
	for frame in 20:
		await get_tree().physics_frame
	mission.toggle_pause()
	var enemy_position: Vector2 = mission.level.enemies[0].position
	var enemy_attack_time: float = mission.level.enemies[0].attack_elapsed()
	var health: int = mission.buneko.current_health()
	for frame in 60:
		await get_tree().physics_frame
	assert_eq(mission.level.enemies[0].position, enemy_position)
	assert_eq(mission.level.enemies[0].attack_elapsed(), enemy_attack_time)
	assert_eq(mission.buneko.current_health(), health)
	mission.toggle_pause()
	assert_false(mission.paused)

func test_enemy_detection_uses_its_own_facing_direction() -> void:
	var level = LevelScene.instantiate()
	add_child_autofree(level)
	var buneko = level.spawn(BaseBunekoParts.complete_assembly(), true)
	var enemy = level.enemies[0]
	buneko.position = Vector2(200, 594)
	enemy.position = Vector2(300, 594)
	enemy.face_direction(1)
	assert_false(level.can_see_target(enemy.combat_position(), enemy.facing_direction(), buneko.combat_position()))
	assert_false(enemy._can_see_position(buneko.combat_position()))
	enemy.face_direction(-1)
	assert_true(level.can_see_target(enemy.combat_position(), enemy.facing_direction(), buneko.combat_position()))
	assert_true(enemy._can_see_position(buneko.combat_position()))

func test_enemy_facing_visual_survives_physics_and_repeated_direction_requests() -> void:
	var enemy = EnemyScene.instantiate()
	add_child_autofree(enemy)
	enemy.set_physics_process(false)
	var visual = enemy.get_node("Visual")
	for direction in [-1, -1, 1, 1, -1, 1]:
		assert_true(enemy.face_direction(direction))
		enemy.velocity = Vector2(0, 10)
		enemy.move_and_slide()
		await get_tree().physics_frame
		await get_tree().process_frame
		assert_eq(enemy.facing_direction(), direction)
		assert_almost_eq(visual.global_transform.x.x, float(direction), 0.0001, "Rendered forward must follow logical facing after physics")
		assert_almost_eq(visual.global_transform.y.y, 1.0, 0.0001)
		assert_almost_eq(enemy.get_node("CollisionShape2D").global_transform.x.x, 1.0, 0.0001)

func test_enemy_visual_tracks_awareness_attack_damage_and_defeat() -> void:
	var enemy = EnemyScene.instantiate()
	add_child_autofree(enemy)
	var visual = enemy.get_node("Visual")
	enemy.awareness_changed.emit(enemy, true)
	assert_true(visual.presentation_snapshot().awareness_cue)
	enemy._melee.begin()
	assert_eq(visual.presentation_snapshot().attack_phase, "windup")
	enemy._melee.advance(enemy._melee.WINDUP_SECONDS)
	assert_eq(visual.presentation_snapshot().attack_phase, "strike")
	enemy.receive_damage(1)
	assert_true(visual.presentation_snapshot().damage_reacting)
	enemy.receive_damage(1)
	assert_true(visual.presentation_snapshot().defeated)

func test_enemy_baton_contact_is_continuous_in_both_directions() -> void:
	var enemy = EnemyScene.instantiate()
	add_child_autofree(enemy)
	enemy.set_physics_process(false)
	var visual = enemy.get_node("Visual")
	for direction in [1, -1]:
		enemy.face_direction(direction)
		assert_true(enemy._melee.begin())
		assert_almost_eq(visual.presentation_snapshot().baton_angle, -0.76, 0.0001)
		assert_false(enemy._melee.advance(0.12))
		assert_almost_eq(visual.presentation_snapshot().baton_angle, -1.72, 0.0001)
		assert_false(enemy._melee.advance(0.0799))
		assert_almost_eq(visual.presentation_snapshot().baton_angle, 0.3, 0.003)
		assert_true(enemy._melee.advance(0.0002))
		assert_almost_eq(visual.presentation_snapshot().baton_angle, 0.3, 0.0001)
		assert_false(enemy._melee.advance(0.16))
		assert_almost_eq(visual.presentation_snapshot().baton_angle, 0.3, 0.001)
		assert_false(enemy._melee.advance(0.4398))
		assert_almost_eq(visual.presentation_snapshot().baton_angle, -0.76, 0.001)
		assert_false(enemy._melee.advance(0.0002))
		assert_eq(visual.presentation_snapshot().attack_phase, "idle")

func test_real_strikes_reach_contact_on_damage_and_hold_through_impact_pause() -> void:
	var mission = _checkpoint_mission(Examples.new().build_program())
	mission.set_physics_process(false)
	mission.level.set_simulation_suspended(true)
	var buneko = mission.buneko
	var enemy = mission.level.enemies[0]
	buneko.position = Vector2(200, 594)
	enemy.position = Vector2(250, 594)
	buneko.face_direction(1)
	enemy.face_direction(-1)
	var player_visual = buneko.get_node("Visual")
	var enemy_visual = enemy.get_node("Visual")
	var observed_angles: Array = []
	buneko.damage_received.connect(func(_actor, _amount): observed_angles.append(enemy_visual.presentation_snapshot().baton_angle))
	enemy.damage_received.connect(func(_actor, _amount): observed_angles.append(player_visual.presentation_snapshot().baton_angle))
	assert_true(buneko.attack())
	assert_true(enemy._melee.begin())
	buneko._physics_process(0.19)
	enemy._physics_process(0.19)
	mission.level._resolve_strikes()
	assert_eq(buneko.current_health(), 10)
	assert_eq(enemy.current_health(), 2)
	assert_false(mission.impact_pause_active)
	buneko._physics_process(0.01)
	enemy._physics_process(0.01)
	mission.level._resolve_strikes()
	assert_eq(buneko.current_health(), 8)
	assert_eq(enemy.current_health(), 0)
	assert_eq(observed_angles.size(), 2)
	assert_almost_eq(observed_angles[0], 0.28, 0.0001)
	assert_almost_eq(observed_angles[1], 0.3, 0.0001)
	assert_true(mission.impact_pause_active)
	assert_almost_eq(enemy_visual.presentation_snapshot().baton_angle, 0.3, 0.0001, "Lethal damage must preserve contact despite attack reset")
	mission.toggle_pause()
	await _wait_for_impact_end(mission)
	assert_true(mission.paused)
	assert_false(mission.impact_pause_active)
	assert_almost_eq(player_visual.presentation_snapshot().baton_angle, 0.28, 0.0001)
	assert_almost_eq(enemy_visual.presentation_snapshot().baton_angle, 0.3, 0.0001)
	assert_eq(buneko.current_health(), 8)
	assert_eq(enemy.current_health(), 0)

func test_enemy_archetype_configuration_is_per_instance() -> void:
	var sturdy_enemy = EnemyScene.instantiate()
	sturdy_enemy.maximum_health = 6
	sturdy_enemy.movement_speed = 70.0
	var default_enemy = EnemyScene.instantiate()
	add_child_autofree(sturdy_enemy)
	add_child_autofree(default_enemy)
	assert_eq(sturdy_enemy.current_health(), 6)
	assert_eq(sturdy_enemy.health_capacity(), 6)
	assert_eq(default_enemy.current_health(), 2)
	sturdy_enemy.receive_damage(2)
	assert_eq(sturdy_enemy.current_health(), 4)
	assert_eq(default_enemy.current_health(), 2)

func test_laboratory_declares_enemy_spawns_and_preserves_patrol_configuration() -> void:
	var level = LevelScene.instantiate()
	add_child_autofree(level)
	var spawn_points := level.get_node("EnemySpawns").get_children()
	assert_eq(spawn_points.size(), 3)
	assert_eq(spawn_points[0].global_position, Vector2(520, 594))
	assert_gt(spawn_points[0].global_position.x - level.get_node("Checkpoint").position.x - spawn_points[0].patrol_left_distance, 240.0)
	assert_eq(spawn_points[0].patrol_left_distance, 50.0)
	assert_eq(spawn_points[0].patrol_right_distance, 420.0)
	assert_eq(spawn_points[0].initial_direction, -1)
	assert_eq(spawn_points[2].initial_direction, -1)

func test_danger_cue_uses_buneko_vision_and_restores_previous_time_scale() -> void:
	var mission = _checkpoint_mission(Examples.new(true).build_program(Examples.Example.COMBAT_ROUTE))
	var enemy = mission.level.enemies[0]
	enemy.position = Vector2(350, 594)
	mission.buneko.face_direction(-1)
	mission._observe_danger(1000)
	assert_eq(Engine.time_scale, 10.0)
	assert_false(mission.danger_cue.was_visible)
	mission.buneko.face_direction(1)
	mission._observe_danger(1100)
	assert_true(mission.danger_cue.was_visible)
	assert_eq(Engine.time_scale, 4.0)
	mission.toggle_pause()
	assert_eq(Engine.time_scale, 10.0)
	mission._observe_danger(1200)
	assert_eq(Engine.time_scale, 10.0)
	mission.queue_free()
	await get_tree().process_frame
	assert_eq(Engine.time_scale, 10.0)

func test_audio_uses_confirmed_events_and_hides_unseen_enemy_actions() -> void:
	var level = LevelScene.instantiate()
	add_child_autofree(level)
	var buneko = level.spawn(BaseBunekoParts.complete_assembly(), true)
	var enemy = level.enemies[0]
	watch_signals(level.combat_audio)
	buneko.position = Vector2(200, 594)
	buneko.face_direction(1)
	enemy.position = Vector2(250, 594)
	level._queue_strike(enemy)
	assert_signal_emitted_with_parameters(level.combat_audio, "audio_event_played", ["swing"])
	level._resolve_strikes()
	assert_signal_emitted_with_parameters(level.combat_audio, "audio_event_played", ["hit"])
	enemy.position = Vector2(-200, 594)
	var prior_count: int = get_signal_emit_count(level.combat_audio, "audio_event_played")
	level._queue_strike(enemy)
	level._resolve_strikes()
	assert_eq(get_signal_emit_count(level.combat_audio, "audio_event_played"), prior_count)
	buneko.landed.emit(buneko)
	assert_signal_emitted_with_parameters(level.combat_audio, "audio_event_played", ["landing"])

func test_ground_enemy_autonomously_detects_and_deals_exactly_two_damage() -> void:
	var level = LevelScene.instantiate()
	add_child_autofree(level)
	var buneko = level.spawn(BaseBunekoParts.complete_assembly(), true)
	level.enemies[0].position = Vector2(300, 594)
	watch_signals(level.enemies[0])
	buneko.position = Vector2(180, 594)
	for frame in 480:
		await get_tree().physics_frame
		if buneko.current_health() < 10:
			break
	assert_eq(buneko.current_health(), 8)
	assert_signal_emitted(level.enemies[0], "attack_started")

func test_started_enemy_strike_misses_when_buneko_jumps_out_of_range() -> void:
	var level = LevelScene.instantiate()
	add_child_autofree(level)
	var buneko = level.spawn(BaseBunekoParts.complete_assembly(), true)
	var enemy = level.enemies[0]
	enemy.position = Vector2(300, 594)
	buneko.position = Vector2(180, 594)
	watch_signals(enemy)
	for frame in 480:
		await get_tree().physics_frame
		if get_signal_emit_count(enemy, "attack_started") > 0:
			assert_true(buneko.jump())
			break
	assert_signal_emitted(enemy, "attack_started")
	for frame in 60:
		await get_tree().physics_frame
		if get_signal_emit_count(enemy, "strike_requested") > 0:
			await get_tree().physics_frame
			break
	level.set_simulation_suspended(true)
	assert_signal_emitted(enemy, "strike_requested")
	assert_eq(buneko.current_health(), 10)

func test_landing_event_ignores_spawn_and_fires_once_after_real_jump() -> void:
	var level = LevelScene.instantiate()
	add_child_autofree(level)
	var buneko = level.spawn(BaseBunekoParts.complete_assembly(), true)
	level.enemies.all(func(enemy): enemy.set_physics_process(false))
	watch_signals(buneko)
	for frame in 12:
		await get_tree().physics_frame
	assert_signal_not_emitted(buneko, "landed")
	assert_true(buneko.jump())
	for frame in 180:
		await get_tree().physics_frame
		if get_signal_emit_count(buneko, "landed") > 0:
			break
	assert_signal_emit_count(buneko, "landed", 1)

func test_step_audio_requires_effective_ground_movement_and_stops_in_air() -> void:
	var level = LevelScene.instantiate()
	add_child_autofree(level)
	var buneko = level.spawn(BaseBunekoParts.complete_assembly(), true)
	for enemy in level.enemies:
		enemy.set_physics_process(false)
	var audio_events: Array[String] = []
	level.combat_audio.audio_event_played.connect(func(kind: String): audio_events.append(kind))
	for frame in 12:
		await get_tree().physics_frame
	assert_eq(audio_events.count("step"), 0)
	for frame in 90:
		buneko.walk(MovementPace.Value.FAST)
		await get_tree().physics_frame
		if audio_events.has("step"):
			break
	assert_gt(audio_events.count("step"), 0)
	assert_true(buneko.jump())
	var step_count := audio_events.count("step")
	for frame in 18:
		buneko.walk(MovementPace.Value.FAST)
		await get_tree().physics_frame
	assert_false(buneko.is_on_floor())
	assert_eq(audio_events.count("step"), step_count)

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

func _wait_for_impact_end(mission) -> void:
	# A pausa usa tempo monotono; o delta do SceneTreeTimer diverge em headless acelerado.
	var deadline := Time.get_ticks_msec() + 500
	while mission.impact_pause_active and Time.get_ticks_msec() < deadline:
		await get_tree().process_frame
	assert_false(mission.impact_pause_active, "Impact pause must finish within 500 ms of real time")
