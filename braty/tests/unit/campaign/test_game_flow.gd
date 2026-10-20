extends GutTest

const FlowScene = preload("res://scenes/campaign/game_flow.tscn")
const SelectionScript = preload("res://src/campaign/campaign_selection.gd")
const TutorialScript = preload("res://src/tutorial/tutorial_mission.gd")
const LaboratoryScript = preload("res://src/campaign/laboratory/laboratory_mission.gd")
const SaveStoreScript = preload("res://src/campaign/campaign_save_store.gd")

var _save_paths: Array[String] = []

func after_each() -> void:
	for path in _save_paths:
		for suffix in ["", ".tmp"]:
			var candidate: String = path + suffix
			if FileAccess.file_exists(candidate):
				DirAccess.remove_absolute(ProjectSettings.globalize_path(candidate))
	_save_paths.clear()

func _new_flow():
	var flow = FlowScene.instantiate()
	var path := "user://test_game_flow_%d.json" % Time.get_ticks_usec()
	_save_paths.append(path)
	flow.configure_save_store(SaveStoreScript.new(path))
	return flow

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
	var flow = _new_flow()
	add_child_autofree(flow)
	flow.session.complete_tutorial(BaseBunekoParts.complete_assembly(), null)
	flow.show_campaign()
	var selection = flow.current_screen
	selection.open_preparation()
	selection.brain_editor.load_example()
	selection.return_to_briefing(true)
	return flow

func test_campaign_confirmation_entry_and_return_preserve_graph_and_body() -> void:
	var flow = _new_flow()
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
	var flow = _new_flow()
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
	assert_eq(flow.current_screen.start_button.text, "Continuar")
	flow.current_screen.start_button.pressed.emit()
	await get_tree().process_frame
	assert_true(flow.current_screen is SelectionScript)
	assert_true(flow.current_screen.open_preparation())
	assert_eq(flow.current_screen.brain_editor.block_count(), 1)

func test_tutorial_failure_does_not_unlock_campaign() -> void:
	var flow = _new_flow()
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

func test_reopened_checkpoint_restores_program_weapon_health_and_enemies() -> void:
	var flow = _prepared_flow()
	flow.session.activate_baton_checkpoint()
	flow.session.preparation_confirmed = false
	assert_true(flow.save_store.save_progress(flow.session))
	var path: String = flow.save_store.save_path
	flow.queue_free()
	await get_tree().process_frame
	var reopened = FlowScene.instantiate()
	reopened.configure_save_store(SaveStoreScript.new(path))
	add_child_autofree(reopened)
	assert_eq(reopened.save_status, "ok")
	assert_true(reopened.session.baton_checkpoint_active)
	assert_true(reopened.session.baton_checkpoint_intro_seen)
	assert_eq(reopened.current_screen.start_button.text, "Continuar")
	assert_true(reopened.show_campaign(true))
	var selection = reopened.current_screen
	assert_eq(selection.brain_editor.capture_snapshot().ram, "10/10 RAM")
	assert_true(selection.return_to_briefing(true))
	assert_true(reopened.show_laboratory())
	var mission = reopened.current_screen
	assert_true(mission.buneko.has_baton())
	assert_eq(mission.buneko.current_health(), 10)
	assert_eq(mission.level.living_enemy_count(), 3)
	assert_false(mission.milestone_overlay.visible)
	assert_eq(mission.buneko.position, Vector2(180, 594))
	reopened.queue_free()
	await get_tree().process_frame

func test_victory_reward_is_visible_and_not_paid_again_after_reopening() -> void:
	var flow = _prepared_flow()
	flow.session.activate_baton_checkpoint()
	flow.session.preparation_confirmed = true
	assert_true(flow.show_laboratory())
	var mission = flow.current_screen
	mission.buneko.position = mission.level.exit_rect().get_center()
	for frame in 10:
		await get_tree().physics_frame
		if mission.outcome == "escaped":
			break
	assert_eq(mission.outcome, "escaped")
	assert_true(mission.milestone_description.text.contains("+10 moedas"))
	assert_eq(flow.session.money, 10)
	var path: String = flow.save_store.save_path
	flow.queue_free()
	await get_tree().process_frame
	var reopened = FlowScene.instantiate()
	reopened.configure_save_store(SaveStoreScript.new(path))
	add_child_autofree(reopened)
	assert_eq(reopened.save_status, "ok")
	assert_eq(reopened.session.money, 10)
	assert_true(reopened.show_campaign())
	assert_eq(reopened.current_screen.balance_label.text, "Saldo: 10 moedas")
	assert_true(reopened.show_laboratory())
	var repeated = reopened.current_screen
	repeated.buneko.position = repeated.level.exit_rect().get_center()
	for frame in 10:
		await get_tree().physics_frame
		if repeated.outcome == "escaped":
			break
	assert_eq(repeated.outcome, "escaped")
	assert_true(repeated.milestone_description.text.contains("ja recebida"))
	assert_eq(reopened.session.money, 10)
	reopened.queue_free()
	await get_tree().process_frame

func test_draft_edit_is_saved_before_leaving_editor() -> void:
	var flow = _prepared_flow()
	assert_true(flow.show_campaign(true))
	var selection = flow.current_screen
	selection.brain_editor.select_block("stairs")
	assert_true(selection.brain_editor.move_selected_block(Vector2(600, 300)))
	var path: String = flow.save_store.save_path
	flow.queue_free()
	await get_tree().process_frame
	var reopened = FlowScene.instantiate()
	reopened.configure_save_store(SaveStoreScript.new(path))
	add_child_autofree(reopened)
	assert_eq(reopened.save_status, "ok")
	assert_eq(reopened.session.graph_state.blocks["stairs"].position, Vector2(600, 300))
	assert_false(reopened.session.preparation_confirmed)
	reopened.queue_free()
	await get_tree().process_frame

func test_new_game_requires_confirmation_and_replaces_saved_progress() -> void:
	var flow = _prepared_flow()
	flow.show_menu()
	var menu = flow.current_screen
	assert_eq(menu.start_button.text, "Continuar")
	assert_true(menu.new_game_button.visible)
	assert_true(flow.session.tutorial_completed)
	assert_true(FileAccess.file_exists(flow.save_store.save_path))
	menu.new_game_dialog.confirmed.emit()
	await get_tree().process_frame
	assert_true(flow.current_screen is TutorialScript)
	assert_false(flow.session.tutorial_completed)
	var restored: Dictionary = SaveStoreScript.new(flow.save_store.save_path).load_progress()
	assert_eq(restored["status"], "ok")
	assert_false(restored["session"].tutorial_completed)

func test_invalid_save_disables_continue_until_explicit_new_game() -> void:
	var flow = _new_flow()
	var file := FileAccess.open(flow.save_store.save_path, FileAccess.WRITE)
	file.store_string("broken")
	file.close()
	add_child_autofree(flow)
	var menu = flow.current_screen
	assert_eq(flow.save_status, "invalid")
	assert_true(menu.start_button.disabled)
	assert_true(menu.new_game_button.visible)
	assert_eq(FileAccess.get_file_as_string(flow.save_store.save_path), "broken")
	menu.new_game_dialog.confirmed.emit()
	await get_tree().process_frame
	assert_true(flow.current_screen is TutorialScript)
	assert_eq(SaveStoreScript.new(flow.save_store.save_path).load_progress()["status"], "ok")

func test_failed_save_is_reported_while_editing_and_on_victory() -> void:
	var flow = _prepared_flow()
	flow.save_store.blocked = true
	assert_true(flow.show_campaign(true), "Selection opens")
	var selection = flow.current_screen
	selection.brain_editor.select_block("stairs")
	assert_true(selection.brain_editor.move_selected_block(Vector2(600, 310)), "Draft moves")
	assert_true(selection.status_label.text.contains("Nao foi possivel salvar"), "Editor shows save failure: %s" % selection.status_label.text)
	flow.save_store.blocked = false
	assert_true(selection.return_to_briefing(true), "Edited program confirms")
	flow.save_store.blocked = true
	assert_true(flow.show_laboratory(), "Mission opens")
	var mission = flow.current_screen
	mission.buneko.position = mission.level.exit_rect().get_center()
	for frame in 10:
		await get_tree().physics_frame
		if mission.outcome == "escaped":
			break
	assert_eq(mission.outcome, "escaped", "Teleport reaches exit")
	assert_true(mission.milestone_description.text.contains("Nao foi possivel salvar"), "Victory shows save failure: %s" % mission.milestone_description.text)
	flow.queue_free()
	await get_tree().process_frame
