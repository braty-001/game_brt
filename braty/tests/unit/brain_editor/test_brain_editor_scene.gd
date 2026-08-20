extends GutTest

const BlockKind = preload("res://src/programming/domain/block_kind.gd")
const ConditionCatalogScript = preload("res://src/programming/domain/condition_catalog.gd")
const TutorialReferenceProgramScript = preload("res://src/tutorial/tutorial_reference_program.gd")

func test_brain_editor_scene_instantiates_with_main_regions() -> void:
	var editor = await _ready_editor()

	assert_not_null(editor.palette)
	assert_not_null(editor.workspace)
	assert_not_null(editor.ram_label)
	assert_not_null(editor.validation_label)
	assert_not_null(editor.start_button)
	assert_eq(editor.palette.item_buttons.size(), 6)
	assert_not_null(editor.editor_header)
	assert_not_null(editor.inspector_panel)
	assert_not_null(editor.example_selector)
	assert_not_null(editor.reset_brain_button)

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

	assert_eq(editor.ram_label.text, "3/5 RAM")
	assert_eq(editor.editor_header.ram_label.text, "3/5 RAM")
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
	assert_eq(editor.block_nodes[if_block.block_id]._port_buttons["true"].text, "+ Sim  ●")
	assert_eq(editor.block_nodes[if_block.block_id]._port_buttons["false"].text, "- Nao  ●")
	assert_true(editor.block_nodes[if_block.block_id]._port_buttons["true"].tooltip_text.contains("positivo"))
	assert_true(editor.block_nodes[if_block.block_id]._port_buttons["false"].tooltip_text.contains("negativo"))

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
	var has_exit_if := false
	for block in editor.graph_state.blocks.values():
		if block.kind == BlockKind.Value.IF and block.condition.query == ConditionCatalogScript.Query.GAP_AHEAD:
			has_exit_if = true
	assert_true(has_exit_if)

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

func _ready_editor():
	var scene: PackedScene = load("res://scenes/brain_editor/brain_editor.tscn")
	var editor = scene.instantiate()
	add_child_autofree(editor)
	await get_tree().process_frame
	return editor
