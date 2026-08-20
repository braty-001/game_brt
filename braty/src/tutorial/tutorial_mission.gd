class_name TutorialMission
extends Control

const AssemblyBenchScene = preload("res://scenes/buneko/assembly_bench.tscn")
const BasePartsScript = preload("res://src/buneko/domain/base_buneko_parts.gd")
const BlockKind = preload("res://src/programming/domain/block_kind.gd")
const BrainEditorScene = preload("res://scenes/brain_editor/brain_editor.tscn")
const BunekoActionDispatcherScript = preload("res://src/buneko/runtime/buneko_action_dispatcher.gd")
const BunekoScene = preload("res://scenes/buneko/buneko.tscn")
const BunekoSensorReaderScript = preload("res://src/buneko/runtime/buneko_sensor_reader.gd")
const EvaluatorScript = preload("res://src/tutorial/tutorial_objective_evaluator.gd")
const HintPresenterScript = preload("res://src/tutorial/tutorial_hint_presenter.gd")
const LevelScene = preload("res://scenes/tutorial/tutorial_level.tscn")
const MissionHeaderScript = preload("res://src/ui/mission_step_header.gd")
const MissionStateScript = preload("res://src/tutorial/mission_state.gd")
const ProgramRuntimeScript = preload("res://src/programming/runtime/program_runtime.gd")
const RuntimeFailureReasonScript = preload("res://src/programming/runtime/runtime_failure_reason.gd")
const Tokens = preload("res://src/ui/design_tokens.gd")
const WorldSensorScript = preload("res://src/tutorial/tutorial_world_sensor.gd")

var evaluator
var hint_presenter
var current_assembly
var current_graph_state
var current_program
var active_runtime
var world_sensor

var assembly_bench
var brain_editor
var level
var buneko
var mission_header
var stage_container: Control
var feedback_label: Label
var hint_label: Label
var runtime_overlay: PanelContainer
var runtime_status_label: Label
var success_message: PanelContainer
var success_title_label: Label
var success_body_label: Label
var pause_button: Button
var resume_button: Button
var stop_button: Button
var return_button: Button
var last_visual_action_kind := -1
var waiting_for_jump_landing := false
var jump_has_left_ground := false

func _ready() -> void:
	_build_ui()
	_start_assembly()

func _physics_process(_delta: float) -> void:
	if evaluator == null or evaluator.state != MissionStateScript.Value.RUNNING:
		return
	if active_runtime == null or buneko == null:
		return

	world_sensor.update_from_buneko(buneko)
	if _is_waiting_for_jump_landing():
		return
	var previous_block_id: String = active_runtime.last_executed_block_id
	var previous_refused_block_id: String = active_runtime.last_refused_action_block_id
	active_runtime.tick()
	_track_accepted_jump(previous_block_id)
	_present_action_pulse(previous_block_id, previous_refused_block_id)
	if active_runtime.failure_reason == RuntimeFailureReasonScript.Value.EXECUTION_LIMIT:
		fail_from_runtime()

func install_base_assembly() -> void:
	current_assembly = BasePartsScript.complete_assembly()
	if assembly_bench != null:
		assembly_bench.install_all_base_parts()

func enter_editor() -> bool:
	if current_assembly == null:
		return false

	evaluator.enter_editing(current_assembly, current_program)
	_show_editor()
	_set_feedback("Monte o programa e execute uma tentativa quando ele estiver valido.")
	_set_hint_for_current_state()
	return true

func return_to_assembly() -> bool:
	if brain_editor != null:
		current_graph_state = brain_editor.graph_state
		current_program = brain_editor.current_program()
	evaluator.state = MissionStateScript.Value.ASSEMBLY
	_start_assembly()
	return true

func start_attempt() -> bool:
	if brain_editor == null:
		return false

	current_graph_state = brain_editor.graph_state
	current_program = brain_editor.current_program()
	if not ProgramValidator.validate(current_program).is_empty():
		_set_feedback("O programa ainda precisa de uma conexao valida.")
		return false
	if not evaluator.start_attempt(current_program):
		return false

	_show_level()
	world_sensor = WorldSensorScript.new()
	world_sensor.gap_start_x = level.gap_start_x
	world_sensor.gap_end_x = level.gap_end_x
	world_sensor.goal_position = level.goal_position
	var sensor_reader = BunekoSensorReaderScript.new(world_sensor)
	var dispatcher = BunekoActionDispatcherScript.new(buneko)
	active_runtime = ProgramRuntimeScript.new(sensor_reader, dispatcher)
	if not active_runtime.prepare(current_program) or not active_runtime.start():
		evaluator.enter_editing(current_assembly, current_program)
		_show_editor()
		_set_feedback("Nao foi possivel iniciar este programa.")
		return false
	_set_feedback("Observe o Buneko. O programa esta no controle.")
	_set_hint_for_current_state()
	_refresh_runtime_overlay()
	return true

func pause_attempt() -> bool:
	if active_runtime == null or not active_runtime.pause():
		return false
	if buneko != null and buneko.controller != null:
		buneko.controller.stop_horizontal()
	_refresh_runtime_overlay()
	_set_feedback("Tentativa pausada.")
	return true

func resume_attempt() -> bool:
	if active_runtime == null or not active_runtime.resume():
		return false
	_refresh_runtime_overlay()
	_set_feedback("Tentativa retomada.")
	return true

func stop_attempt() -> bool:
	if active_runtime == null or not active_runtime.stop():
		return false
	return _return_to_editor_from_attempt("Tentativa interrompida. Ajuste o programa e tente novamente.")

func return_to_editor_from_attempt() -> bool:
	if active_runtime != null and active_runtime.state != RuntimeState.Value.COMPLETED:
		active_runtime.stop()
	return _return_to_editor_from_attempt("Voce voltou para ajustar o programa.")

func fail_by_fall() -> bool:
	if not evaluator.fail_by_fall():
		return false

	if active_runtime != null:
		active_runtime.fail_externally()
	_show_editor()
	_set_feedback("Voce falhou: o Buneko caiu. O programa foi preservado.")
	_set_hint_for_current_state()
	return true

func complete_goal() -> bool:
	if not evaluator.complete_goal():
		return false

	if active_runtime != null:
		active_runtime.complete()
	_set_feedback("Objetivo concluido! O Buneko executou seu programa.")
	_set_hint_for_current_state()
	mission_header.configure("ETAPA 3/3  RESULTADO", "Atravesse o buraco e alcance o objetivo", "Concluido", "")
	_show_success_message()
	_refresh_runtime_overlay()
	return true

func fail_from_runtime() -> bool:
	if active_runtime == null:
		return false

	if active_runtime.failure_reason == RuntimeFailureReasonScript.Value.EXECUTION_LIMIT:
		var failed: bool = evaluator.fail_by_execution_limit()
		_show_editor()
		_set_feedback("Voce falhou: o programa executou instrucoes demais.")
		_set_hint_for_current_state()
		return failed
	return false

func _build_ui() -> void:
	if evaluator == null:
		evaluator = EvaluatorScript.new()
	if hint_presenter == null:
		hint_presenter = HintPresenterScript.new()

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
	margin.add_theme_constant_override("margin_left", 10)
	margin.add_theme_constant_override("margin_right", 10)
	margin.add_theme_constant_override("margin_top", 8)
	margin.add_theme_constant_override("margin_bottom", 8)
	add_child(margin)

	var page := VBoxContainer.new()
	page.add_theme_constant_override("separation", 8)
	margin.add_child(page)

	mission_header = MissionHeaderScript.new()
	mission_header.name = "MissionHeader"
	page.add_child(mission_header)

	stage_container = Control.new()
	stage_container.name = "StageContainer"
	stage_container.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	stage_container.size_flags_vertical = Control.SIZE_EXPAND_FILL
	stage_container.clip_contents = true
	page.add_child(stage_container)

	var guidance := PanelContainer.new()
	guidance.custom_minimum_size.y = 58.0
	Tokens.apply_panel(guidance, Color("202b31"))
	page.add_child(guidance)
	var guidance_box := VBoxContainer.new()
	guidance.add_child(guidance_box)
	feedback_label = Label.new()
	feedback_label.name = "FeedbackLabel"
	feedback_label.add_theme_color_override("font_color", Tokens.TEXT)
	guidance_box.add_child(feedback_label)
	hint_label = Label.new()
	hint_label.name = "HintLabel"
	hint_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	hint_label.add_theme_color_override("font_color", Tokens.TEXT_MUTED)
	guidance_box.add_child(hint_label)

func _start_assembly() -> void:
	evaluator.state = MissionStateScript.Value.ASSEMBLY
	_clear_stage_nodes()
	assembly_bench = AssemblyBenchScene.instantiate()
	assembly_bench.name = "AssemblyBench"
	if current_assembly != null:
		assembly_bench.assembly = current_assembly
	stage_container.add_child(assembly_bench)
	assembly_bench.set_anchors_preset(Control.PRESET_FULL_RECT)
	assembly_bench.assembly_confirmed.connect(_on_assembly_confirmed)
	mission_header.configure("ETAPA 1/3  MONTAGEM", "Prepare o Buneko para atravessar o buraco", "Montando", "")
	_set_feedback("Instale as tres pecas para liberar a programacao.")
	_set_hint_for_current_state()

func _show_editor() -> void:
	_clear_stage_nodes()
	brain_editor = BrainEditorScene.instantiate()
	brain_editor.name = "BrainEditor"
	stage_container.add_child(brain_editor)
	brain_editor.set_anchors_preset(Control.PRESET_FULL_RECT)
	brain_editor.set_external_attempt_runner(true)
	brain_editor.set_embedded_mode(true)
	brain_editor.attempt_requested.connect(_on_attempt_requested)
	brain_editor.back_to_assembly_requested.connect(_on_back_to_assembly_requested)
	brain_editor.summary_changed.connect(_on_editor_summary_changed)
	if current_graph_state != null:
		brain_editor.load_graph_state(current_graph_state)
	mission_header.configure("ETAPA 2/3  PROGRAMACAO", "Atravesse o buraco e alcance o objetivo", "Editando", "0/5 RAM")
	_on_editor_summary_changed(brain_editor.ram_label.text, brain_editor.state_label.text, not brain_editor.start_button.disabled)

func _show_level() -> void:
	_clear_stage_nodes()
	level = LevelScene.instantiate()
	level.name = "TutorialLevel"
	stage_container.add_child(level)

	buneko = BunekoScene.instantiate()
	buneko.name = "Buneko"
	buneko.position = level.spawn_position
	buneko.fall_limit_y = level.fall_limit_y
	level.add_child(buneko)
	buneko.fell_out_of_bounds.connect(_on_fall_detected)
	level.get_node("Goal").reached.connect(complete_goal)
	level.get_node("FallZone").fallen.connect(_on_fall_detected)
	_build_runtime_overlay()
	_build_success_message()
	mission_header.configure("ETAPA 3/3  TESTE", "Atravesse o buraco e alcance o objetivo", "Executando", "")

func _build_runtime_overlay() -> void:
	runtime_overlay = PanelContainer.new()
	runtime_overlay.name = "RuntimeOverlay"
	runtime_overlay.set_anchors_preset(Control.PRESET_BOTTOM_WIDE)
	runtime_overlay.offset_left = 18.0
	runtime_overlay.offset_right = -18.0
	runtime_overlay.offset_top = -68.0
	runtime_overlay.offset_bottom = -12.0
	Tokens.apply_panel(runtime_overlay, Color("202b31"))
	stage_container.add_child(runtime_overlay)
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 8)
	runtime_overlay.add_child(row)
	runtime_status_label = Label.new()
	runtime_status_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	runtime_status_label.text = "Programa em execucao"
	row.add_child(runtime_status_label)
	pause_button = Button.new()
	pause_button.text = "Pausar"
	Tokens.apply_secondary_button(pause_button)
	pause_button.pressed.connect(pause_attempt)
	row.add_child(pause_button)
	resume_button = Button.new()
	resume_button.text = "Retomar"
	Tokens.apply_primary_button(resume_button)
	resume_button.pressed.connect(resume_attempt)
	row.add_child(resume_button)
	stop_button = Button.new()
	stop_button.text = "Parar e editar"
	Tokens.apply_secondary_button(stop_button)
	stop_button.pressed.connect(_on_stop_requested)
	row.add_child(stop_button)
	return_button = Button.new()
	return_button.name = "ReturnButton"
	return_button.text = "Voltar"
	return_button.tooltip_text = "Volta para o editor mantendo o programa atual"
	Tokens.apply_secondary_button(return_button)
	return_button.pressed.connect(_on_return_requested)
	row.add_child(return_button)

func _build_success_message() -> void:
	success_message = PanelContainer.new()
	success_message.name = "SuccessMessage"
	success_message.visible = false
	success_message.anchor_left = 0.5
	success_message.anchor_right = 0.5
	success_message.anchor_top = 0.0
	success_message.anchor_bottom = 0.0
	success_message.offset_left = -210.0
	success_message.offset_right = 210.0
	success_message.offset_top = 18.0
	success_message.offset_bottom = 104.0
	Tokens.apply_panel(success_message, Color("183c35"))
	stage_container.add_child(success_message)

	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 4)
	success_message.add_child(box)

	success_title_label = Label.new()
	success_title_label.name = "SuccessTitleLabel"
	success_title_label.text = "Objetivo concluido!"
	success_title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	success_title_label.add_theme_color_override("font_color", Tokens.SUCCESS)
	success_title_label.add_theme_font_size_override("font_size", 24)
	box.add_child(success_title_label)

	success_body_label = Label.new()
	success_body_label.name = "SuccessBodyLabel"
	success_body_label.text = "O Buneko chegou ao final da fase."
	success_body_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	success_body_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	success_body_label.add_theme_color_override("font_color", Tokens.TEXT)
	box.add_child(success_body_label)

func _refresh_runtime_overlay() -> void:
	if runtime_overlay == null or active_runtime == null:
		return
	pause_button.visible = active_runtime.state == RuntimeState.Value.RUNNING
	resume_button.visible = active_runtime.state == RuntimeState.Value.PAUSED
	stop_button.visible = active_runtime.state == RuntimeState.Value.RUNNING or active_runtime.state == RuntimeState.Value.PAUSED
	return_button.visible = active_runtime.state == RuntimeState.Value.RUNNING or active_runtime.state == RuntimeState.Value.PAUSED or active_runtime.state == RuntimeState.Value.COMPLETED
	if active_runtime.state == RuntimeState.Value.COMPLETED:
		runtime_status_label.text = "Objetivo concluido"
		runtime_status_label.add_theme_color_override("font_color", Tokens.SUCCESS)

func _clear_stage_nodes() -> void:
	if stage_container != null:
		for child in stage_container.get_children():
			stage_container.remove_child(child)
			child.free()
	assembly_bench = null
	brain_editor = null
	level = null
	buneko = null
	runtime_overlay = null
	runtime_status_label = null
	success_message = null
	success_title_label = null
	success_body_label = null
	pause_button = null
	resume_button = null
	stop_button = null
	return_button = null
	last_visual_action_kind = -1
	waiting_for_jump_landing = false
	jump_has_left_ground = false

func _set_feedback(message: String) -> void:
	if feedback_label != null:
		feedback_label.text = message

func _on_assembly_confirmed(assembly) -> void:
	current_assembly = assembly
	call_deferred("_enter_editor_after_confirmation")

func _enter_editor_after_confirmation() -> void:
	enter_editor()

func _on_attempt_requested() -> void:
	call_deferred("_start_attempt_from_ui")

func _on_editor_summary_changed(ram: String, status: String, _is_valid: bool) -> void:
	if evaluator.state == MissionStateScript.Value.EDITING or evaluator.state == MissionStateScript.Value.FAILED:
		mission_header.set_ram(ram)
		mission_header.set_status(status)

func _start_attempt_from_ui() -> void:
	start_attempt()

func _on_back_to_assembly_requested() -> void:
	call_deferred("return_to_assembly")

func _on_stop_requested() -> void:
	call_deferred("stop_attempt")

func _on_return_requested() -> void:
	call_deferred("return_to_editor_from_attempt")

func _present_action_pulse(previous_block_id: String, previous_refused_block_id: String) -> void:
	if buneko == null:
		return
	if not active_runtime.last_refused_action_block_id.is_empty() and active_runtime.last_refused_action_block_id != previous_refused_block_id:
		buneko.show_action_pulse(active_runtime.last_refused_action_kind, true)
		return
	if active_runtime.last_executed_block_id == previous_block_id:
		return
	if current_program == null or not current_program.blocks.has(active_runtime.last_executed_block_id):
		return
	var action_kind: int = current_program.blocks[active_runtime.last_executed_block_id].kind
	if BlockKind.requires_condition(action_kind) or action_kind == last_visual_action_kind:
		return
	last_visual_action_kind = action_kind
	buneko.show_action_pulse(action_kind)

func _is_waiting_for_jump_landing() -> bool:
	if not waiting_for_jump_landing:
		return false
	if not buneko.is_on_floor():
		jump_has_left_ground = true
		return true
	if not jump_has_left_ground:
		return true
	waiting_for_jump_landing = false
	jump_has_left_ground = false
	return false

func _track_accepted_jump(previous_block_id: String) -> void:
	if active_runtime.last_executed_block_id == previous_block_id:
		return
	if current_program == null or not current_program.blocks.has(active_runtime.last_executed_block_id):
		return
	if current_program.blocks[active_runtime.last_executed_block_id].kind != BlockKind.Value.JUMP:
		return
	if active_runtime.last_refused_action_block_id == active_runtime.last_executed_block_id:
		return
	waiting_for_jump_landing = true
	jump_has_left_ground = false

func _on_fall_detected() -> void:
	call_deferred("_fail_from_detected_fall")

func _fail_from_detected_fall() -> void:
	if evaluator.state == MissionStateScript.Value.RUNNING:
		fail_by_fall()

func _set_hint_for_current_state() -> void:
	if hint_label == null or hint_presenter == null or evaluator == null:
		return
	hint_label.text = hint_presenter.hint_for(evaluator.state, evaluator.result.kind, _current_program_block_count())

func _show_success_message() -> void:
	if success_message != null:
		success_message.visible = true

func _return_to_editor_from_attempt(message: String) -> bool:
	if current_assembly == null or current_program == null:
		return false
	evaluator.enter_editing(current_assembly, current_program)
	_show_editor()
	_set_feedback(message)
	_set_hint_for_current_state()
	return true

func _current_program_block_count() -> int:
	if current_program != null:
		return current_program.blocks.size()
	if current_graph_state != null:
		return current_graph_state.blocks.size()
	return 0
