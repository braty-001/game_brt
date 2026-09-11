class_name LaboratoryMission
extends Control

const LevelScene = preload("res://scenes/campaign/laboratory_level.tscn")
const AttemptScript = preload("res://src/buneko/runtime/program_attempt_session.gd")
const GraphBuilder = preload("res://src/brain_editor/program_graph_builder.gd")
const Catalog = preload("res://src/campaign/campaign_mission_catalog.gd")
const Tokens = preload("res://src/ui/design_tokens.gd")

signal editing_requested

var session
var level
var buneko
var attempt
var outcome := ""
var paused := false
var restart_count := 0
@onready var stage: Control = $Margin/Page/Stage
@onready var display: SubViewportContainer = $Margin/Page/Stage/Display
@onready var world: SubViewport = $Margin/Page/Stage/Display/World
@onready var status_label: Label = $Margin/Page/Status
@onready var pause_button: Button = $Margin/Page/Actions/PauseButton
@onready var edit_button: Button = $Margin/Page/Actions/EditButton

func configure_session(campaign_session) -> void:
	session = campaign_session

func _ready() -> void:
	$Background.color = Tokens.BACKGROUND
	Tokens.apply_secondary_button(pause_button)
	Tokens.apply_primary_button(edit_button)
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
	world.add_child(level)
	buneko = level.spawn(session.assembly, session.baton_checkpoint_active)
	attempt = AttemptScript.new()
	attempt.preserve_motion_on_pause = true
	if not attempt.begin(program, buneko, level.sensor, Catalog.INITIAL_RAM):
		_finish("invalid", "Nao foi possivel iniciar o programa.")
	else:
		attempt.action_pulse_requested.connect(buneko.show_action_pulse)

func _physics_process(_delta: float) -> void:
	if attempt == null or paused or not outcome.is_empty():
		return
	if level.reached_exit():
		attempt.complete()
		_finish("escaped", "Saida alcancada! Percurso concluido. Combate e recompensa ainda nao estao ativos.")
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
		status_label.text = "Vida %d/10 | Inimigos %d/3 | Executando: %s" % [buneko.health.current, level.living_enemy_count(), attempt.runtime.last_executed_block_id]

func toggle_pause() -> void:
	if attempt == null or not outcome.is_empty():
		return
	if paused:
		if attempt.resume():
			paused = false
			level.process_mode = Node.PROCESS_MODE_INHERIT
			pause_button.text = "Pausar"
	elif attempt.pause():
		paused = true
		level.process_mode = Node.PROCESS_MODE_DISABLED
		pause_button.text = "Continuar"
		status_label.text = "Pausado. O programa e o movimento continuam do mesmo ponto."

func _finish(result: String, message: String) -> void:
	outcome = result
	if attempt != null and result == "finished":
		attempt.stop()
	status_label.text = message
	pause_button.disabled = true
	if level != null:
		level.process_mode = Node.PROCESS_MODE_DISABLED

func _request_editing() -> void:
	if attempt != null:
		attempt.stop()
	if buneko != null:
		buneko.set_physics_process(false)
	editing_requested.emit()

func _on_baton_checkpoint_reached() -> void:
	if session == null or session.baton_checkpoint_active:
		return
	session.activate_baton_checkpoint()
	attempt.stop()
	level.set_deferred("process_mode", Node.PROCESS_MODE_DISABLED)
	status_label.text = "Bastao equipado! Abrindo o cerebro no checkpoint..."
	call_deferred("_request_checkpoint_editing")

func _request_checkpoint_editing() -> void:
	editing_requested.emit()

func _on_buneko_defeated() -> void:
	if not outcome.is_empty():
		return
	attempt.fail_externally()
	level.process_mode = Node.PROCESS_MODE_DISABLED
	status_label.text = "Buneko derrotado. Restaurando checkpoint..."
	call_deferred("_restart_from_checkpoint")

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
	outcome = ""
	restart_count += 1
	pause_button.disabled = false
	pause_button.text = "Pausar"
	_start_attempt(program)
	status_label.text = "Checkpoint restaurado: vida 10, bastao e tres inimigos reiniciados."

func _fit_world() -> void:
	var extent := Vector2(world.size)
	var factor := minf(stage.size.x / extent.x, stage.size.y / extent.y)
	display.scale = Vector2.ONE * factor
	display.position = (stage.size - extent * factor) / 2.0
