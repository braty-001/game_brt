class_name BrainEditor
extends Control

const BlockFactoryScript = preload("res://src/brain_editor/block_factory.gd")
const BlockNodeScript = preload("res://src/brain_editor/block_node.gd")
const ActionDispatcherScript = preload("res://src/programming/runtime/action_dispatcher.gd")
const BrainEditorSnapshotScript = preload("res://src/brain_editor/brain_editor_snapshot.gd")
const ConditionSelectorScript = preload("res://src/brain_editor/condition_selector.gd")
const ConnectionControllerScript = preload("res://src/brain_editor/connection_controller.gd")
const EditorCommandControllerScript = preload("res://src/brain_editor/editor_command_controller.gd")
const EditorGraphStateScript = preload("res://src/brain_editor/editor_graph_state.gd")
const EditorLayoutControllerScript = preload("res://src/brain_editor/editor_layout_controller.gd")
const EditorViewScript = preload("res://src/brain_editor/brain_editor_view.gd")
const MovementPaceScript = preload("res://src/programming/domain/movement_pace.gd")
const ProgramGraphBuilderScript = preload("res://src/brain_editor/program_graph_builder.gd")
const ProgramGraphImporterScript = preload("res://src/brain_editor/program_graph_importer.gd")
const PseudocodePresenterScript = preload("res://src/brain_editor/pseudocode_presenter.gd")
const RamPanelScript = preload("res://src/brain_editor/ram_panel.gd")
const RuntimeStatePresenterScript = preload("res://src/brain_editor/runtime_state_presenter.gd")
const ProgramRuntimeScript = preload("res://src/programming/runtime/program_runtime.gd")
const RuntimeControlsScript = preload("res://src/brain_editor/runtime_controls.gd")
const SensorReaderScript = preload("res://src/programming/runtime/sensor_reader.gd")
const Tokens = preload("res://src/ui/design_tokens.gd")
const ValidationPanelScript = preload("res://src/brain_editor/validation_panel.gd")

const DEFAULT_SPAWN_POSITION := Vector2(230, 108)
const SPAWN_OFFSET := Vector2(24, 82)

signal attempt_requested
signal back_to_assembly_requested
signal summary_changed(ram: String, status: String, is_valid: bool)

var graph_state
var block_factory
var graph_builder
var graph_importer
var ram_panel
var validation_panel
var runtime_state_presenter
var connection_controller
var condition_selector
var command_controller
var layout_controller
var runtime
var runtime_controls
var pseudocode_presenter
var editor_view
var example_provider

var block_nodes: Dictionary = {}
var selected_block_id := ""
var pending_connection_from_block_id := ""
var pending_connection_from_port := ""
var next_spawn_position := DEFAULT_SPAWN_POSITION
var external_attempt_runner := false
var is_sync_suspended := false

var editor_header
var palette
var block_drawer
var pseudocode_panel
var canvas_toolbar: PanelContainer
var canvas_primary_tools: HBoxContainer
var canvas_navigation_tools: HBoxContainer
var workspace: Control
var inspector_panel: PanelContainer
var ram_label: Label
var validation_label: Label
var state_label: Label
var connection_feedback_label: Label
var parameter_panel
var start_button: Button
var pause_button: Button
var resume_button: Button
var stop_button: Button
var restart_button: Button
var organize_button: Button
var pan_button: Button
var zoom_out_button: Button
var zoom_label_button: Button
var zoom_in_button: Button
var center_view_button: Button
var drawer_button: Button
var pseudocode_button: Button
var back_button: Button
var example_selector: OptionButton
var example_button: Button
var reset_brain_button: Button

func _ready() -> void:
	_initialize_models()
	_ensure_ui()
	refresh_panels()

func set_external_attempt_runner(enabled: bool) -> void:
	external_attempt_runner = enabled

func configure_example_provider(provider) -> void:
	if workspace != null:
		return
	example_provider = provider

func configure_runtime(runtime_instance) -> void:
	if runtime_controls != null:
		return
	runtime = runtime_instance

func set_embedded_mode(enabled: bool) -> void:
	_ensure_ui()
	editor_header.visible = not enabled
	back_button.visible = enabled

func set_objective(text: String) -> void:
	_ensure_ui()
	editor_header.objective_label.text = text

func create_block(kind: int, block_position: Vector2 = Vector2.INF):
	_initialize_models()
	_ensure_ui()

	var spawn_position: Vector2 = block_position
	if spawn_position == Vector2.INF:
		spawn_position = next_spawn_position
		next_spawn_position += Vector2(24, 82)

	var result = command_controller.insert_block(kind, spawn_position)
	if not result.is_success:
		return null
	var block_state = result.value
	_refresh_next_spawn_position()
	select_block(block_state.id)
	_sync_editor_from_graph_state()
	return block_nodes.get(block_state.id)

func load_graph_state(saved_graph_state) -> bool:
	if saved_graph_state == null:
		return false

	_initialize_models()
	_ensure_ui()
	_clear_workspace_program()
	_replace_graph_state(saved_graph_state)
	selected_block_id = ""
	pending_connection_from_block_id = ""
	pending_connection_from_port = ""

	_reconcile_block_nodes()
	_refresh_next_spawn_position()
	_sync_editor_from_graph_state()
	if graph_state.blocks.is_empty():
		connection_feedback_label.text = "Adicione um bloco para comecar"
	else:
		connection_feedback_label.text = "Programa restaurado. Selecione um bloco para continuar editando."
	connection_feedback_label.add_theme_color_override("font_color", Tokens.TEXT_MUTED)
	return true

func select_block(block_id: String) -> void:
	if not pending_connection_from_block_id.is_empty() and pending_connection_from_block_id != block_id:
		complete_connection(block_id)
		return

	selected_block_id = block_id
	for node_id in block_nodes:
		block_nodes[node_id].set_selected(node_id == selected_block_id)
	_update_parameter_panel()

func apply_condition_to_selected(modality: int, query: int) -> bool:
	if selected_block_id.is_empty():
		return false

	var condition = condition_selector.create_condition(modality, query)
	if condition == null:
		return false
	var applied: bool = command_controller.set_condition(selected_block_id, condition).is_success
	if applied and block_nodes.has(selected_block_id):
		block_nodes[selected_block_id].refresh_from_state()
	_sync_editor_from_graph_state()
	return applied

func apply_movement_pace_to_selected(pace: int) -> bool:
	if selected_block_id.is_empty() or not MovementPaceScript.is_valid(pace):
		return false
	if not graph_state.blocks.has(selected_block_id):
		return false
	if graph_state.blocks[selected_block_id].kind != ProgramBlockKind.Value.WALK:
		return false

	var applied: bool = command_controller.set_parameter(
		selected_block_id,
		MovementPaceScript.PARAMETER_KEY,
		pace
	).is_success
	if applied and block_nodes.has(selected_block_id):
		block_nodes[selected_block_id].refresh_from_state()
	_sync_editor_from_graph_state()
	return applied

func start_connection(block_id: String, port: String) -> void:
	pending_connection_from_block_id = block_id
	pending_connection_from_port = port
	selected_block_id = block_id
	for node_id in block_nodes:
		block_nodes[node_id].set_compatible_target(node_id != block_id)
	connection_feedback_label.text = "Selecione a entrada de outro bloco"
	connection_feedback_label.add_theme_color_override("font_color", Tokens.TEAL)
	if block_drawer != null and graph_state.blocks.has(block_id):
		block_drawer.show_insertion_target(block_factory.label_for_kind(graph_state.blocks[block_id].kind), _port_label_for_drawer(port))

func complete_connection(target_block_id: String) -> bool:
	if pending_connection_from_block_id.is_empty():
		return false

	var connection_result = command_controller.connect_blocks(
		pending_connection_from_block_id,
		pending_connection_from_port,
		target_block_id
	)
	var connected: bool = connection_result.is_success
	pending_connection_from_block_id = ""
	pending_connection_from_port = ""
	if block_drawer != null:
		block_drawer.show_insertion_hint()
	for node_id in block_nodes:
		block_nodes[node_id].set_compatible_target(false)
	connection_feedback_label.text = "Conexao criada" if connected else "Esta conexao nao e compativel"
	connection_feedback_label.add_theme_color_override("font_color", Tokens.SUCCESS if connected else Tokens.ERROR)
	selected_block_id = target_block_id
	select_block(target_block_id)
	_sync_editor_from_graph_state()
	return connected

func move_selected_block(new_position: Vector2) -> bool:
	if selected_block_id.is_empty():
		return false

	var moved: bool = command_controller.move_block(selected_block_id, new_position).is_success
	if moved and block_nodes.has(selected_block_id):
		block_nodes[selected_block_id].move_to(new_position)
	_sync_editor_from_graph_state()
	return moved

func remove_selected_block() -> bool:
	if selected_block_id.is_empty():
		return false
	return _remove_block(selected_block_id)

func current_program():
	return graph_builder.build(graph_state)

func block_count() -> int:
	return graph_state.blocks.size()

func connection_count() -> int:
	return graph_state.connections.size()

func visual_block_count() -> int:
	return block_nodes.size()

func selected_block() -> String:
	return selected_block_id

func capture_snapshot():
	_initialize_models()
	var program = current_program()
	var ram_summary: Dictionary = ram_panel.summary_for_program(program)
	var validation_summary: Dictionary = validation_panel.summary_for_program(program)
	return BrainEditorSnapshotScript.new(
		graph_state,
		program,
		ram_summary["label"],
		runtime_state_presenter.label_for_state(runtime.state, runtime.failure_reason),
		validation_summary["is_valid"]
	)

func load_example(example_id := -1) -> bool:
	if example_provider == null:
		return false
	if example_id < 0:
		example_id = example_provider.default_example_id()
	var example_program = example_provider.build_program(example_id)
	if example_program == null:
		return false
	var example_graph = graph_importer.import_program(example_program)
	var positions: Dictionary = layout_controller.positions_for(example_graph)
	for block_id in positions:
		example_graph.move_block(block_id, positions[block_id])

	_reset_graph_state()
	load_graph_state(example_graph)
	select_block(graph_state.start_block_id)

	connection_feedback_label.text = "Exemplo carregado. Mova os blocos e observe as conexoes."
	connection_feedback_label.add_theme_color_override("font_color", Tokens.TEXT_MUTED)
	return true

func reset_brain() -> void:
	_reset_graph_state()
	connection_feedback_label.text = "Cerebro zerado"
	connection_feedback_label.add_theme_color_override("font_color", Tokens.TEXT_MUTED)
	refresh_panels()

func refresh_panels() -> void:
	_initialize_models()
	if ram_label == null:
		return

	var program = current_program()
	var ram_summary: Dictionary = ram_panel.summary_for_program(program)
	var validation_summary: Dictionary = validation_panel.summary_for_program(program)
	var runtime_state: int = runtime.state
	var runtime_failure_reason: int = runtime.failure_reason
	var control_state: Dictionary = runtime_state_presenter.controls_for_state(runtime_state, validation_summary["is_valid"])

	ram_label.text = ram_summary["label"]
	editor_header.set_ram(ram_summary["label"])
	for block_id in block_nodes:
		block_nodes[block_id].set_invalid(false)
	for error in validation_summary["errors"]:
		if not error.subject_id.is_empty() and block_nodes.has(error.subject_id):
			block_nodes[error.subject_id].set_invalid(true)

	if validation_summary["is_valid"]:
		validation_label.text = "Programa pronto para executar"
		validation_label.add_theme_color_override("font_color", Tokens.SUCCESS)
	else:
		validation_label.text = "\n".join(_validation_messages(validation_summary["errors"]))
		validation_label.add_theme_color_override("font_color", Tokens.ERROR)

	state_label.text = runtime_state_presenter.label_for_state(runtime_state, runtime_failure_reason)
	editor_header.set_status(state_label.text)
	start_button.disabled = not control_state["can_start"]
	start_button.visible = control_state["can_edit"]
	pause_button.visible = control_state["can_pause"]
	resume_button.visible = control_state["can_resume"]
	stop_button.visible = control_state["can_stop"]
	restart_button.visible = control_state["can_restart"]
	organize_button.visible = control_state["can_edit"]
	pan_button.visible = control_state["can_edit"]
	zoom_out_button.visible = control_state["can_edit"]
	zoom_label_button.visible = control_state["can_edit"]
	zoom_in_button.visible = control_state["can_edit"]
	center_view_button.visible = control_state["can_edit"]
	drawer_button.visible = control_state["can_edit"]
	pseudocode_button.visible = control_state["can_edit"]
	example_button.text = "Carregar exemplo" if graph_state.blocks.is_empty() else "Recomecar com exemplo"
	summary_changed.emit(ram_summary["label"], state_label.text, validation_summary["is_valid"])

	for block_id in block_nodes:
		block_nodes[block_id].set_active(runtime.last_executed_block_id == block_id and runtime_state == RuntimeState.Value.RUNNING)

func _initialize_models() -> void:
	if graph_state == null:
		graph_state = EditorGraphStateScript.new()
	if block_factory == null:
		block_factory = BlockFactoryScript.new()
	if graph_builder == null:
		graph_builder = ProgramGraphBuilderScript.new()
	if graph_importer == null:
		graph_importer = ProgramGraphImporterScript.new()
	if ram_panel == null:
		ram_panel = RamPanelScript.new()
	if validation_panel == null:
		validation_panel = ValidationPanelScript.new()
	if runtime_state_presenter == null:
		runtime_state_presenter = RuntimeStatePresenterScript.new()
	if connection_controller == null:
		connection_controller = ConnectionControllerScript.new()
	if command_controller == null:
		command_controller = EditorCommandControllerScript.new()
	if layout_controller == null:
		layout_controller = EditorLayoutControllerScript.new()
	_configure_graph_state()
	if condition_selector == null:
		condition_selector = ConditionSelectorScript.new()
	if runtime == null:
		runtime = ProgramRuntimeScript.new(SensorReaderScript.new(), ActionDispatcherScript.new())
	if runtime_controls == null:
		runtime_controls = RuntimeControlsScript.new(runtime, graph_builder)
	if pseudocode_presenter == null:
		pseudocode_presenter = PseudocodePresenterScript.new()

func _ensure_ui() -> void:
	if workspace != null:
		return
	editor_view = EditorViewScript.new()
	var example_entries: Array[Dictionary] = []
	if example_provider != null:
		example_entries = example_provider.entries()
	editor_view.bind(self, block_factory, example_entries)
	_bind_view_references()
	_connect_view_signals()

func _bind_view_references() -> void:
	editor_header = editor_view.editor_header
	palette = editor_view.palette
	block_drawer = editor_view.block_drawer
	pseudocode_panel = editor_view.pseudocode_panel
	canvas_toolbar = editor_view.canvas_toolbar
	canvas_primary_tools = editor_view.canvas_primary_tools
	canvas_navigation_tools = editor_view.canvas_navigation_tools
	workspace = editor_view.workspace
	inspector_panel = editor_view.inspector_panel
	ram_label = editor_view.ram_label
	validation_label = editor_view.validation_label
	state_label = editor_view.state_label
	connection_feedback_label = editor_view.connection_feedback_label
	parameter_panel = editor_view.parameter_panel
	start_button = editor_view.start_button
	pause_button = editor_view.pause_button
	resume_button = editor_view.resume_button
	stop_button = editor_view.stop_button
	restart_button = editor_view.restart_button
	organize_button = editor_view.organize_button
	pan_button = editor_view.pan_button
	zoom_out_button = editor_view.zoom_out_button
	zoom_label_button = editor_view.zoom_label_button
	zoom_in_button = editor_view.zoom_in_button
	center_view_button = editor_view.center_view_button
	drawer_button = editor_view.drawer_button
	pseudocode_button = editor_view.pseudocode_button
	back_button = editor_view.back_button
	example_selector = editor_view.example_selector
	example_button = editor_view.example_button
	reset_brain_button = editor_view.reset_brain_button

func _connect_view_signals() -> void:
	block_drawer.block_requested.connect(_on_drawer_block_requested)
	block_drawer.close_requested.connect(_close_drawer)
	parameter_panel.condition_selected.connect(apply_condition_to_selected)
	parameter_panel.movement_pace_selected.connect(apply_movement_pace_to_selected)
	start_button.pressed.connect(_on_start_pressed)
	pause_button.pressed.connect(_on_pause_pressed)
	resume_button.pressed.connect(_on_resume_pressed)
	stop_button.pressed.connect(_on_stop_pressed)
	restart_button.pressed.connect(_on_restart_pressed)
	organize_button.pressed.connect(organize_program)
	drawer_button.toggled.connect(_on_drawer_toggled)
	pseudocode_button.pressed.connect(_on_pseudocode_pressed)
	pan_button.toggled.connect(_on_pan_toggled)
	zoom_out_button.pressed.connect(workspace.zoom_out)
	zoom_in_button.pressed.connect(workspace.zoom_in)
	center_view_button.pressed.connect(workspace.center_viewport)
	workspace.viewport_changed.connect(_on_workspace_viewport_changed)
	example_button.pressed.connect(_on_example_pressed)
	reset_brain_button.pressed.connect(reset_brain)
	back_button.pressed.connect(back_to_assembly_requested.emit)

func _on_palette_block_requested(kind: int) -> void:
	create_block(kind)

func _on_drawer_block_requested(kind: int) -> void:
	if graph_state.blocks.is_empty():
		create_block(kind)
		_close_drawer()
		return
	if pending_connection_from_block_id.is_empty():
		connection_feedback_label.text = "Selecione uma saida antes de inserir"
		connection_feedback_label.add_theme_color_override("font_color", Tokens.AMBER)
		block_drawer.show_insertion_error()
		return
	var source_node = block_nodes.get(pending_connection_from_block_id)
	var spawn_position := next_spawn_position
	if source_node != null:
		spawn_position = source_node.position + Vector2(210, 0)
	var result = command_controller.insert_connected_block(kind, spawn_position, pending_connection_from_block_id, pending_connection_from_port)
	if not result.is_success:
		connection_feedback_label.text = "Nao foi possivel inserir nessa saida"
		connection_feedback_label.add_theme_color_override("font_color", Tokens.ERROR)
		return
	var block_state = result.value
	pending_connection_from_block_id = ""
	pending_connection_from_port = ""
	block_drawer.show_insertion_hint()
	select_block(block_state.id)
	connection_feedback_label.text = "Bloco inserido e conectado"
	connection_feedback_label.add_theme_color_override("font_color", Tokens.SUCCESS)
	_sync_editor_from_graph_state()
	_close_drawer()

func _on_start_pressed() -> void:
	if external_attempt_runner:
		attempt_requested.emit()
		return
	if runtime_controls.prepare_from_graph(graph_state):
		runtime_controls.start()
	refresh_panels()

func _on_pause_pressed() -> void:
	runtime_controls.pause()
	refresh_panels()

func _on_resume_pressed() -> void:
	runtime_controls.resume()
	refresh_panels()

func _on_stop_pressed() -> void:
	runtime_controls.stop()
	refresh_panels()

func _on_restart_pressed() -> void:
	runtime_controls.restart()
	refresh_panels()

func _on_example_pressed() -> void:
	if example_selector == null or example_selector.item_count == 0:
		return
	load_example(int(example_selector.get_selected_metadata()))

func _on_block_node_moved(block_id: String, new_position: Vector2) -> void:
	command_controller.move_block(block_id, new_position)

func _on_remove_block_requested(block_id: String) -> void:
	_remove_block(block_id)

func _remove_block(block_id: String) -> bool:
	selected_block_id = block_id
	var removed: bool = command_controller.remove_block(block_id).is_success
	if removed:
		selected_block_id = ""
		pending_connection_from_block_id = ""
		pending_connection_from_port = ""
		for node_id in block_nodes:
			block_nodes[node_id].set_compatible_target(false)
		block_drawer.show_insertion_hint()
		_close_drawer()
		_sync_editor_from_graph_state()
		connection_feedback_label.text = "Bloco removido. Escolha uma saida vazia para continuar."
		connection_feedback_label.add_theme_color_override("font_color", Tokens.TEXT_MUTED)
	return removed

func _on_output_port_selected(block_id: String, port: String) -> void:
	if _output_has_connection(block_id, port):
		connection_feedback_label.text = "Essa saida ja esta conectada. Remova o bloco ligado para deixa-la vazia."
		connection_feedback_label.add_theme_color_override("font_color", Tokens.AMBER)
		return
	start_connection(block_id, port)
	block_drawer.show()
	drawer_button.set_pressed_no_signal(true)

func _output_has_connection(block_id: String, port: String) -> bool:
	for connection in graph_state.connections:
		if connection.from_block_id == block_id and connection.from_port == port:
			return true
	return false

func _update_parameter_panel() -> void:
	if parameter_panel == null:
		return
	if selected_block_id.is_empty() or not graph_state.blocks.has(selected_block_id):
		parameter_panel.show_no_selection()
		return
	parameter_panel.show_block(graph_state.blocks[selected_block_id])

func _add_block_node(block_state):
	var block_node = BlockNodeScript.new()
	block_node.configure(block_state, block_factory.label_for_kind(block_state.kind), block_factory.output_ports_for_kind(block_state.kind))
	block_node.selected.connect(select_block)
	block_node.input_selected.connect(complete_connection)
	block_node.output_port_selected.connect(_on_output_port_selected)
	block_node.moved.connect(_on_block_node_moved)
	block_node.remove_requested.connect(_on_remove_block_requested)
	block_node.block_insert_requested.connect(_on_block_insert_requested)
	workspace.add_block_node(block_node)
	block_nodes[block_state.id] = block_node
	return block_node

func _reset_graph_state() -> void:
	_clear_workspace_program()
	_replace_graph_state(EditorGraphStateScript.new())
	selected_block_id = ""
	pending_connection_from_block_id = ""
	pending_connection_from_port = ""
	next_spawn_position = DEFAULT_SPAWN_POSITION
	if runtime != null:
		runtime.stop()
		runtime.prepare(graph_builder.build(graph_state))
	_sync_editor_from_graph_state()

func _clear_workspace_program() -> void:
	_clear_connection_visuals()

	for block_id in block_nodes:
		var block_node = block_nodes[block_id]
		if is_instance_valid(block_node):
			block_node.free()
	block_nodes.clear()

func _rebuild_connection_lines() -> void:
	_clear_connection_visuals()
	workspace.configure_connections(graph_state, block_nodes)

func organize_program() -> void:
	var positions: Dictionary = layout_controller.positions_for(graph_state)
	is_sync_suspended = true
	for block_id in positions:
		command_controller.move_block(block_id, positions[block_id])
		if block_nodes.has(block_id):
			block_nodes[block_id].move_to(positions[block_id])
	is_sync_suspended = false
	_sync_editor_from_graph_state()

func _configure_graph_state() -> void:
	if graph_state == null or command_controller == null:
		return
	command_controller.configure(graph_state, block_factory, connection_controller)
	if not graph_state.changed.is_connected(_on_graph_state_changed):
		graph_state.changed.connect(_on_graph_state_changed)

func _replace_graph_state(next_graph_state) -> void:
	if graph_state != null and graph_state.changed.is_connected(_on_graph_state_changed):
		graph_state.changed.disconnect(_on_graph_state_changed)
	graph_state = next_graph_state
	_configure_graph_state()

func _on_graph_state_changed(_change: int, _affected_block_ids: PackedStringArray) -> void:
	if not is_sync_suspended:
		_sync_editor_from_graph_state()

func _sync_editor_from_graph_state() -> void:
	if workspace == null:
		return
	_reconcile_block_nodes()
	_refresh_next_spawn_position()
	_rebuild_connection_lines()
	_update_parameter_panel()
	refresh_panels()

func _reconcile_block_nodes() -> void:
	for block_id in graph_state.blocks:
		if not block_nodes.has(block_id):
			_add_block_node(graph_state.blocks[block_id])
	for block_id in block_nodes.keys():
		if not graph_state.blocks.has(block_id):
			_remove_block_node(block_id)

func _remove_block_node(block_id: String) -> void:
	if not block_nodes.has(block_id):
		return
	var node = block_nodes[block_id]
	block_nodes.erase(block_id)
	if is_instance_valid(node):
		node.queue_free()

func _clear_connection_visuals() -> void:
	# Remove visuais legados que foram criados antes do canvas unico.
	for child in workspace.get_children():
		if child is Node2D and is_instance_valid(child):
			child.free()
	workspace.configure_connections(null, {})

func _on_pan_toggled(enabled: bool) -> void:
	workspace.set_navigation_enabled(enabled)

func _on_workspace_viewport_changed(zoom_label: String) -> void:
	zoom_label_button.text = zoom_label

func _on_drawer_toggled(is_open: bool) -> void:
	block_drawer.visible = is_open

func _close_drawer() -> void:
	block_drawer.hide()
	drawer_button.set_pressed_no_signal(false)

func _on_pseudocode_pressed() -> void:
	var result: Dictionary = pseudocode_presenter.present(graph_state)
	pseudocode_panel.show_text(result["text"])

func _on_block_insert_requested(block_id: String, port: String, kind: int) -> void:
	if _output_has_connection(block_id, port):
		connection_feedback_label.text = "Essa saida ja esta conectada. Remova o bloco ligado antes de inserir outro."
		connection_feedback_label.add_theme_color_override("font_color", Tokens.AMBER)
		return
	start_connection(block_id, port)
	_on_drawer_block_requested(kind)

func _port_label_for_drawer(port: String) -> String:
	match port:
		"body": return "Repetir"
		"next": return "Depois"
		"true": return "Sim"
		"false": return "Nao"
		_: return port

func _refresh_next_spawn_position() -> void:
	next_spawn_position = DEFAULT_SPAWN_POSITION + SPAWN_OFFSET * block_nodes.size()

func _validation_messages(errors: Array) -> PackedStringArray:
	var messages := PackedStringArray()
	for error in errors:
		if error.code == ProgramValidationError.Code.INVALID_BLOCK and graph_state.blocks.has(error.subject_id):
			var block_state = graph_state.blocks[error.subject_id]
			if ProgramBlockKind.requires_condition(block_state.kind):
				messages.append("%s precisa de uma condicao. Selecione o bloco e escolha ao lado." % block_factory.label_for_kind(block_state.kind))
				continue
		var message: String = validation_panel.mapper.message_for_error(error)
		if not message.is_empty():
			messages.append(message)
	return messages
