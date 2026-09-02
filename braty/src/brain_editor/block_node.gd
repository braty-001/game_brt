class_name BrainEditorBlockNode
extends PanelContainer

const Tokens = preload("res://src/ui/design_tokens.gd")
const PresentationRegistryScript = preload("res://src/brain_editor/block_presentation_registry.gd")
const PortButtonScript = preload("res://src/brain_editor/block_port_button.gd")
const MovementPaceScript = preload("res://src/programming/domain/movement_pace.gd")

signal selected(block_id: String)
signal input_selected(block_id: String)
signal output_port_selected(block_id: String, port: String)
signal moved(block_id: String, new_position: Vector2)
signal remove_requested(block_id: String)
signal block_insert_requested(block_id: String, port: String, kind: int)

var block_id: String
var block_kind: int
var output_ports := PackedStringArray()
var selected_state := false
var active_state := false
var invalid_state := false
var block_state

var _title_label: Label
var _parameter_label: Label
var _input_button: Button
var _ports_box: BoxContainer
var _port_buttons: Dictionary = {}
var _dragging := false
var _presentation_registry = PresentationRegistryScript.new()
var _shape := PresentationRegistryScript.Shape.ACTION

func _ready() -> void:
	if _title_label == null:
		_build_ui()

func configure(state, label: String, ports: PackedStringArray) -> void:
	block_state = state
	block_id = state.id
	block_kind = state.kind
	position = state.position
	output_ports = ports
	var presentation: Dictionary = _presentation_registry.presentation_for(block_kind)
	_shape = presentation.get("shape", PresentationRegistryScript.Shape.ACTION)
	if _title_label == null:
		_build_ui()
	_title_label.text = label
	_refresh_parameter_summary()
	_rebuild_ports()
	custom_minimum_size = presentation.get("size", Vector2(154, 76))
	_refresh_style()

func set_selected(is_selected: bool) -> void:
	selected_state = is_selected
	_refresh_style()

func set_active(is_active: bool) -> void:
	active_state = is_active
	_refresh_style()

func set_invalid(is_invalid: bool) -> void:
	invalid_state = is_invalid
	_refresh_style()

func refresh_from_state() -> void:
	_refresh_parameter_summary()

func move_to(new_position: Vector2) -> void:
	position = new_position

func input_position() -> Vector2:
	if _input_button == null:
		return position + Vector2(0, size.y * 0.5)
	return position + _input_button.position + _input_button.size * 0.5

func output_position(port: String) -> Vector2:
	if not _port_buttons.has(port):
		return position + Vector2(size.x, size.y * 0.5)
	var button: Button = _port_buttons[port]
	return position + button.position + button.size * 0.5

func set_compatible_target(value: bool) -> void:
	if value:
		_input_button.add_theme_color_override("font_color", Tokens.SUCCESS)
	else:
		_input_button.add_theme_color_override("font_color", Tokens.TEXT_MUTED)

func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			_dragging = true
			selected.emit(block_id)
		else:
			_dragging = false
	elif event is InputEventMouseMotion and _dragging:
		position += event.relative
		moved.emit(block_id, position)

func _build_ui() -> void:
	mouse_filter = Control.MOUSE_FILTER_STOP
	var box := VBoxContainer.new()
	box.name = "Content"
	box.add_theme_constant_override("separation", 2)
	add_child(box)

	var header := HBoxContainer.new()
	box.add_child(header)
	_input_button = Button.new()
	_input_button.name = "InputPort"
	_input_button.text = "●"
	_input_button.flat = true
	_input_button.tooltip_text = "Entrada do bloco"
	_input_button.pressed.connect(_on_input_pressed)
	header.add_child(_input_button)
	_title_label = Label.new()
	_title_label.name = "Title"
	_title_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_title_label.add_theme_font_size_override("font_size", 15)
	header.add_child(_title_label)
	var remove_button := Button.new()
	remove_button.name = "RemoveButton"
	remove_button.text = "×"
	remove_button.flat = true
	remove_button.tooltip_text = "Remover bloco"
	remove_button.pressed.connect(_on_remove_pressed)
	header.add_child(remove_button)

	_parameter_label = Label.new()
	_parameter_label.name = "ParameterSummary"
	_parameter_label.add_theme_color_override("font_color", Tokens.TEXT_MUTED)
	_parameter_label.add_theme_font_size_override("font_size", 13)
	_parameter_label.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	box.add_child(_parameter_label)

	_ports_box = VBoxContainer.new() if _shape == PresentationRegistryScript.Shape.BRANCH else HBoxContainer.new()
	_ports_box.name = "Ports"
	_ports_box.alignment = BoxContainer.ALIGNMENT_END
	box.add_child(_ports_box)

func _rebuild_ports() -> void:
	for child in _ports_box.get_children():
		child.queue_free()
	_port_buttons.clear()

	for port in output_ports:
		var button = PortButtonScript.new()
		button.name = "Port_%s" % port
		button.text = "%s  ●" % _port_label(port)
		button.flat = true
		button.add_theme_font_size_override("font_size", 13)
		button.tooltip_text = _port_tooltip(port)
		button.add_theme_color_override("font_color", _port_color(port))
		button.pressed.connect(_on_port_pressed.bind(port))
		button.block_dropped.connect(_on_block_dropped.bind(port))
		_ports_box.add_child(button)
		_port_buttons[port] = button

func _refresh_parameter_summary() -> void:
	if block_state == null:
		return
	if not ProgramBlockKind.requires_condition(block_kind):
		if block_kind == ProgramBlockKind.Value.WALK:
			_parameter_label.text = "Ritmo: %s" % MovementPaceScript.label(
				MovementPaceScript.from_parameters(block_state.parameters)
			).to_lower()
		else:
			_parameter_label.text = "Acao"
		return
	if block_state.condition == null:
		_parameter_label.text = "Escolha uma condicao"
		return
	if block_kind == ProgramBlockKind.Value.IF:
		_parameter_label.text = "Se %s" % _condition_question(block_state.condition.query)
	elif block_kind == ProgramBlockKind.Value.WHILE:
		_parameter_label.text = "Enquanto %s" % _condition_question(block_state.condition.query)
	else:
		_parameter_label.text = _condition_label(block_state.condition.query)

func _refresh_style() -> void:
	var border := Tokens.category_color(block_kind)
	var background := Tokens.SURFACE
	if active_state:
		border = Tokens.SUCCESS
		background = Color("29443a")
	elif selected_state:
		border = Tokens.AMBER
		background = Color("3b3730")
	elif invalid_state:
		border = Tokens.ERROR
		background = Color("3d292b")
	var style := Tokens.panel_style(background, 6, border)
	style.content_margin_left = 9.0
	style.content_margin_right = 9.0
	style.content_margin_top = 7.0
	style.content_margin_bottom = 7.0
	add_theme_stylebox_override("panel", style)

func _condition_label(query: int) -> String:
	match query:
		ConditionCatalog.Query.PATH_CLEAR_AHEAD:
			return "Visao: caminho livre a frente"
		ConditionCatalog.Query.GAP_AHEAD:
			return "Visao: buraco a frente"
		ConditionCatalog.Query.GOAL_VISIBLE:
			return "Visao: objetivo a frente"
		ConditionCatalog.Query.SIGNAL_HEARD:
			return "Audicao: sinal ouvido"
		_:
			return "Condicao"

func _condition_question(query: int) -> String:
	match query:
		ConditionCatalog.Query.PATH_CLEAR_AHEAD:
			return "caminho livre a frente?"
		ConditionCatalog.Query.GAP_AHEAD:
			return "buraco a frente?"
		ConditionCatalog.Query.GOAL_VISIBLE:
			return "objetivo visivel?"
		ConditionCatalog.Query.SIGNAL_HEARD:
			return "sinal ouvido?"
		_:
			return "condicao?"

func _port_label(port: String) -> String:
	if block_kind == ProgramBlockKind.Value.IF:
		match port:
			"true":
				return "✓"
			"false":
				return "×"

	match port:
		"true":
			return "Sim"
		"false":
			return "Nao"
		"body":
			return "Repetir"
		"next":
			return "Depois"
		_:
			return port

func _port_tooltip(port: String) -> String:
	if block_kind == ProgramBlockKind.Value.IF:
		match port:
			"true":
				return "Ramo positivo: a condicao respondeu sim"
			"false":
				return "Ramo negativo: a condicao respondeu nao"

	return "Criar conexao pela saida %s" % _port_label(port)

func _port_color(port: String) -> Color:
	if block_kind == ProgramBlockKind.Value.IF:
		if port == "true":
			return Tokens.SUCCESS
		if port == "false":
			return Tokens.ERROR
	return Tokens.category_color(block_kind)

func _on_input_pressed() -> void:
	input_selected.emit(block_id)

func _on_port_pressed(port: String) -> void:
	output_port_selected.emit(block_id, port)

func _on_remove_pressed() -> void:
	remove_requested.emit(block_id)

func _on_block_dropped(kind: int, port: String) -> void:
	block_insert_requested.emit(block_id, port, kind)
