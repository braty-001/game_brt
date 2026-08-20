class_name BrainEditor
extends Control

const BlockFactoryScript = preload("res://src/brain_editor/block_factory.gd")
const BlockNodeScript = preload("res://src/brain_editor/block_node.gd")
const BlockPaletteScript = preload("res://src/brain_editor/block_palette.gd")
const BlockParameterPanelScript = preload("res://src/brain_editor/block_parameter_panel.gd")
const BunekoActionDispatcherScript = preload("res://src/buneko/runtime/buneko_action_dispatcher.gd")
const BunekoMotorScript = preload("res://src/buneko/runtime/buneko_motor.gd")
const BunekoSensorReaderScript = preload("res://src/buneko/runtime/buneko_sensor_reader.gd")
const ConditionSelectorScript = preload("res://src/brain_editor/condition_selector.gd")
const ConnectionControllerScript = preload("res://src/brain_editor/connection_controller.gd")
const EditorGraphStateScript = preload("res://src/brain_editor/editor_graph_state.gd")
const MissionHeaderScript = preload("res://src/ui/mission_step_header.gd")
const ProgramGraphBuilderScript = preload("res://src/brain_editor/program_graph_builder.gd")
const RamPanelScript = preload("res://src/brain_editor/ram_panel.gd")
const RuntimeStatePresenterScript = preload("res://src/brain_editor/runtime_state_presenter.gd")
const ProgramRuntimeScript = preload("res://src/programming/runtime/program_runtime.gd")
const RuntimeControlsScript = preload("res://src/brain_editor/runtime_controls.gd")
const Tokens = preload("res://src/ui/design_tokens.gd")
const TutorialReferenceProgramScript = preload("res://src/tutorial/tutorial_reference_program.gd")
const ValidationPanelScript = preload("res://src/brain_editor/validation_panel.gd")
const WorkspaceScript = preload("res://src/brain_editor/editor_workspace.gd")
const WorkspaceInputControllerScript = preload("res://src/brain_editor/workspace_input_controller.gd")

const DEFAULT_SPAWN_POSITION := Vector2(230, 108)
const SPAWN_OFFSET := Vector2(24, 82)

signal attempt_requested
signal back_to_assembly_requested
signal summary_changed(ram: String, status: String, is_valid: bool)

var graph_state
var block_factory
var graph_builder
var ram_panel
var validation_panel
var runtime_state_presenter
var workspace_controller
var connection_controller
var condition_selector
var runtime
var runtime_controls

var block_nodes: Dictionary = {}
var selected_block_id := ""
var pending_connection_from_block_id := ""
var pending_connection_from_port := ""
var next_spawn_position := DEFAULT_SPAWN_POSITION
var external_attempt_runner := false

var editor_header
var palette
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

	var block_state = block_factory.create_block(kind, spawn_position)
	if block_state == null:
		return null

	graph_state.add_block(block_state)
	if graph_state.start_block_id.is_empty():
		graph_state.start_block_id = block_state.id

	var block_node = _add_block_node(block_state)
	_refresh_next_spawn_position()
	select_block(block_state.id)
	_rebuild_connection_lines()
	refresh_panels()
	return block_node

func load_graph_state(saved_graph_state) -> bool:
	if saved_graph_state == null:
		return false

	_initialize_models()
	_ensure_ui()
	_clear_workspace_program()
	graph_state = saved_graph_state
	selected_block_id = ""
	pending_connection_from_block_id = ""
	pending_connection_from_port = ""

	for block_id in graph_state.blocks:
		_add_block_node(graph_state.blocks[block_id])

	_refresh_next_spawn_position()
	_rebuild_connection_lines()
	refresh_panels()
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

	var applied: bool = condition_selector.apply_condition(graph_state, selected_block_id, modality, query)
	if applied and block_nodes.has(selected_block_id):
		block_nodes[selected_block_id].refresh_from_state()
	_update_parameter_panel()
	refresh_panels()
	return applied

func start_connection(block_id: String, port: String) -> void:
	pending_connection_from_block_id = block_id
	pending_connection_from_port = port
	selected_block_id = block_id
	for node_id in block_nodes:
		block_nodes[node_id].set_compatible_target(node_id != block_id)
	connection_feedback_label.text = "Selecione a entrada de outro bloco"
	connection_feedback_label.add_theme_color_override("font_color", Tokens.TEAL)

func complete_connection(target_block_id: String) -> bool:
	if pending_connection_from_block_id.is_empty():
		return false

	var connected: bool = connection_controller.connect_blocks(
		graph_state,
		pending_connection_from_block_id,
		pending_connection_from_port,
		target_block_id
	)
	pending_connection_from_block_id = ""
	pending_connection_from_port = ""
	for node_id in block_nodes:
		block_nodes[node_id].set_compatible_target(false)
	connection_feedback_label.text = "Conexao criada" if connected else "Esta conexao nao e compativel"
	connection_feedback_label.add_theme_color_override("font_color", Tokens.SUCCESS if connected else Tokens.ERROR)
	_rebuild_connection_lines()
	refresh_panels()
	selected_block_id = target_block_id
	select_block(target_block_id)
	return connected

func move_selected_block(new_position: Vector2) -> bool:
	if selected_block_id.is_empty():
		return false

	var moved: bool = workspace_controller.move_block(
		graph_state,
		block_nodes,
		selected_block_id,
		new_position
	)
	_rebuild_connection_lines()
	return moved

func remove_selected_block() -> bool:
	if selected_block_id.is_empty():
		return false
	return _remove_block(selected_block_id)

func current_program():
	return graph_builder.build(graph_state)

func load_tutorial_example(example := TutorialReferenceProgramScript.Example.IF_GAP) -> void:
	_reset_graph_state()

	if example == TutorialReferenceProgramScript.Example.WHILE_PATH_CLEAR:
		_load_while_example_graph()
	else:
		_load_if_example_graph()

	connection_feedback_label.text = "Exemplo carregado. Mova os blocos e observe as conexoes."
	refresh_panels()

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
	if ram_panel == null:
		ram_panel = RamPanelScript.new()
	if validation_panel == null:
		validation_panel = ValidationPanelScript.new()
	if runtime_state_presenter == null:
		runtime_state_presenter = RuntimeStatePresenterScript.new()
	if workspace_controller == null:
		workspace_controller = WorkspaceInputControllerScript.new()
	if connection_controller == null:
		connection_controller = ConnectionControllerScript.new()
	if condition_selector == null:
		condition_selector = ConditionSelectorScript.new()
	if runtime == null:
		var motor = BunekoMotorScript.new()
		var dispatcher = BunekoActionDispatcherScript.new(motor)
		var sensor_reader = BunekoSensorReaderScript.new()
		runtime = ProgramRuntimeScript.new(sensor_reader, dispatcher)
	if runtime_controls == null:
		runtime_controls = RuntimeControlsScript.new(runtime, graph_builder)

func _ensure_ui() -> void:
	if workspace != null:
		return

	theme = load("res://themes/buneko_theme.tres")
	anchors_preset = PRESET_FULL_RECT
	anchor_right = 1.0
	anchor_bottom = 1.0

	var background := ColorRect.new()
	background.color = Tokens.BACKGROUND
	background.set_anchors_preset(PRESET_FULL_RECT)
	background.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(background)

	var margin := MarginContainer.new()
	margin.set_anchors_preset(PRESET_FULL_RECT)
	margin.add_theme_constant_override("margin_left", 14)
	margin.add_theme_constant_override("margin_right", 14)
	margin.add_theme_constant_override("margin_top", 12)
	margin.add_theme_constant_override("margin_bottom", 12)
	add_child(margin)

	var page := VBoxContainer.new()
	page.add_theme_constant_override("separation", 10)
	margin.add_child(page)

	editor_header = MissionHeaderScript.new()
	editor_header.name = "EditorHeader"
	editor_header.configure("ETAPA 2/3  PROGRAMACAO", "Atravesse o buraco e alcance o objetivo", "Editando", "0/5 RAM")
	page.add_child(editor_header)

	var body := HBoxContainer.new()
	body.size_flags_vertical = Control.SIZE_EXPAND_FILL
	body.add_theme_constant_override("separation", 10)
	page.add_child(body)

	var palette_panel := PanelContainer.new()
	palette_panel.custom_minimum_size.x = 165.0
	Tokens.apply_panel(palette_panel)
	body.add_child(palette_panel)
	var palette_box := VBoxContainer.new()
	palette_panel.add_child(palette_box)
	var palette_title := Label.new()
	palette_title.text = "BLOCOS"
	palette_title.add_theme_color_override("font_color", Tokens.TEXT_MUTED)
	palette_box.add_child(palette_title)
	palette = BlockPaletteScript.new()
	palette.name = "Palette"
	palette.factory = block_factory
	palette.block_requested.connect(_on_palette_block_requested)
	palette_box.add_child(palette)

	var center := VBoxContainer.new()
	center.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	center.size_flags_vertical = Control.SIZE_EXPAND_FILL
	center.add_theme_constant_override("separation", 8)
	body.add_child(center)

	var workspace_panel := PanelContainer.new()
	workspace_panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	workspace_panel.size_flags_vertical = Control.SIZE_EXPAND_FILL
	Tokens.apply_panel(workspace_panel, Color("1b252a"))
	center.add_child(workspace_panel)
	workspace = WorkspaceScript.new()
	workspace.name = "Workspace"
	workspace.custom_minimum_size = Vector2(480, 360)
	workspace_panel.add_child(workspace)
	_add_start_marker()

	var toolbar_panel := PanelContainer.new()
	Tokens.apply_panel(toolbar_panel)
	center.add_child(toolbar_panel)
	var toolbar := HBoxContainer.new()
	toolbar.add_theme_constant_override("separation", 8)
	toolbar_panel.add_child(toolbar)
	validation_label = Label.new()
	validation_label.name = "ValidationLabel"
	validation_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	validation_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	toolbar.add_child(validation_label)
	start_button = _add_control_button(toolbar, "StartButton", "Executar tentativa", true)
	pause_button = _add_control_button(toolbar, "PauseButton", "Pausar")
	resume_button = _add_control_button(toolbar, "ResumeButton", "Retomar", true)
	stop_button = _add_control_button(toolbar, "StopButton", "Parar")
	restart_button = _add_control_button(toolbar, "RestartButton", "Executar novamente", true)
	start_button.pressed.connect(_on_start_pressed)
	pause_button.pressed.connect(_on_pause_pressed)
	resume_button.pressed.connect(_on_resume_pressed)
	stop_button.pressed.connect(_on_stop_pressed)
	restart_button.pressed.connect(_on_restart_pressed)

	inspector_panel = PanelContainer.new()
	inspector_panel.custom_minimum_size.x = 195.0
	Tokens.apply_panel(inspector_panel)
	body.add_child(inspector_panel)
	var inspector := VBoxContainer.new()
	inspector.add_theme_constant_override("separation", 10)
	inspector_panel.add_child(inspector)
	var inspector_title := Label.new()
	inspector_title.text = "PROPRIEDADES"
	inspector_title.add_theme_color_override("font_color", Tokens.TEXT_MUTED)
	inspector.add_child(inspector_title)
	parameter_panel = BlockParameterPanelScript.new()
	parameter_panel.name = "ParameterPanel"
	parameter_panel.condition_selected.connect(apply_condition_to_selected)
	inspector.add_child(parameter_panel)
	var separator := HSeparator.new()
	inspector.add_child(separator)
	connection_feedback_label = Label.new()
	connection_feedback_label.name = "ConnectionFeedback"
	connection_feedback_label.text = "Adicione um bloco para comecar"
	connection_feedback_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	connection_feedback_label.size_flags_vertical = Control.SIZE_EXPAND_FILL
	connection_feedback_label.add_theme_color_override("font_color", Tokens.TEXT_MUTED)
	inspector.add_child(connection_feedback_label)
	example_selector = OptionButton.new()
	example_selector.name = "ExampleSelector"
	example_selector.add_item("Exemplo com IF")
	example_selector.set_item_metadata(0, TutorialReferenceProgramScript.Example.IF_GAP)
	example_selector.add_item("Exemplo com WHILE")
	example_selector.set_item_metadata(1, TutorialReferenceProgramScript.Example.WHILE_PATH_CLEAR)
	inspector.add_child(example_selector)
	example_button = Button.new()
	example_button.name = "ExampleButton"
	example_button.text = "Carregar exemplo"
	example_button.tooltip_text = "Substitui o grafo atual por uma solucao curta que voce pode editar"
	Tokens.apply_secondary_button(example_button)
	example_button.pressed.connect(_on_example_pressed)
	inspector.add_child(example_button)
	reset_brain_button = Button.new()
	reset_brain_button.name = "ResetBrainButton"
	reset_brain_button.text = "Zerar cerebro"
	reset_brain_button.tooltip_text = "Remove todos os blocos e conexoes do cerebro atual"
	Tokens.apply_secondary_button(reset_brain_button)
	reset_brain_button.pressed.connect(reset_brain)
	inspector.add_child(reset_brain_button)
	ram_label = Label.new()
	ram_label.name = "RamLabel"
	ram_label.visible = false
	inspector.add_child(ram_label)
	state_label = Label.new()
	state_label.name = "StateLabel"
	state_label.visible = false
	inspector.add_child(state_label)
	back_button = Button.new()
	back_button.text = "Voltar para montagem"
	back_button.visible = false
	Tokens.apply_secondary_button(back_button)
	back_button.pressed.connect(back_to_assembly_requested.emit)
	inspector.add_child(back_button)

func _add_start_marker() -> void:
	var marker := PanelContainer.new()
	marker.name = "StartMarker"
	marker.position = Vector2(22, 24)
	marker.custom_minimum_size = Vector2(130, 54)
	marker.mouse_filter = Control.MOUSE_FILTER_IGNORE
	marker.add_theme_stylebox_override("panel", Tokens.panel_style(Color("173b3c"), 6, Tokens.TEAL))
	var label := Label.new()
	label.text = "INICIO   ●"
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.add_theme_color_override("font_color", Tokens.TEAL)
	marker.add_child(label)
	workspace.add_child(marker)

func _add_control_button(parent: Node, button_name: String, button_text: String, primary := false) -> Button:
	var button := Button.new()
	button.name = button_name
	button.text = button_text
	if primary:
		Tokens.apply_primary_button(button)
	else:
		Tokens.apply_secondary_button(button)
	parent.add_child(button)
	return button

func _on_palette_block_requested(kind: int) -> void:
	create_block(kind)

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
	var selected_example: int = TutorialReferenceProgramScript.Example.IF_GAP
	if example_selector != null:
		selected_example = int(example_selector.get_selected_metadata())
	load_tutorial_example(selected_example)

func _on_block_node_moved(block_id: String, new_position: Vector2) -> void:
	graph_state.move_block(block_id, new_position)
	_rebuild_connection_lines()

func _on_remove_block_requested(block_id: String) -> void:
	_remove_block(block_id)

func _remove_block(block_id: String) -> bool:
	selected_block_id = block_id
	var removed: bool = workspace_controller.remove_block(graph_state, block_nodes, workspace, block_id)
	if removed:
		selected_block_id = ""
		_refresh_next_spawn_position()
		_rebuild_connection_lines()
		_update_parameter_panel()
		refresh_panels()
	return removed

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
	block_node.output_port_selected.connect(start_connection)
	block_node.moved.connect(_on_block_node_moved)
	block_node.remove_requested.connect(_on_remove_block_requested)
	workspace.add_child(block_node)
	block_nodes[block_state.id] = block_node
	return block_node

func _load_if_example_graph() -> void:
	var while_node = create_block(ProgramBlockKind.Value.WHILE, Vector2(205, 86))
	apply_condition_to_selected(ConditionCatalog.Modality.VISION, ConditionCatalog.Query.PATH_CLEAR_AHEAD)
	var walk_node = create_block(ProgramBlockKind.Value.WALK, Vector2(430, 62))
	var if_node = create_block(ProgramBlockKind.Value.IF, Vector2(430, 190))
	apply_condition_to_selected(ConditionCatalog.Modality.VISION, ConditionCatalog.Query.GAP_AHEAD)
	var jump_node = create_block(ProgramBlockKind.Value.JUMP, Vector2(655, 170))
	var run_node = create_block(ProgramBlockKind.Value.RUN, Vector2(655, 270))
	start_connection(while_node.block_id, "body")
	complete_connection(walk_node.block_id)
	start_connection(while_node.block_id, "next")
	complete_connection(if_node.block_id)
	start_connection(if_node.block_id, "true")
	complete_connection(jump_node.block_id)
	start_connection(jump_node.block_id, "next")
	complete_connection(run_node.block_id)
	select_block(while_node.block_id)

func _load_while_example_graph() -> void:
	var while_node = create_block(ProgramBlockKind.Value.WHILE, Vector2(205, 86))
	apply_condition_to_selected(ConditionCatalog.Modality.VISION, ConditionCatalog.Query.PATH_CLEAR_AHEAD)
	var walk_node = create_block(ProgramBlockKind.Value.WALK, Vector2(430, 62))
	var if_node = create_block(ProgramBlockKind.Value.IF, Vector2(430, 190))
	apply_condition_to_selected(ConditionCatalog.Modality.VISION, ConditionCatalog.Query.GAP_AHEAD)
	var jump_node = create_block(ProgramBlockKind.Value.JUMP, Vector2(655, 170))
	var run_node = create_block(ProgramBlockKind.Value.RUN, Vector2(655, 270))
	start_connection(while_node.block_id, "body")
	complete_connection(walk_node.block_id)
	start_connection(while_node.block_id, "next")
	complete_connection(if_node.block_id)
	start_connection(if_node.block_id, "true")
	complete_connection(jump_node.block_id)
	start_connection(jump_node.block_id, "next")
	complete_connection(run_node.block_id)
	select_block(while_node.block_id)

func _reset_graph_state() -> void:
	_clear_workspace_program()
	graph_state = EditorGraphStateScript.new()
	selected_block_id = ""
	pending_connection_from_block_id = ""
	pending_connection_from_port = ""
	next_spawn_position = DEFAULT_SPAWN_POSITION
	if runtime != null:
		runtime.stop()
		runtime.prepare(graph_builder.build(graph_state))

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

func _clear_connection_visuals() -> void:
	# Remove visuais legados que foram criados antes do canvas unico.
	for child in workspace.get_children():
		if child is Node2D and is_instance_valid(child):
			child.free()
	workspace.configure_connections(null, {})

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
