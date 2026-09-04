class_name TutorialMission
extends Control

const AssemblyBenchScene = preload("res://scenes/buneko/assembly_bench.tscn")
const AttemptHudScene = preload("res://scenes/tutorial/tutorial_attempt_hud.tscn")
const BasePartsScript = preload("res://src/buneko/domain/base_buneko_parts.gd")
const BrainEditorScene = preload("res://scenes/brain_editor/brain_editor.tscn")
const BunekoAttributeResolverScript = preload("res://src/buneko/domain/buneko_attribute_resolver.gd")
const BunekoAttributesScript = preload("res://src/buneko/domain/buneko_attributes.gd")
const BunekoScene = preload("res://scenes/buneko/buneko.tscn")
const HintPresenterScript = preload("res://src/tutorial/tutorial_hint_presenter.gd")
const BrainExampleProviderScript = preload("res://src/tutorial/tutorial_brain_example_provider.gd")
const LevelScene = preload("res://scenes/tutorial/tutorial_level.tscn")
const MissionFlowScript = preload("res://src/tutorial/tutorial_mission_flow.gd")
const MissionStateScript = preload("res://src/tutorial/mission_state.gd")
const AttemptSessionScript = preload("res://src/tutorial/tutorial_attempt_session.gd")
const Tokens = preload("res://src/ui/design_tokens.gd")

var flow
var evaluator
var hint_presenter
var current_assembly
var current_graph_state
var current_program
var active_runtime
var world_sensor
var attempt_session

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
var waiting_for_jump_landing: bool:
	get:
		return attempt_session != null and attempt_session.is_waiting_for_jump_landing()

func _ready() -> void:
	_build_ui()
	_start_assembly()

func _physics_process(_delta: float) -> void:
	if evaluator == null or evaluator.state != MissionStateScript.Value.RUNNING:
		return
	if attempt_session == null:
		return

	var tick_result: int = attempt_session.tick()
	if tick_result == AttemptSessionScript.TickResult.EXECUTION_LIMIT:
		fail_from_runtime()
	elif tick_result == AttemptSessionScript.TickResult.PROGRAM_FINISHED:
		fail_from_program_end()

func install_base_assembly() -> void:
	current_assembly = BasePartsScript.complete_assembly()
	if assembly_bench != null:
		assembly_bench.install_all_base_parts()

func enter_editor() -> bool:
	if current_assembly == null:
		return false

	if not flow.enter_editing(current_assembly, current_program):
		return false
	_show_editor()
	_set_feedback("Monte o programa e execute uma tentativa quando ele estiver valido.")
	_set_hint_for_current_state()
	return true

func return_to_assembly() -> bool:
	if brain_editor != null:
		var snapshot = brain_editor.capture_snapshot()
		current_graph_state = snapshot.graph_state
		current_program = snapshot.program
	_start_assembly()
	return true

func start_attempt() -> bool:
	if brain_editor == null:
		return false

	var snapshot = brain_editor.capture_snapshot()
	current_graph_state = snapshot.graph_state
	current_program = snapshot.program
	if not ProgramValidator.validate(current_program).is_empty():
		_set_feedback("O programa ainda precisa de uma conexao valida.")
		return false
	if not flow.start_attempt(current_program):
		return false

	_show_level()
	attempt_session = AttemptSessionScript.new()
	attempt_session.action_pulse_requested.connect(_on_action_pulse_requested)
	if not attempt_session.start(current_program, buneko, level):
		flow.enter_editing(current_assembly, current_program)
		_show_editor()
		_set_feedback("Nao foi possivel iniciar este programa.")
		return false
	active_runtime = attempt_session.runtime
	world_sensor = attempt_session.world_sensor
	_set_feedback("Observe o Buneko. O programa esta no controle.")
	_set_hint_for_current_state()
	_refresh_runtime_overlay()
	return true

func pause_attempt() -> bool:
	if attempt_session == null or not attempt_session.pause():
		return false
	_refresh_runtime_overlay()
	_set_feedback("Tentativa pausada.")
	return true

func resume_attempt() -> bool:
	if attempt_session == null or not attempt_session.resume():
		return false
	_refresh_runtime_overlay()
	_set_feedback("Tentativa retomada.")
	return true

func stop_attempt() -> bool:
	if attempt_session == null or not attempt_session.stop():
		return false
	return _return_to_editor_from_attempt("Tentativa interrompida. Ajuste o programa e tente novamente.")

func return_to_editor_from_attempt() -> bool:
	if attempt_session != null and active_runtime.state != RuntimeState.Value.COMPLETED:
		attempt_session.stop()
	return _return_to_editor_from_attempt("Voce voltou para ajustar o programa.")

func fail_by_fall() -> bool:
	if not flow.fail_by_fall():
		return false

	if attempt_session != null:
		attempt_session.fail_externally()
	_show_editor()
	_set_feedback("Voce falhou: o Buneko caiu. O programa foi preservado.")
	_set_hint_for_current_state()
	return true

func complete_goal() -> bool:
	if not flow.complete_goal():
		return false

	if attempt_session != null:
		attempt_session.complete()
	_set_feedback("Objetivo concluido! O Buneko executou seu programa.")
	_set_hint_for_current_state()
	mission_header.configure("ETAPA 3/3  RESULTADO", "Atravesse o buraco e alcance o objetivo", "Concluido", "")
	_show_success_message()
	_refresh_runtime_overlay()
	return true

func fail_from_runtime() -> bool:
	if active_runtime == null:
		return false

	if active_runtime.failure_reason == RuntimeFailureReason.Value.EXECUTION_LIMIT:
		var failed: bool = flow.fail_by_execution_limit()
		_show_editor()
		_set_feedback("Voce falhou: o programa executou instrucoes demais.")
		_set_hint_for_current_state()
		return failed
	return false

func fail_from_program_end() -> bool:
	if active_runtime == null or not active_runtime.has_finished_execution():
		return false
	if not flow.fail_by_program_end():
		return false

	var false_while_block_id: String = attempt_session.false_while_with_empty_next_block_id()
	attempt_session.stop()
	_show_editor()
	if not false_while_block_id.is_empty():
		brain_editor.select_block(false_while_block_id)
		_set_feedback("O WHILE avaliou a condicao como falsa e seguiu por Depois. Como essa saida esta vazia, o programa terminou. Altere a condicao ou preencha Depois.")
	else:
		_set_feedback("O programa terminou antes de o Buneko alcancar o objetivo.")
	_set_hint_for_current_state()
	return true

func _build_ui() -> void:
	if flow == null:
		flow = MissionFlowScript.new()
	evaluator = flow.evaluator
	if hint_presenter == null:
		hint_presenter = HintPresenterScript.new()

	var background: ColorRect = get_node("Background")
	background.color = Tokens.BACKGROUND
	mission_header = get_node("Margin/Page/MissionHeader")
	stage_container = get_node("Margin/Page/StageContainer")
	var guidance: PanelContainer = get_node("Margin/Page/Guidance")
	Tokens.apply_panel(guidance, Color("202b31"))
	feedback_label = get_node("Margin/Page/Guidance/GuidanceBox/FeedbackLabel")
	feedback_label.add_theme_color_override("font_color", Tokens.TEXT)
	hint_label = get_node("Margin/Page/Guidance/GuidanceBox/HintLabel")
	hint_label.add_theme_color_override("font_color", Tokens.TEXT_MUTED)

func _start_assembly() -> void:
	flow.enter_assembly(current_assembly, current_program)
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
	brain_editor.configure_example_provider(BrainExampleProviderScript.new())
	brain_editor.set_external_attempt_runner(true)
	stage_container.add_child(brain_editor)
	brain_editor.set_anchors_preset(Control.PRESET_FULL_RECT)
	brain_editor.set_embedded_mode(true)
	brain_editor.attempt_requested.connect(_on_attempt_requested)
	brain_editor.back_to_assembly_requested.connect(_on_back_to_assembly_requested)
	brain_editor.summary_changed.connect(_on_editor_summary_changed)
	if current_graph_state != null:
		brain_editor.load_graph_state(current_graph_state)
	mission_header.configure("ETAPA 2/3  PROGRAMACAO", "Atravesse o buraco e alcance o objetivo", "Editando", "0/5 RAM")
	var snapshot = brain_editor.capture_snapshot()
	_on_editor_summary_changed(snapshot.ram, snapshot.status, snapshot.is_valid)

func _show_level() -> void:
	_clear_stage_nodes()
	level = LevelScene.instantiate()
	level.name = "TutorialLevel"
	stage_container.add_child(level)

	buneko = BunekoScene.instantiate()
	buneko.name = "Buneko"
	buneko.position = level.spawn_position
	buneko.fall_limit_y = level.fall_limit_y
	var base_attributes = BunekoAttributesScript.new(
		buneko.movement_speed,
		buneko.ground_deceleration,
		buneko.jump_impulse,
		buneko.gravity,
		buneko.strength
	)
	buneko.configure_attributes(
		BunekoAttributeResolverScript.resolve(current_assembly, base_attributes)
	)
	level.add_child(buneko)
	buneko.fell_out_of_bounds.connect(_on_fall_detected)
	level.get_node("Goal").reached.connect(complete_goal)
	level.get_node("FallZone").fallen.connect(_on_fall_detected)
	_build_attempt_hud()
	mission_header.configure("ETAPA 3/3  TESTE", "Atravesse o buraco e alcance o objetivo", "Executando", "")

func _build_attempt_hud() -> void:
	var attempt_hud = AttemptHudScene.instantiate()
	stage_container.add_child(attempt_hud)
	runtime_overlay = attempt_hud.get_node("RuntimeOverlay")
	Tokens.apply_panel(runtime_overlay, Color("202b31"))
	runtime_status_label = attempt_hud.get_node("RuntimeOverlay/Row/RuntimeStatusLabel")
	pause_button = attempt_hud.get_node("RuntimeOverlay/Row/PauseButton")
	Tokens.apply_secondary_button(pause_button)
	pause_button.pressed.connect(pause_attempt)
	resume_button = attempt_hud.get_node("RuntimeOverlay/Row/ResumeButton")
	Tokens.apply_primary_button(resume_button)
	resume_button.pressed.connect(resume_attempt)
	stop_button = attempt_hud.get_node("RuntimeOverlay/Row/StopButton")
	Tokens.apply_secondary_button(stop_button)
	stop_button.pressed.connect(_on_stop_requested)
	return_button = attempt_hud.get_node("RuntimeOverlay/Row/ReturnButton")
	Tokens.apply_secondary_button(return_button)
	return_button.pressed.connect(_on_return_requested)
	success_message = attempt_hud.get_node("SuccessMessage")
	Tokens.apply_panel(success_message, Color("183c35"))
	success_title_label = attempt_hud.get_node("SuccessMessage/Box/SuccessTitleLabel")
	success_body_label = attempt_hud.get_node("SuccessMessage/Box/SuccessBodyLabel")
	success_body_label.add_theme_color_override("font_color", Tokens.TEXT)

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
	attempt_session = null
	active_runtime = null
	world_sensor = null

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

func _on_action_pulse_requested(action_kind: int, refused: bool) -> void:
	if buneko != null:
		buneko.show_action_pulse(action_kind, refused)

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
	if not flow.enter_editing(current_assembly, current_program):
		return false
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
