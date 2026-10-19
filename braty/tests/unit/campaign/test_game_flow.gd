extends GutTest

const FlowScene = preload("res://scenes/campaign/game_flow.tscn")
const SelectionScript = preload("res://src/campaign/campaign_selection.gd")
const TutorialScript = preload("res://src/tutorial/tutorial_mission.gd")
const LaboratoryScript = preload("res://src/campaign/laboratory/laboratory_mission.gd")

func test_baton_notice_confirmation_opens_editor_and_reentry_skips_notice() -> void:
	var flow = _prepared_flow()
	var graph = flow.session.graph_state
	var assembly = flow.session.assembly
	assert_true(flow.show_laboratory())
	var mission = flow.current_screen
	for frame in 180:
		await get_tree().physics_frame
		if mission.milestone_overlay.visible:
			break
	assert_true(mission.milestone_overlay.visible)
	await get_tree().process_frame
	assert_same(flow.current_screen, mission)
	mission.milestone_primary.pressed.emit()
	mission.milestone_primary.pressed.emit()
	await get_tree().process_frame
	var selection = flow.current_screen
	assert_true(selection is SelectionScript)
	assert_not_null(selection.brain_editor)
	assert_same(flow.session.graph_state, graph)
	assert_same(flow.session.assembly, assembly)
	assert_true(flow.session.baton_checkpoint_active)
	assert_not_null(selection.brain_editor.palette.item_for_kind(ProgramBlockKind.Value.ATTACK))
	assert_true(selection.return_to_briefing(true))
	assert_true(flow.show_laboratory())
	assert_true(flow.current_screen.buneko.has_baton())
	assert_eq(flow.current_screen.buneko.position, Vector2(180, 594))
	assert_false(flow.current_screen.milestone_overlay.visible)
	flow.queue_free()
	await get_tree().process_frame

func test_victory_choices_preserve_session_and_navigate_once() -> void:
	for open_editor in [false, true]:
		var flow = _prepared_flow()
		flow.session.activate_baton_checkpoint()
		flow.session.preparation_confirmed = true
		var graph = flow.session.graph_state
		var assembly = flow.session.assembly
		assert_true(flow.show_laboratory())
		var mission = flow.current_screen
		watch_signals(mission)
		mission.buneko.position = mission.level.exit_rect().get_center()
		for frame in 10:
			await get_tree().physics_frame
			if not mission.outcome.is_empty():
				break
		assert_eq(mission.outcome, "escaped")
		if mission.outcome != "escaped":
			return
		assert_true(mission.milestone_overlay.visible)
		var chosen: Button = mission.milestone_secondary if open_editor else mission.milestone_primary
		chosen.pressed.emit()
		chosen.pressed.emit()
		assert_signal_emit_count(mission, "editing_requested" if open_editor else "selection_requested", 1)
		await get_tree().process_frame
		var selection = flow.current_screen
		assert_true(selection is SelectionScript)
		assert_eq(selection.brain_editor != null, open_editor)
		assert_same(flow.session.graph_state, graph)
		assert_same(flow.session.assembly, assembly)
		assert_true(flow.session.baton_checkpoint_active)
		flow.queue_free()
		await get_tree().process_frame

func _prepared_flow():
	var flow = FlowScene.instantiate()
	add_child_autofree(flow)
	flow.session.complete_tutorial(BaseBunekoParts.complete_assembly(), null)
	flow.show_campaign()
	var selection = flow.current_screen
	selection.open_preparation()
	selection.brain_editor.load_example()
	selection.return_to_briefing(true)
	return flow

func test_campaign_confirmation_entry_and_return_preserve_graph_and_body() -> void:
	var flow = FlowScene.instantiate()
	add_child_autofree(flow)
	assert_false(flow.show_laboratory())
	flow.session.complete_tutorial(BaseBunekoParts.complete_assembly(), null)
	assert_true(flow.show_campaign())
	var selection = flow.current_screen
	assert_true(selection.enter_button.disabled)
	assert_true(selection.open_preparation())
	selection.brain_editor.load_example()
	assert_eq(selection.brain_editor.capture_snapshot().ram, "10/10 RAM")
	selection.brain_editor.select_block("stairs")
	assert_true(selection.brain_editor.move_selected_block(Vector2(600, 240)))
	selection.brain_editor.start_button.pressed.emit()
	await get_tree().process_frame
	assert_false(selection.enter_button.disabled)
	var graph = flow.session.graph_state
	var assembly = flow.session.assembly
	selection.enter_button.pressed.emit()
	await get_tree().process_frame
	assert_true(flow.current_screen is LaboratoryScript)
	assert_same(flow.current_screen.session.assembly, assembly)
	assert_eq(flow.current_screen.attempt.runtime.ram_capacity, 10)
	flow.current_screen.edit_button.pressed.emit()
	await get_tree().process_frame
	assert_true(flow.current_screen is SelectionScript)
	assert_not_null(flow.current_screen.brain_editor)
	assert_same(flow.session.graph_state, graph)
	var snapshot = flow.current_screen.brain_editor.capture_snapshot()
	assert_eq(snapshot.graph_state.blocks["stairs"].position, Vector2(600, 240))
	assert_eq(snapshot.ram, "10/10 RAM")

func test_menu_tutorial_goal_campaign_and_menu_round_trip() -> void:
	var flow = FlowScene.instantiate()
	add_child_autofree(flow)
	await get_tree().process_frame
	assert_false(flow.show_campaign())
	flow.current_screen.start_button.pressed.emit()
	await get_tree().process_frame
	var tutorial = flow.current_screen
	assert_true(tutorial is TutorialScript)
	assert_false(tutorial.complete_goal())
	assert_false(flow.session.tutorial_completed)
	tutorial.install_base_assembly()
	assert_true(tutorial.enter_editor())
	tutorial.brain_editor.load_example()
	assert_eq(tutorial.brain_editor.ram_capacity, 5)
	assert_true(tutorial.start_attempt())
	var original_graph = tutorial.current_graph_state
	var original_assembly = tutorial.current_assembly
	tutorial.level.get_node("Goal").reached.emit()
	await get_tree().process_frame
	assert_true(flow.current_screen is SelectionScript)
	assert_true(flow.session.tutorial_completed)
	assert_same(flow.session.graph_state, original_graph)
	assert_same(flow.session.assembly, original_assembly)
	var selection = flow.current_screen
	selection.prepare_button.pressed.emit()
	assert_eq(selection.brain_editor.ram_capacity, 10)
	selection.brain_editor.reset_brain()
	selection.brain_editor.create_block(ProgramBlockKind.Value.WALK)
	selection.menu_button.pressed.emit()
	await get_tree().process_frame
	assert_eq(flow.current_screen.start_button.text, "Campanha")
	flow.current_screen.start_button.pressed.emit()
	await get_tree().process_frame
	assert_true(flow.current_screen is SelectionScript)
	assert_true(flow.current_screen.open_preparation())
	assert_eq(flow.current_screen.brain_editor.block_count(), 1)

func test_tutorial_failure_does_not_unlock_campaign() -> void:
	var flow = FlowScene.instantiate()
	add_child_autofree(flow)
	await get_tree().process_frame
	flow.start_selected_flow()
	var tutorial = flow.current_screen
	tutorial.install_base_assembly()
	tutorial.enter_editor()
	tutorial.brain_editor.load_example()
	assert_true(tutorial.start_attempt())
	assert_true(tutorial.fail_by_fall())
	assert_false(flow.session.tutorial_completed)
	assert_false(flow.show_campaign())
	assert_same(flow.current_screen, tutorial)
	await get_tree().process_frame
