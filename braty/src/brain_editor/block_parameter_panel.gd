class_name BrainEditorBlockParameterPanel
extends VBoxContainer

const ConditionSelectorScript = preload("res://src/brain_editor/condition_selector.gd")
const MovementPaceScript = preload("res://src/programming/domain/movement_pace.gd")

signal condition_selected(modality: int, query: int)
signal movement_pace_selected(pace: int)

var selector
var condition_options: Array = []
var title_label: Label
var condition_dropdown: OptionButton
var movement_pace_dropdown: OptionButton

func configure_selector(condition_selector) -> void:
	selector = condition_selector
	_build_ui()
	condition_dropdown.clear()
	condition_options = selector.available_options()
	for option in condition_options:
		condition_dropdown.add_item(option["label"])
	show_no_selection()

func _ready() -> void:
	if selector == null:
		selector = ConditionSelectorScript.new()
	_build_ui()
	show_no_selection()

func show_no_selection() -> void:
	_build_ui()
	title_label.text = "Parametros"
	condition_dropdown.disabled = true
	condition_dropdown.visible = false
	condition_dropdown.select(-1)
	movement_pace_dropdown.disabled = true
	movement_pace_dropdown.visible = false
	movement_pace_dropdown.select(-1)

func show_block(block_state) -> void:
	_build_ui()
	if block_state == null:
		show_no_selection()
		return

	if ProgramBlockKind.requires_condition(block_state.kind):
		title_label.text = "Condicao"
		condition_dropdown.disabled = false
		condition_dropdown.visible = true
		movement_pace_dropdown.disabled = true
		movement_pace_dropdown.visible = false
		_select_condition(block_state.condition)
	elif block_state.kind == ProgramBlockKind.Value.WALK:
		title_label.text = "Ritmo"
		condition_dropdown.disabled = true
		condition_dropdown.visible = false
		movement_pace_dropdown.disabled = false
		movement_pace_dropdown.visible = true
		_select_movement_pace(MovementPaceScript.from_parameters(block_state.parameters))
	else:
		title_label.text = "Sem parametros"
		condition_dropdown.disabled = true
		condition_dropdown.visible = false
		condition_dropdown.select(-1)
		movement_pace_dropdown.disabled = true
		movement_pace_dropdown.visible = false
		movement_pace_dropdown.select(-1)

func _build_ui() -> void:
	if title_label != null:
		return

	title_label = Label.new()
	title_label.name = "ParameterTitle"
	add_child(title_label)

	condition_dropdown = OptionButton.new()
	condition_dropdown.name = "ConditionDropdown"
	add_child(condition_dropdown)
	condition_dropdown.item_selected.connect(_on_condition_selected)

	movement_pace_dropdown = OptionButton.new()
	movement_pace_dropdown.name = "MovementPaceDropdown"
	movement_pace_dropdown.add_item("Normal", MovementPaceScript.Value.NORMAL)
	movement_pace_dropdown.add_item("Rapido", MovementPaceScript.Value.FAST)
	add_child(movement_pace_dropdown)
	movement_pace_dropdown.item_selected.connect(_on_movement_pace_selected)

	condition_options = selector.available_options()
	for option in condition_options:
		condition_dropdown.add_item(option["label"])

func _select_condition(condition) -> void:
	if condition == null:
		condition_dropdown.select(-1)
		return

	for index in condition_options.size():
		var option: Dictionary = condition_options[index]
		if option["modality"] == condition.modality and option["query"] == condition.query:
			condition_dropdown.select(index)
			return

	condition_dropdown.select(-1)

func _on_condition_selected(index: int) -> void:
	if index < 0 or index >= condition_options.size():
		return

	var option: Dictionary = condition_options[index]
	condition_selected.emit(option["modality"], option["query"])

func _select_movement_pace(pace: int) -> void:
	for index in movement_pace_dropdown.item_count:
		if movement_pace_dropdown.get_item_id(index) == pace:
			movement_pace_dropdown.select(index)
			return
	movement_pace_dropdown.select(0)

func _on_movement_pace_selected(index: int) -> void:
	if index < 0 or index >= movement_pace_dropdown.item_count:
		return
	movement_pace_selected.emit(movement_pace_dropdown.get_item_id(index))
