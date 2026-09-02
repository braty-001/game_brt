extends GutTest

const BlockKind = preload("res://src/programming/domain/block_kind.gd")
const ConditionCatalogScript = preload("res://src/programming/domain/condition_catalog.gd")
const EditorBlockStateScript = preload("res://src/brain_editor/editor_block_state.gd")
const EditorGraphStateScript = preload("res://src/brain_editor/editor_graph_state.gd")
const MovementPaceScript = preload("res://src/programming/domain/movement_pace.gd")
const Tokens = preload("res://src/ui/design_tokens.gd")
const TutorialReferenceProgramScript = preload("res://src/tutorial/tutorial_reference_program.gd")

func test_brain_editor_scene_instantiates_with_main_regions() -> void:
	var editor = await _ready_editor()

	assert_not_null(editor.palette)
	assert_not_null(editor.workspace)
	assert_not_null(editor.ram_label)
	assert_not_null(editor.validation_label)
	assert_not_null(editor.start_button)
	assert_eq(editor.palette.item_buttons.size(), 5)
	assert_not_null(editor.editor_header)
	assert_not_null(editor.inspector_panel)
	assert_not_null(editor.example_selector)
	assert_not_null(editor.reset_brain_button)
	assert_not_null(editor.organize_button)
	assert_not_null(editor.drawer_button)
	assert_not_null(editor.pseudocode_button)
	assert_not_null(editor.block_drawer)
	assert_not_null(editor.pseudocode_panel)
	assert_not_null(editor.canvas_toolbar)
	assert_not_null(editor.canvas_primary_tools)
	assert_not_null(editor.canvas_navigation_tools)

func test_canvas_toolbar_groups_clear_creation_and_navigation_actions() -> void:
	var editor = await _ready_editor()

	assert_eq(editor.canvas_toolbar.name, "CanvasToolbar")
	assert_eq(editor.drawer_button.text, "Blocos")
	assert_eq(editor.organize_button.text, "Organizar")
	assert_eq(editor.pseudocode_button.text, "Código")
	assert_eq(editor.pan_button.text, "Mover")
	assert_eq(editor.zoom_out_button.text, "-")
	assert_eq(editor.zoom_label_button.text, "100%")
	assert_eq(editor.zoom_in_button.text, "+")
	assert_eq(editor.center_view_button.text, "Centralizar")
	assert_eq(editor.drawer_button.get_parent(), editor.canvas_primary_tools)
	assert_eq(editor.zoom_in_button.get_parent(), editor.canvas_navigation_tools)

func test_canvas_toolbar_fits_the_workspace_width_at_960_target() -> void:
	var editor = await _ready_editor()
	var available_width := 960.0 - 28.0 - 195.0 - 10.0

	assert_lte(editor.canvas_toolbar.get_combined_minimum_size().x, available_width)

func test_create_block_adds_visual_node_and_graph_block() -> void:
	var editor = await _ready_editor()

	var block_node = editor.create_block(BlockKind.Value.WALK, Vector2(320, 120))

	assert_not_null(block_node)
	assert_eq(editor.graph_state.blocks.size(), 1)
	assert_eq(editor.block_nodes.size(), 1)
	assert_eq(block_node.position, Vector2(320, 120))
	assert_eq(editor.ram_label.text, "1/5 RAM")
	assert_eq(editor.validation_label.text, "Programa pronto para executar")
	assert_false(editor.start_button.disabled)

func test_palette_click_creates_block() -> void:
	var editor = await _ready_editor()
	var first_item = editor.palette.item_buttons[0]

	first_item.pressed.emit()

	assert_eq(editor.graph_state.blocks.size(), 1)
	assert_eq(editor.block_nodes.size(), 1)

func test_drawer_opens_with_all_blocks_without_scroll() -> void:
	var editor = await _ready_editor()

	assert_false(editor.block_drawer.visible)
	editor.drawer_button.button_pressed = true
	await get_tree().process_frame

	assert_true(editor.block_drawer.visible)
	assert_true(editor.canvas_toolbar.visible)
	assert_eq(editor.palette.item_buttons.size(), 5)
	assert_null(editor.block_drawer.find_child("PaletteScroll", true, false))
	assert_lte(
		editor.block_drawer.position.y + editor.block_drawer.size.y,
		editor.workspace.size.y
	)
	var close_button: Button = editor.block_drawer.find_child("CloseButton", true, false)
	assert_not_null(close_button)
	close_button.pressed.emit()
	assert_false(editor.block_drawer.visible)
	assert_true(editor.canvas_toolbar.visible)
	assert_false(editor.drawer_button.button_pressed)

func test_removing_while_body_leaves_it_empty_and_clicking_output_opens_drawer() -> void:
	var editor = await _ready_editor()
	editor.load_tutorial_example(TutorialReferenceProgramScript.Example.WHILE_PATH_CLEAR)
	var while_node = editor.block_nodes[editor.graph_state.start_block_id]
	var removed_block_id := _target_for_output(editor, while_node.block_id, "body")
	var initial_block_count: int = editor.graph_state.blocks.size()

	editor.select_block(removed_block_id)
	assert_true(editor.remove_selected_block())
	await get_tree().process_frame

	assert_eq(editor.graph_state.blocks.size(), initial_block_count - 1)
	assert_false(editor.graph_state.blocks.has(removed_block_id))
	assert_eq(_target_for_output(editor, while_node.block_id, "body"), "")
	assert_eq(editor.pending_connection_from_block_id, "")
	assert_false(editor.block_drawer.visible)

	while_node._port_buttons["body"].pressed.emit()

	assert_true(editor.block_drawer.visible)
	assert_eq(editor.pending_connection_from_block_id, while_node.block_id)
	assert_eq(editor.pending_connection_from_port, "body")
	editor.palette.item_for_kind(BlockKind.Value.JUMP).pressed.emit()

	var replacement_id := _target_for_output(editor, while_node.block_id, "body")
	assert_false(replacement_id.is_empty())
	assert_eq(editor.graph_state.blocks[replacement_id].kind, BlockKind.Value.JUMP)
	assert_false(editor.block_drawer.visible)

func test_clicking_an_occupied_output_does_not_open_the_drawer() -> void:
	var editor = await _ready_editor()
	editor.load_tutorial_example(TutorialReferenceProgramScript.Example.WHILE_PATH_CLEAR)
	var while_node = editor.block_nodes[editor.graph_state.start_block_id]

	while_node._port_buttons["body"].pressed.emit()

	assert_false(editor.block_drawer.visible)
	assert_eq(editor.pending_connection_from_block_id, "")
	assert_true(editor.connection_feedback_label.text.contains("ja esta conectada"))

func test_drawer_click_inserts_and_connects_to_the_selected_output() -> void:
	var editor = await _ready_editor()
	var walk = editor.create_block(BlockKind.Value.WALK, Vector2(100, 100))

	editor.start_connection(walk.block_id, "next")
	editor._on_drawer_block_requested(BlockKind.Value.JUMP)

	assert_eq(editor.graph_state.blocks.size(), 2)
	assert_eq(editor.graph_state.connections.size(), 1)
	assert_eq(editor.ram_label.text, "2/5 RAM")
	assert_eq(editor.connection_feedback_label.text, "Bloco inserido e conectado")
	assert_false(editor.block_drawer.visible)

func test_drawer_explains_that_a_while_needs_a_selected_output() -> void:
	var editor = await _ready_editor()
	var while_node = editor.create_block(BlockKind.Value.WHILE, Vector2(100, 100))

	editor._on_drawer_block_requested(BlockKind.Value.JUMP)

	assert_eq(editor.graph_state.blocks.size(), 1)
	assert_true(editor.block_drawer.insertion_label.text.contains("Escolha uma saida"))
	editor.start_connection(while_node.block_id, "body")
	assert_eq(editor.block_drawer.insertion_label.text, "Inserir em: WHILE / Repetir")

func test_move_selected_block_updates_visual_and_graph_state() -> void:
	var editor = await _ready_editor()
	var block_node = editor.create_block(BlockKind.Value.WALK, Vector2(100, 100))

	assert_true(editor.move_selected_block(Vector2(240, 160)))

	assert_eq(block_node.position, Vector2(240, 160))
	assert_eq(editor.graph_state.blocks[block_node.block_id].position, Vector2(240, 160))

func test_block_drag_event_updates_graph_state() -> void:
	var editor = await _ready_editor()
	var block_node = editor.create_block(BlockKind.Value.WALK, Vector2(100, 100))

	block_node.moved.emit(block_node.block_id, Vector2(180, 140))

	assert_eq(editor.graph_state.blocks[block_node.block_id].position, Vector2(180, 140))

func test_remove_selected_block_updates_graph_and_validation() -> void:
	var editor = await _ready_editor()
	editor.create_block(BlockKind.Value.WALK)

	assert_true(editor.remove_selected_block())
	await get_tree().process_frame

	assert_eq(editor.graph_state.blocks.size(), 0)
	assert_eq(editor.block_nodes.size(), 0)
	assert_eq(editor.ram_label.text, "0/5 RAM")
	assert_true(editor.start_button.disabled)

func test_connecting_port_to_block_creates_graph_connection_and_line() -> void:
	var editor = await _ready_editor()
	var walk = editor.create_block(BlockKind.Value.WALK, Vector2(100, 100))
	var jump = editor.create_block(BlockKind.Value.JUMP, Vector2(320, 100))

	editor.start_connection(walk.block_id, "next")
	assert_true(editor.complete_connection(jump.block_id))

	assert_eq(editor.graph_state.connections.size(), 1)
	assert_eq(_connection_visual_count(editor), 2)
	assert_eq(editor.ram_label.text, "2/5 RAM")

func test_port_buttons_create_connection_and_line() -> void:
	var editor = await _ready_editor()
	var walk = editor.create_block(BlockKind.Value.WALK, Vector2(100, 100))
	var jump = editor.create_block(BlockKind.Value.JUMP, Vector2(320, 100))

	walk._port_buttons["next"].pressed.emit()
	jump._input_button.pressed.emit()

	assert_eq(editor.graph_state.connections.size(), 1)
	assert_eq(_connection_visual_count(editor), 2)
	assert_eq(_connection_visual_count(editor), 2)

func test_removing_connected_block_removes_its_connection_visuals_immediately() -> void:
	var editor = await _ready_editor()
	var walk = editor.create_block(BlockKind.Value.WALK, Vector2(100, 100))
	var jump = editor.create_block(BlockKind.Value.JUMP, Vector2(320, 100))

	editor.start_connection(walk.block_id, "next")
	assert_true(editor.complete_connection(jump.block_id))
	assert_eq(_connection_visual_count(editor), 2)

	editor.select_block(walk.block_id)
	assert_true(editor.remove_selected_block())
	await get_tree().process_frame

	assert_eq(editor.graph_state.connections.size(), 0)
	assert_eq(_connection_visual_count(editor), 0)

func test_remove_button_returns_ram_for_a_connected_block() -> void:
	var editor = await _ready_editor()
	editor.load_tutorial_example(TutorialReferenceProgramScript.Example.WHILE_PATH_CLEAR)
	var jump_node = _block_node_for_kind(editor, BlockKind.Value.JUMP)

	assert_eq(editor.ram_label.text, "5/5 RAM")
	var header = jump_node.get_node("Content").get_child(0)
	var remove_button: Button = header.get_child(2)
	remove_button.pressed.emit()
	await get_tree().process_frame

	assert_eq(editor.ram_label.text, "2/5 RAM")
	assert_eq(editor.editor_header.ram_label.text, "2/5 RAM")
	assert_false(is_instance_valid(jump_node))

func test_removing_block_also_clears_an_untracked_connection_visual() -> void:
	var editor = await _ready_editor()
	var walk = editor.create_block(BlockKind.Value.WALK, Vector2(100, 100))
	var stale_connection := Node2D.new()
	stale_connection.name = "Connection"
	editor.workspace.add_child(stale_connection)

	editor.select_block(walk.block_id)
	assert_true(editor.remove_selected_block())
	await get_tree().process_frame

	assert_eq(_connection_visual_count(editor), 0)

func test_removing_block_reuses_the_next_default_spawn_position() -> void:
	var editor = await _ready_editor()
	var first_walk = editor.create_block(BlockKind.Value.WALK)
	var first_position: Vector2 = first_walk.position

	assert_true(editor.remove_selected_block())
	await get_tree().process_frame
	var second_walk = editor.create_block(BlockKind.Value.WALK)

	assert_eq(second_walk.position, first_position)

func test_selecting_control_block_and_applying_condition_updates_validation() -> void:
	var editor = await _ready_editor()
	var if_block = editor.create_block(BlockKind.Value.IF, Vector2(100, 100))

	assert_true(editor.start_button.disabled)
	assert_false(editor.parameter_panel.condition_dropdown.disabled)
	assert_false(editor.apply_condition_to_selected(
		ConditionCatalogScript.Modality.HEARING,
		ConditionCatalogScript.Query.GAP_AHEAD
	))
	assert_true(editor.apply_condition_to_selected(
		ConditionCatalogScript.Modality.VISION,
		ConditionCatalogScript.Query.GAP_AHEAD
	))

	assert_eq(editor.graph_state.blocks[if_block.block_id].condition.query, ConditionCatalogScript.Query.GAP_AHEAD)
	assert_eq(editor.validation_label.text, "Programa pronto para executar")
	assert_true(editor.block_nodes[if_block.block_id]._parameter_label.text.contains("Se buraco a frente?"))
	assert_eq(editor.block_nodes[if_block.block_id]._port_buttons["true"].text, "✓  ●")
	assert_eq(editor.block_nodes[if_block.block_id]._port_buttons["false"].text, "×  ●")
	assert_true(editor.block_nodes[if_block.block_id]._port_buttons["true"].tooltip_text.contains("positivo"))
	assert_true(editor.block_nodes[if_block.block_id]._port_buttons["false"].tooltip_text.contains("negativo"))

func test_selecting_walk_and_applying_fast_pace_updates_program_and_label() -> void:
	var editor = await _ready_editor()
	var walk = editor.create_block(BlockKind.Value.WALK)

	assert_true(editor.apply_movement_pace_to_selected(MovementPaceScript.Value.FAST))

	assert_eq(
		MovementPaceScript.from_parameters(editor.current_program().blocks[walk.block_id].parameters),
		MovementPaceScript.Value.FAST
	)
	assert_true(editor.block_nodes[walk.block_id]._parameter_label.text.contains("rapido"))

func test_external_attempt_runner_emits_request_without_starting_isolated_runtime() -> void:
	var editor = await _ready_editor()
	editor.create_block(BlockKind.Value.WALK)
	editor.set_external_attempt_runner(true)
	watch_signals(editor)

	editor.start_button.pressed.emit()

	assert_signal_emitted(editor, "attempt_requested")
	assert_eq(editor.state_label.text, "Editando")

func test_invalid_control_block_is_highlighted_with_specific_message() -> void:
	var editor = await _ready_editor()
	var while_node = editor.create_block(BlockKind.Value.WHILE)

	assert_true(while_node.invalid_state)
	assert_true(editor.validation_label.text.contains("WHILE precisa de uma condicao"))

func test_tutorial_example_builds_compact_valid_program() -> void:
	var editor = await _ready_editor()

	editor.load_tutorial_example()

	assert_eq(editor.graph_state.blocks.size(), 5)
	assert_eq(editor.graph_state.connections.size(), 4)
	assert_eq(editor.ram_label.text, "5/5 RAM")
	assert_false(editor.start_button.disabled)
	assert_eq(editor.validation_label.text, "Programa pronto para executar")
	assert_eq(editor.palette.item_buttons[0].custom_minimum_size.y, 34.0)
	for block_node in editor.block_nodes.values():
		if block_node.block_kind == BlockKind.Value.WHILE:
			assert_eq(block_node.custom_minimum_size, Vector2(176, 90))
		elif block_node.block_kind == BlockKind.Value.IF:
			assert_eq(block_node.custom_minimum_size, Vector2(184, 94))
		else:
			assert_eq(block_node.custom_minimum_size, Vector2(154, 76))

func test_tutorial_while_example_builds_compact_valid_program() -> void:
	var editor = await _ready_editor()

	editor.load_tutorial_example(TutorialReferenceProgramScript.Example.WHILE_PATH_CLEAR)

	assert_eq(editor.graph_state.blocks.size(), 5)
	assert_eq(editor.graph_state.connections.size(), 4)
	assert_eq(editor.ram_label.text, "5/5 RAM")
	assert_false(editor.start_button.disabled)
	assert_eq(editor.validation_label.text, "Programa pronto para executar")
	var start_block = editor.graph_state.blocks[editor.graph_state.start_block_id]
	assert_eq(start_block.kind, BlockKind.Value.WHILE)
	assert_eq(start_block.condition.query, ConditionCatalogScript.Query.PATH_CLEAR_AHEAD)
	assert_true(editor.block_nodes[start_block.id]._parameter_label.text.contains("Enquanto caminho livre a frente?"))
	for block in editor.graph_state.blocks.values():
		assert_ne(block.kind, BlockKind.Value.IF)

func test_example_selector_loads_while_example() -> void:
	var editor = await _ready_editor()

	editor.example_selector.select(1)
	editor.example_button.pressed.emit()

	var start_block = editor.graph_state.blocks[editor.graph_state.start_block_id]
	assert_eq(start_block.kind, BlockKind.Value.WHILE)
	assert_eq(start_block.condition.query, ConditionCatalogScript.Query.PATH_CLEAR_AHEAD)
	assert_eq(editor.ram_label.text, "5/5 RAM")

func test_reset_brain_button_clears_blocks_connections_and_ram() -> void:
	var editor = await _ready_editor()
	editor.load_tutorial_example(TutorialReferenceProgramScript.Example.WHILE_PATH_CLEAR)

	editor.reset_brain_button.pressed.emit()

	assert_eq(editor.graph_state.blocks.size(), 0)
	assert_eq(editor.graph_state.connections.size(), 0)
	assert_eq(editor.block_nodes.size(), 0)
	assert_eq(editor.ram_label.text, "0/5 RAM")
	assert_true(editor.start_button.disabled)
	assert_eq(editor.connection_feedback_label.text, "Cerebro zerado")

func test_loading_a_graph_stops_observing_the_previous_graph() -> void:
	var editor = await _ready_editor()
	editor.create_block(BlockKind.Value.WALK)
	var previous_graph = editor.graph_state
	var replacement_graph = EditorGraphStateScript.new()
	replacement_graph.add_block(EditorBlockStateScript.new("jump", BlockKind.Value.JUMP))
	replacement_graph.set_start_block("jump")

	assert_true(editor.load_graph_state(replacement_graph))
	previous_graph.add_block(EditorBlockStateScript.new("walk_2", BlockKind.Value.WALK))

	assert_eq(editor.graph_state, replacement_graph)
	assert_eq(editor.ram_label.text, "1/5 RAM")
	assert_true(editor.connection_feedback_label.text.contains("Programa restaurado"))

func test_organize_button_repositions_blocks_without_changing_the_program() -> void:
	var editor = await _ready_editor()
	editor.load_tutorial_example(TutorialReferenceProgramScript.Example.WHILE_PATH_CLEAR)
	var initial_connections: Array = editor.graph_state.connections.duplicate()
	var initial_ram: String = editor.ram_label.text
	var initial_visual_count := _connection_visual_count(editor)

	editor.organize_button.pressed.emit()

	assert_eq(editor.graph_state.connections.size(), initial_connections.size())
	assert_eq(editor.ram_label.text, initial_ram)
	assert_eq(editor.validation_label.text, "Programa pronto para executar")
	assert_eq(editor.graph_state.blocks[editor.graph_state.start_block_id].position, Vector2(205, 105))
	assert_eq(_connection_visual_count(editor), initial_visual_count)

func test_zoom_buttons_change_only_the_viewport() -> void:
	var editor = await _ready_editor()
	var walk = editor.create_block(BlockKind.Value.WALK, Vector2(100, 100))
	var initial_position: Vector2 = editor.graph_state.blocks[walk.block_id].position

	editor.zoom_in_button.pressed.emit()
	editor.zoom_in_button.pressed.emit()

	assert_eq(editor.zoom_label_button.text, "140%")
	assert_eq(editor.workspace.canvas.scale, Vector2(1.4, 1.4))
	assert_eq(editor.workspace.graph_to_viewport(initial_position), initial_position * 1.4)
	assert_eq(editor.workspace.viewport_to_graph(initial_position * 1.4), initial_position)
	assert_eq(editor.workspace.connection_stroke_width(), 5.6)
	assert_eq(editor.workspace.connection_arrow_length(), 18.2)
	assert_eq(editor.graph_state.blocks[walk.block_id].position, initial_position)
	editor.center_view_button.pressed.emit()
	assert_eq(editor.zoom_label_button.text, "100%")

func test_pseudocode_panel_reads_the_current_graph_without_editing_it() -> void:
	var editor = await _ready_editor()
	editor.load_tutorial_example(TutorialReferenceProgramScript.Example.WHILE_PATH_CLEAR)
	var initial_ram: String = editor.ram_label.text

	editor.pseudocode_button.pressed.emit()

	assert_true(editor.pseudocode_panel.visible)
	assert_true(editor.pseudocode_panel.text_label.text.contains("ENQUANTO"))
	assert_eq(editor.pseudocode_panel.text_label.get_theme_color("font_readonly_color"), Tokens.TEXT)
	assert_eq(editor.ram_label.text, initial_ram)

func test_runtime_buttons_drive_runtime_state() -> void:
	var editor = await _ready_editor()
	editor.create_block(BlockKind.Value.WALK, Vector2(100, 100))

	assert_false(editor.start_button.disabled)
	editor.start_button.pressed.emit()
	assert_eq(editor.state_label.text, "Executando")
	assert_false(editor.pause_button.disabled)

	editor.pause_button.pressed.emit()
	assert_eq(editor.state_label.text, "Pausado")
	assert_false(editor.resume_button.disabled)

	editor.resume_button.pressed.emit()
	assert_eq(editor.state_label.text, "Executando")

	editor.stop_button.pressed.emit()
	assert_eq(editor.state_label.text, "Parado")
	assert_false(editor.start_button.disabled)

func test_block_node_scene_instantiates() -> void:
	var scene: PackedScene = load("res://scenes/brain_editor/block_node.tscn")

	var instance = scene.instantiate()

	assert_not_null(instance)
	instance.free()

func _connection_visual_count(editor) -> int:
	return editor.workspace.visible_connection_count()

func _block_node_for_kind(editor, kind: int):
	for block_node in editor.block_nodes.values():
		if block_node.block_kind == kind:
			return block_node
	return null

func _target_for_output(editor, block_id: String, port: String) -> String:
	for connection in editor.graph_state.connections:
		if connection.from_block_id == block_id and connection.from_port == port:
			return connection.to_block_id
	return ""

func _ready_editor():
	var scene: PackedScene = load("res://scenes/brain_editor/brain_editor.tscn")
	var editor = scene.instantiate()
	add_child_autofree(editor)
	await get_tree().process_frame
	return editor
