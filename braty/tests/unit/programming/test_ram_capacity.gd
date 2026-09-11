extends GutTest

const Importer = preload("res://src/brain_editor/program_graph_importer.gd")
const RamPanel = preload("res://src/brain_editor/ram_panel.gd")
const ValidationPanel = preload("res://src/brain_editor/validation_panel.gd")
const Pseudocode = preload("res://src/brain_editor/pseudocode_presenter.gd")
const EditorScene = preload("res://scenes/brain_editor/brain_editor.tscn")

func test_tutorial_default_and_campaign_boundaries_are_independent() -> void:
	assert_true(ProgramValidator.validate(_linear_program(5)).is_empty())
	assert_false(ProgramValidator.validate(_linear_program(6)).is_empty())
	assert_true(ProgramValidator.validate(_linear_program(10), 10).is_empty())
	assert_false(ProgramValidator.validate(_linear_program(11), 10).is_empty())
	assert_false(ProgramValidator.validate(_linear_program(6)).is_empty())
	assert_false(ProgramRamCalculator.is_within_limit(_linear_program(1), 0))
	assert_false(ProgramRamCalculator.is_within_limit(_linear_program(1), -10))

func test_capacity_does_not_hide_structural_errors_or_charge_disconnected_blocks() -> void:
	var program := _linear_program(10)
	program.add_block(ProgramBlock.new("unused", ProgramBlockKind.Value.WALK))
	assert_eq(ProgramRamCalculator.used_ram(program), 10)
	assert_true(ProgramValidator.validate(program, 10).is_empty())
	program.add_connection(ProgramConnection.new("block_9", "next", "block_0"))
	var errors := ProgramValidator.validate(program, 10)
	assert_true(errors.any(func(error): return error.code == ProgramValidationError.Code.ARBITRARY_CYCLE))

func test_runtime_enforces_its_capacity_on_prepare_and_restart() -> void:
	var program := _linear_program(10)
	var tutorial := ProgramRuntime.new(SensorReader.new(), ActionDispatcher.new())
	var campaign := ProgramRuntime.new(SensorReader.new(), ActionDispatcher.new(), 10)
	assert_false(tutorial.prepare(program))
	assert_true(campaign.prepare(program))
	assert_true(campaign.start())
	assert_true(campaign.restart())
	assert_eq(campaign.ram_capacity, 10)
	assert_false(campaign.prepare(_linear_program(11)))
	assert_false(campaign.start())
	assert_false(tutorial.prepare(_linear_program(6)))

func test_panels_and_pseudocode_use_the_same_capacity() -> void:
	var program := _linear_program(10)
	var graph = Importer.new().import_program(program)
	assert_eq(RamPanel.new().summary_for_program(program, 10)["label"], "10/10 RAM")
	assert_true(ValidationPanel.new().summary_for_program(program, 10)["is_valid"])
	assert_true(Pseudocode.new().present(graph, 10)["is_valid"])
	assert_false(Pseudocode.new().present(graph)["is_valid"])
	var exceeded: Dictionary = ValidationPanel.new().summary_for_program(_linear_program(11), 10)
	assert_false(exceeded["is_valid"])
	assert_has(exceeded["messages"], "O programa conectado ultrapassa 10 RAM.")

func test_campaign_editor_rejects_eleven_and_recovers_after_removal() -> void:
	var editor = EditorScene.instantiate()
	assert_true(editor.configure_ram_capacity(10))
	editor.configure_preparation_mode()
	add_child_autofree(editor)
	await get_tree().process_frame
	editor.load_graph_state(Importer.new().import_program(_linear_program(11)))
	assert_eq(editor.capture_snapshot().ram, "11/10 RAM")
	assert_string_contains(editor.validation_label.text, "10 RAM")
	assert_false(editor.capture_snapshot().is_valid)
	assert_true(editor.start_button.disabled)
	watch_signals(editor)
	editor.start_button.pressed.emit()
	assert_signal_not_emitted(editor, "attempt_requested")
	editor.select_block("block_10")
	assert_true(editor.remove_selected_block())
	assert_true(editor.capture_snapshot().is_valid)
	assert_eq(editor.capture_snapshot().ram, "10/10 RAM")
	assert_false(editor.start_button.disabled)
	assert_true(editor.pseudocode_presenter.present(editor.graph_state, editor.ram_capacity)["is_valid"])
	editor.start_button.pressed.emit()
	assert_signal_emitted(editor, "attempt_requested")
	assert_eq(editor.runtime.state, RuntimeState.Value.EDITING)
	assert_false(editor.configure_ram_capacity(5))

func _linear_program(count: int) -> ProgramDefinition:
	var program := ProgramDefinition.new()
	program.start_block_id = "block_0"
	for index in count:
		var block_id := "block_%d" % index
		program.add_block(ProgramBlock.new(block_id, ProgramBlockKind.Value.WALK))
		if index > 0:
			program.add_connection(ProgramConnection.new("block_%d" % (index - 1), "next", block_id))
	return program
