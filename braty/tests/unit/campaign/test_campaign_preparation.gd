extends GutTest

const Session = preload("res://src/campaign/campaign_session.gd")
const Catalog = preload("res://src/campaign/campaign_mission_catalog.gd")
const SelectionScene = preload("res://scenes/campaign/campaign_selection.tscn")
const Importer = preload("res://src/brain_editor/program_graph_importer.gd")
const ReferenceProgram = preload("res://src/tutorial/tutorial_reference_program.gd")

func test_campaign_is_locked_without_tutorial_and_unknown_mission_is_rejected() -> void:
	var session = Session.new()
	assert_false(session.can_prepare_mission(Catalog.LABORATORY_ID))
	var selection = _selection(session)
	await get_tree().process_frame
	assert_true(selection.prepare_button.disabled)
	assert_false(selection.open_preparation())
	session.complete_tutorial(BaseBunekoParts.complete_assembly(), null)
	assert_true(session.can_prepare_mission(Catalog.LABORATORY_ID))
	assert_false(session.can_prepare_mission("unknown"))

func test_briefing_contains_approximate_intel_and_checkpoint_notice() -> void:
	var data := Catalog.laboratory_briefing()
	assert_string_contains(data["checkpoint"], "pausa")
	assert_string_contains(data["checkpoint"], "checkpoint")
	assert_string_contains(data["objective"], "nao e necessario")
	assert_string_contains(data["reward"], "primeira conclusao")
	var regions := Catalog.approximate_enemy_regions()
	assert_eq(regions.size(), 3)
	var ground_count := 0
	for region in regions:
		assert_gt(region.size.x, 0.0)
		assert_gt(region.size.y, 0.0)
		if region.get_center().y > 0.5:
			ground_count += 1
	assert_eq(ground_count, 1)

func test_preparation_preserves_parameters_conditions_positions_and_assembly() -> void:
	var session = _unlocked_session()
	var assembly = session.assembly
	var original_graph = session.graph_state
	var original_id: String = original_graph.start_block_id
	var original_condition = original_graph.blocks[original_id].condition
	var selection = _selection(session)
	await get_tree().process_frame
	selection.prepare_button.pressed.emit()
	var editor = selection.brain_editor
	assert_eq(editor.ram_capacity, 10)
	assert_string_contains(selection.status_label.text, "5/10 RAM")
	assert_eq(editor.block_count(), original_graph.blocks.size())
	assert_true(editor.example_button.visible)
	assert_eq(editor.condition_selector.available_options().size(), 4)
	assert_null(editor.condition_selector.create_condition(ConditionCatalog.Modality.HEARING, ConditionCatalog.Query.SIGNAL_HEARD))
	assert_not_null(editor.condition_selector.create_condition(ConditionCatalog.Modality.VISION, ConditionCatalog.Query.STEP_AHEAD))
	editor.select_block(original_id)
	assert_true(editor.move_selected_block(Vector2(350, 110)))
	var program_before = editor.current_program()
	editor.start_button.pressed.emit()
	await get_tree().process_frame
	assert_null(selection.brain_editor)
	assert_true(session.preparation_confirmed)
	assert_same(session.assembly, assembly)
	assert_true(selection.open_preparation())
	var restored = selection.brain_editor.capture_snapshot()
	assert_eq(restored.graph_state.blocks[original_id].position, Vector2(350, 110))
	assert_eq(restored.graph_state.blocks[original_id].condition.query, original_condition.query)
	assert_eq(restored.program.connections.size(), program_before.connections.size())
	for block_id in program_before.blocks:
		assert_eq(restored.program.blocks[block_id].parameters, program_before.blocks[block_id].parameters)

func test_invalid_draft_survives_back_and_cannot_be_confirmed() -> void:
	var session = _unlocked_session()
	var selection = _selection(session)
	await get_tree().process_frame
	assert_true(selection.open_preparation())
	var editor = selection.brain_editor
	editor.reset_brain()
	assert_string_contains(selection.status_label.text, "0/10 RAM")
	assert_false(selection.return_to_briefing(true))
	assert_false(session.preparation_confirmed)
	var node = editor.create_block(ProgramBlockKind.Value.WHILE)
	var draft_id: String = node.block_id
	editor.back_button.pressed.emit()
	await get_tree().process_frame
	assert_null(selection.brain_editor)
	assert_true(selection.open_preparation())
	assert_eq(selection.brain_editor.block_count(), 1)
	assert_true(selection.brain_editor.graph_state.blocks.has(draft_id))
	assert_false(selection.brain_editor.capture_snapshot().is_valid)

func test_menu_request_keeps_in_progress_draft() -> void:
	var session = _unlocked_session()
	var selection = _selection(session)
	await get_tree().process_frame
	selection.open_preparation()
	selection.brain_editor.reset_brain()
	selection.brain_editor.create_block(ProgramBlockKind.Value.TURN)
	watch_signals(selection)
	selection.menu_button.pressed.emit()
	assert_signal_emitted(selection, "menu_requested")
	assert_eq(session.graph_state.blocks.size(), 1)
	assert_false(session.preparation_confirmed)

func test_briefing_and_preparation_fit_supported_viewports() -> void:
	for target in [Vector2i(960, 540), Vector2i(1440, 810), Vector2i(1600, 900)]:
		var viewport := SubViewport.new()
		viewport.size = target
		add_child_autofree(viewport)
		var selection = SelectionScene.instantiate()
		selection.configure_session(_unlocked_session())
		viewport.add_child(selection)
		for frame in 6:
			await get_tree().process_frame
		_assert_inside(selection.prepare_button, target)
		_assert_inside(selection.menu_button, target)
		_assert_inside(selection.get_node("Margin/Page/Briefing/Content/MapColumn/Minimap"), target)
		var details = selection.get_node("Margin/Page/Briefing/Content/DetailsScroll")
		_assert_inside(details, target)
		assert_true(selection.open_preparation())
		for frame in 6:
			await get_tree().process_frame
		_assert_inside(selection.brain_editor.start_button, target)
		_assert_inside(selection.brain_editor.back_button, target)
		_assert_inside(selection.menu_button, target)
		var editor = selection.brain_editor
		editor.drawer_button.button_pressed = true
		for frame in 6:
			await get_tree().process_frame
		var drawer_scroll: ScrollContainer = editor.block_drawer.get_parent()
		assert_true(drawer_scroll.is_visible_in_tree())
		assert_false(editor.workspace.is_ancestor_of(editor.block_drawer))
		_assert_inside(drawer_scroll, target)
		drawer_scroll.ensure_control_visible(editor.palette.item_for_kind(ProgramBlockKind.Value.WHILE))
		await get_tree().process_frame
		var item_rect: Rect2 = editor.palette.item_for_kind(ProgramBlockKind.Value.WHILE).get_global_rect()
		assert_true(drawer_scroll.get_global_rect().encloses(item_rect))
		editor.drawer_button.button_pressed = false
		editor.pseudocode_button.pressed.emit()
		for frame in 6:
			await get_tree().process_frame
		_assert_inside(editor.pseudocode_panel.get_parent(), target)

func _assert_inside(control: Control, target: Vector2i) -> void:
	var rect := control.get_global_rect()
	assert_gte(rect.position.x, 0.0)
	assert_gte(rect.position.y, 0.0)
	assert_lte(rect.end.x, float(target.x))
	assert_lte(rect.end.y, float(target.y), str(control.get_path()))

func _selection(session):
	var selection = SelectionScene.instantiate()
	selection.configure_session(session)
	add_child_autofree(selection)
	return selection

func _unlocked_session():
	var session = Session.new()
	var graph = Importer.new().import_program(ReferenceProgram.build_program())
	session.complete_tutorial(BaseBunekoParts.complete_assembly(), graph)
	return session
