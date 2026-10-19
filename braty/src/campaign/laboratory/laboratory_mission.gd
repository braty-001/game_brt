class_name LaboratoryMission
extends Control

const LevelScene = preload("res://scenes/campaign/laboratory_level.tscn")
const AttemptScript = preload("res://src/buneko/runtime/program_attempt_session.gd")
const GraphBuilder = preload("res://src/brain_editor/program_graph_builder.gd")
const Catalog = preload("res://src/campaign/campaign_mission_catalog.gd")
const Tokens = preload("res://src/ui/design_tokens.gd")

const IMPACT_PAUSE_MSEC := 60
const DEFEAT_PRESENTATION_MSEC := 600

signal editing_requested
signal selection_requested

var session
var level
var buneko
var attempt
var outcome := ""
var paused := false
var restart_count := 0
var last_restart_position := Vector2.INF
var impact_pause_active := false
var defeat_presentation_active := false
var _impact_deadline_msec := 0
var _defeat_deadline_msec := 0
var _defeat_pending := false
var _defeat_ready_to_restart := false
var _resume_after_impact := false
var _navigation_requested := false
@onready var stage: Control = $Margin/Page/Stage
@onready var display: SubViewportContainer = $Margin/Page/Stage/Display
@onready var world: SubViewport = $Margin/Page/Stage/Display/World
@onready var status_label: Label = $Margin/Page/Status
@onready var pause_button: Button = $Margin/Page/Actions/PauseButton
@onready var edit_button: Button = $Margin/Page/Actions/EditButton
@onready var milestone_overlay: Control = $MilestoneOverlay
@onready var milestone_panel: PanelContainer = $MilestoneOverlay/Center/Panel
@onready var milestone_title: Label = $MilestoneOverlay/Center/Panel/Content/Title
@onready var milestone_description: Label = $MilestoneOverlay/Center/Panel/Content/Description
@onready var milestone_primary: Button = $MilestoneOverlay/Center/Panel/Content/Actions/Primary
@onready var milestone_secondary: Button = $MilestoneOverlay/Center/Panel/Content/Actions/Secondary

func configure_session(campaign_session) -> void:
	session = campaign_session

func _ready() -> void:
	$Background.color = Tokens.BACKGROUND
	Tokens.apply_secondary_button(pause_button)
	Tokens.apply_primary_button(edit_button)
	Tokens.apply_panel(milestone_panel, Tokens.SURFACE_RAISED)
	Tokens.apply_primary_button(milestone_primary)
	Tokens.apply_secondary_button(milestone_secondary)
	milestone_title.add_theme_color_override("font_color", Tokens.SUCCESS)
	milestone_primary.pressed.connect(_on_milestone_primary_pressed)
	milestone_secondary.pressed.connect(_on_milestone_secondary_pressed)
	pause_button.pressed.connect(toggle_pause)
	edit_button.pressed.connect(_request_editing)
	stage.resized.connect(_fit_world)
	world.world_2d = World2D.new()
	_fit_world()
	if session == null or not session.can_prepare_mission(Catalog.LABORATORY_ID) or not session.preparation_confirmed or session.graph_state == null:
		_finish("invalid", "Prepare e confirme o cerebro antes de entrar.")
		return
	var program = GraphBuilder.new().build(session.graph_state)
	if not session.program_can_run(program):
		_finish("invalid", "Programa invalido. Volte ao cerebro para revisar.")
		return
	_start_attempt(program)

func _start_attempt(program) -> void:
	level = LevelScene.instantiate()
	level.baton_checkpoint_reached.connect(_on_baton_checkpoint_reached)
	level.buneko_defeated.connect(_on_buneko_defeated)
	level.combat_batch_resolved.connect(_on_combat_batch_resolved)
	world.add_child(level)
	buneko = level.spawn(session.assembly, session.baton_checkpoint_active)
	attempt = AttemptScript.new()
	attempt.preserve_motion_on_pause = true
	if not attempt.begin(program, buneko, level.sensor, Catalog.INITIAL_RAM):
		_finish("invalid", "Nao foi possivel iniciar o programa.")
	else:
		attempt.action_pulse_requested.connect(buneko.show_action_pulse)

func _process(_delta: float) -> void:
	var now := Time.get_ticks_msec()
	if impact_pause_active and now >= _impact_deadline_msec:
		_finish_impact_pause()
	if defeat_presentation_active and not _defeat_ready_to_restart and now >= _defeat_deadline_msec:
		if paused:
			_defeat_ready_to_restart = true
			status_label.text = "Derrota apresentada. Continue para restaurar o checkpoint."
		else:
			_finish_defeat_presentation()

func _physics_process(_delta: float) -> void:
	if attempt == null or milestone_overlay.visible or _navigation_requested or paused or impact_pause_active or defeat_presentation_active or not outcome.is_empty():
		return
	if level.reached_exit():
		attempt.complete()
		_finish("escaped", "Voce escapou do laboratorio.")
		return
	if buneko.position.y > level.WORLD_SIZE.y + 60:
		attempt.fail_externally()
		_finish("fell", "O Buneko caiu. Revise o cerebro e tente novamente.")
		return
	var result: int = attempt.tick()
	if result == AttemptScript.TickResult.EXECUTION_LIMIT:
		_finish("guard", "Execucao interrompida: rotina sem progresso. Revise o cerebro.")
	elif result == AttemptScript.TickResult.PROGRAM_FINISHED:
		_finish("finished", "O programa terminou antes da saida. Volte ao cerebro para revisar.")
	else:
		status_label.text = "Vida %d/10 | Inimigos %d/3 | Executando: %s" % [buneko.current_health(), level.living_enemy_count(), attempt.runtime.last_executed_block_id]

func toggle_pause() -> void:
	if attempt == null or milestone_overlay.visible or _navigation_requested or not outcome.is_empty():
		return
	if paused:
		paused = false
		pause_button.text = "Pausar"
		if defeat_presentation_active and _defeat_ready_to_restart:
			_finish_defeat_presentation()
		elif impact_pause_active or defeat_presentation_active:
			status_label.text = "Apresentacao de combate em andamento."
		elif attempt.resume():
			paused = false
			level.process_mode = Node.PROCESS_MODE_INHERIT
			level.set_simulation_suspended(false)
			pause_button.text = "Pausar"
	elif impact_pause_active or defeat_presentation_active:
		paused = true
		pause_button.text = "Continuar"
		status_label.text = "Pausado. A tentativa nao retomara ao fim do efeito."
	elif attempt.pause():
		paused = true
		level.process_mode = Node.PROCESS_MODE_DISABLED
		level.stop_presentation_audio()
		pause_button.text = "Continuar"
		status_label.text = "Pausado. O programa e o movimento continuam do mesmo ponto."

func _finish(result: String, message: String) -> void:
	_cancel_combat_presentation()
	outcome = result
	if attempt != null and result == "finished":
		attempt.stop()
	status_label.text = message
	pause_button.disabled = true
	if level != null:
		level.set_simulation_suspended(true)
		level.process_mode = Node.PROCESS_MODE_DISABLED
	if result == "escaped":
		_show_milestone("Missao concluida!", message, "Voltar a selecao", true)

func _request_editing() -> void:
	if milestone_overlay.visible:
		return
	_request_navigation(true)

func _request_navigation(open_editor: bool) -> void:
	if _navigation_requested:
		return
	_navigation_requested = true
	pause_button.disabled = true
	edit_button.disabled = true
	milestone_primary.disabled = true
	milestone_secondary.disabled = true
	_cancel_combat_presentation()
	if attempt != null:
		attempt.stop()
	if level != null:
		level.set_simulation_suspended(true)
		level.process_mode = Node.PROCESS_MODE_DISABLED
	if buneko != null:
		buneko.set_physics_process(false)
	if open_editor:
		editing_requested.emit()
	else:
		selection_requested.emit()

func _on_baton_checkpoint_reached() -> void:
	if session == null or session.baton_checkpoint_active or _navigation_requested or not outcome.is_empty():
		return
	session.activate_baton_checkpoint()
	_cancel_combat_presentation()
	attempt.stop()
	level.set_simulation_suspended(true)
	level.set_deferred("process_mode", Node.PROCESS_MODE_DISABLED)
	status_label.text = "Bastao equipado. Checkpoint ativado."
	_show_milestone(
		"Bastao adquirido!",
		"Atacar e as condicoes de inimigo visivel e inimigo ao alcance estao liberados.\nSe for derrotado, voltara a este checkpoint com o bastao e seu programa.",
		"Editar cerebro"
	)

func _show_milestone(title: String, description: String, primary_text: String, show_secondary := false) -> void:
	milestone_title.text = title
	milestone_description.text = description
	milestone_primary.text = primary_text
	milestone_secondary.visible = show_secondary
	pause_button.disabled = true
	edit_button.disabled = true
	milestone_overlay.show()
	var other: Button = milestone_secondary if show_secondary else milestone_primary
	milestone_primary.focus_next = milestone_primary.get_path_to(other)
	milestone_primary.focus_previous = milestone_primary.get_path_to(other)
	milestone_primary.grab_focus()

func _on_milestone_primary_pressed() -> void:
	if milestone_overlay.visible:
		_request_navigation(outcome != "escaped")

func _on_milestone_secondary_pressed() -> void:
	if milestone_overlay.visible and outcome == "escaped":
		_request_navigation(true)

func _on_buneko_defeated() -> void:
	if milestone_overlay.visible or _navigation_requested or not outcome.is_empty():
		return
	attempt.fail_externally()
	_defeat_pending = true
	level.set_simulation_suspended(true)
	status_label.text = "Buneko derrotado. Confirmando o impacto..."
	if not impact_pause_active:
		_begin_defeat_presentation()

func _on_combat_batch_resolved(results: Array) -> void:
	if milestone_overlay.visible or _navigation_requested or not outcome.is_empty() or impact_pause_active or defeat_presentation_active:
		return
	if not results.any(func(result): return bool(result.get("hit", false))):
		return
	impact_pause_active = true
	_impact_deadline_msec = Time.get_ticks_msec() + IMPACT_PAUSE_MSEC
	_resume_after_impact = attempt != null and not paused and attempt.pause()
	level.set_simulation_suspended(true)
	status_label.text = "Impacto!"

func _finish_impact_pause() -> void:
	impact_pause_active = false
	_impact_deadline_msec = 0
	if _defeat_pending:
		_begin_defeat_presentation()
		return
	level.set_simulation_suspended(false)
	if paused:
		level.process_mode = Node.PROCESS_MODE_DISABLED
		status_label.text = "Pausado. O programa e o movimento continuam do mesmo ponto."
	elif _resume_after_impact and attempt != null:
		attempt.resume()
	_resume_after_impact = false

func _begin_defeat_presentation() -> void:
	impact_pause_active = false
	defeat_presentation_active = true
	_defeat_deadline_msec = Time.get_ticks_msec() + DEFEAT_PRESENTATION_MSEC
	level.set_simulation_suspended(true)
	status_label.text = "Buneko derrotado. Restaurando checkpoint..."

func _finish_defeat_presentation() -> void:
	defeat_presentation_active = false
	_defeat_deadline_msec = 0
	_defeat_pending = false
	_restart_from_checkpoint()

func _cancel_combat_presentation() -> void:
	impact_pause_active = false
	defeat_presentation_active = false
	_impact_deadline_msec = 0
	_defeat_deadline_msec = 0
	_defeat_pending = false
	_defeat_ready_to_restart = false
	_resume_after_impact = false
	if level != null and is_instance_valid(level):
		level.stop_presentation_audio()
		level.set_simulation_suspended(false)

func _restart_from_checkpoint() -> void:
	if session == null or not session.baton_checkpoint_active or session.graph_state == null:
		_finish("defeated", "Buneko derrotado. Volte ao cerebro para tentar novamente.")
		return
	var program = GraphBuilder.new().build(session.graph_state)
	if not session.program_can_run(program):
		_finish("invalid", "O programa salvo no checkpoint ficou invalido.")
		return
	world.remove_child(level)
	level.queue_free()
	level = null
	buneko = null
	attempt = null
	paused = false
	_cancel_combat_presentation()
	outcome = ""
	restart_count += 1
	pause_button.disabled = false
	pause_button.text = "Pausar"
	_start_attempt(program)
	last_restart_position = buneko.position
	status_label.text = "Checkpoint restaurado: vida 10, bastao e tres inimigos reiniciados."

func _fit_world() -> void:
	var extent := Vector2(world.size)
	var factor := minf(stage.size.x / extent.x, stage.size.y / extent.y)
	display.scale = Vector2.ONE * factor
	display.position = (stage.size - extent * factor) / 2.0
