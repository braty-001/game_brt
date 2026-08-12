class_name BrainEditorBlockParameterPanel
extends VBoxContainer

const ConditionSelectorScript = preload("res://src/brain_editor/condition_selector.gd")

signal condition_selected(modality: int, query: int)

var selector
var condition_options: Array = []
var title_label: Label
var condition_dropdown: OptionButton

func _ready() -> void:
	if selector == null:
		selector = ConditionSelectorScript.new()
	_build_ui()
	show_no_selection()

func show_no_selection() -> void:
	_build_ui()
	title_label.text = "Parametros"
	condition_dropdown.disabled = true
	condition_dropdown.select(-1)

func show_block(block_state) -> void:
	_build_ui()
	if block_state == null:
		show_no_selection()
		return

	if ProgramBlockKind.requires_condition(block_state.kind):
		title_label.text = "Condicao"
		condition_dropdown.disabled = false
		_select_condition(block_state.condition)
	else:
		title_label.text = "Sem parametros"
		condition_dropdown.disabled = true
		condition_dropdown.select(-1)

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
