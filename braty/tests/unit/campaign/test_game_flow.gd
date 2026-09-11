extends GutTest

const FlowScene = preload("res://scenes/campaign/game_flow.tscn")
const SelectionScript = preload("res://src/campaign/campaign_selection.gd")
const TutorialScript = preload("res://src/tutorial/tutorial_mission.gd")
const LaboratoryScript = preload("res://src/campaign/laboratory/laboratory_mission.gd")

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
