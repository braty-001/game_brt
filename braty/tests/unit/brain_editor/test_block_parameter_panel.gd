extends GutTest

const BlockKind = preload("res://src/programming/domain/block_kind.gd")
const ConditionCatalogScript = preload("res://src/programming/domain/condition_catalog.gd")
const EditorBlockStateScript = preload("res://src/brain_editor/editor_block_state.gd")
const ParameterPanelScript = preload("res://src/brain_editor/block_parameter_panel.gd")

func test_action_block_disables_condition_selector() -> void:
	var panel = ParameterPanelScript.new()
	add_child_autofree(panel)
	await get_tree().process_frame

	panel.show_block(EditorBlockStateScript.new("walk", BlockKind.Value.WALK))

	assert_true(panel.condition_dropdown.disabled)
	assert_eq(panel.title_label.text, "Sem parametros")

func test_control_block_enables_condition_selector() -> void:
	var panel = ParameterPanelScript.new()
	add_child_autofree(panel)
	await get_tree().process_frame

	panel.show_block(EditorBlockStateScript.new("if", BlockKind.Value.IF))

	assert_false(panel.condition_dropdown.disabled)
	assert_eq(panel.title_label.text, "Condicao")

func test_condition_dropdown_emits_selected_condition() -> void:
	var panel = ParameterPanelScript.new()
	add_child_autofree(panel)
	watch_signals(panel)
	await get_tree().process_frame

	panel.condition_dropdown.item_selected.emit(0)

	assert_signal_emitted(panel, "condition_selected")
