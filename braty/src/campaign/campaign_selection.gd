class_name CampaignSelection
extends Control

const Catalog = preload("res://src/campaign/campaign_mission_catalog.gd")
const BrainEditorScene = preload("res://scenes/brain_editor/brain_editor.tscn")
const Tokens = preload("res://src/ui/design_tokens.gd")
const LaboratoryExamples = preload("res://src/campaign/laboratory/laboratory_example_provider.gd")

signal menu_requested
signal mission_requested
signal progress_changed

var session
var brain_editor
var save_error := false
@onready var briefing: Control = $Margin/Page/Briefing
@onready var editor_host: Control = $Margin/Page/EditorHost
@onready var status_label: Label = $Margin/Page/StatusLabel
@onready var balance_label: Label = $Margin/Page/Header/BalanceLabel
@onready var prepare_button: Button = $Margin/Page/Briefing/Actions/PrepareButton
@onready var menu_button: Button = $Margin/Page/Header/MenuButton
@onready var enter_button: Button = $Margin/Page/Briefing/Actions/EnterButton

func configure_session(campaign_session) -> void:
	session = campaign_session

func _ready() -> void:
	$Background.color = Tokens.BACKGROUND
	var data := Catalog.laboratory_briefing()
	$Margin/Page/Header/Title.text = data["title"]
	var info: VBoxContainer = $Margin/Page/Briefing/Content/DetailsScroll/Details
	info.get_node("Objective").text = data["objective"]
	info.get_node("Route").text = data["route"]
	info.get_node("Equipment").text = data["equipment"]
	info.get_node("Checkpoint").text = data["checkpoint"]
	info.get_node("Reward").text = data["reward"]
	balance_label.text = "Saldo: %d moedas" % (session.money if session != null else 0)
	balance_label.add_theme_color_override("font_color", Tokens.AMBER)
	info.get_node("Checkpoint").add_theme_color_override("font_color", Tokens.AMBER)
	Tokens.apply_primary_button(prepare_button)
	Tokens.apply_secondary_button(menu_button)
	Tokens.apply_primary_button(enter_button)
	enter_button.pressed.connect(_on_enter_pressed)
	prepare_button.pressed.connect(open_preparation)
	menu_button.pressed.connect(_on_menu_pressed)
	_refresh_briefing()

func open_preparation() -> bool:
	if session == null or not session.can_prepare_mission(Catalog.LABORATORY_ID):
		return false
	if brain_editor != null:
		return false
	brain_editor = BrainEditorScene.instantiate()
	brain_editor.configure_ram_capacity(Catalog.INITIAL_RAM)
	brain_editor.configure_preparation_mode()
	var combat_available: bool = session.baton_checkpoint_active
	brain_editor.configure_example_provider(LaboratoryExamples.new(combat_available))
	var queries: Array[int] = [
		ConditionCatalog.Query.PATH_CLEAR_AHEAD, ConditionCatalog.Query.GAP_AHEAD,
		ConditionCatalog.Query.GOAL_VISIBLE, ConditionCatalog.Query.STEP_AHEAD,
	]
	var kinds: Array[int] = [
		ProgramBlockKind.Value.WALK, ProgramBlockKind.Value.JUMP, ProgramBlockKind.Value.TURN,
		ProgramBlockKind.Value.IF, ProgramBlockKind.Value.WHILE,
	]
	if combat_available:
		queries.append(ConditionCatalog.Query.ENEMY_VISIBLE)
		queries.append(ConditionCatalog.Query.ENEMY_IN_MELEE_RANGE)
		kinds.append(ProgramBlockKind.Value.ATTACK)
	brain_editor.configure_condition_queries(queries)
	brain_editor.configure_block_kinds(kinds)
	editor_host.add_child(brain_editor)
	brain_editor.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	brain_editor.set_embedded_mode(true)
	brain_editor.attempt_requested.connect(_on_confirm_requested)
	brain_editor.back_to_assembly_requested.connect(_on_back_requested)
	brain_editor.summary_changed.connect(_on_editor_summary_changed)
	if session.graph_state != null:
		brain_editor.load_graph_state(session.graph_state)
	brain_editor.draft_changed.connect(_on_draft_changed)
	briefing.hide()
	editor_host.show()
	var snapshot = brain_editor.capture_snapshot()
	_on_editor_summary_changed(snapshot.ram, snapshot.status, snapshot.is_valid)
	return true

func _on_editor_summary_changed(ram: String, _status: String, _is_valid: bool) -> void:
	if save_error:
		status_label.text = "Nao foi possivel salvar o progresso. Sua edicao continua nesta sessao."
		status_label.add_theme_color_override("font_color", Tokens.ERROR)
		return
	if session != null and session.baton_checkpoint_active:
		status_label.text = "Checkpoint do bastao / %s | Atacar e sensores de inimigo liberados." % ram
	else:
		status_label.text = "Preparacao / %s | Voce podera revisar o programa ao encontrar o bastao." % ram

func return_to_briefing(confirm := false) -> bool:
	if brain_editor == null:
		return false
	var snapshot = brain_editor.capture_snapshot()
	if confirm:
		if not session.confirm_preparation(snapshot):
			return false
	else:
		session.keep_draft(snapshot)
	editor_host.remove_child(brain_editor)
	brain_editor.queue_free()
	brain_editor = null
	editor_host.hide()
	briefing.show()
	_refresh_briefing()
	progress_changed.emit()
	return true

func _refresh_briefing() -> void:
	var unlocked: bool = session != null and session.can_prepare_mission(Catalog.LABORATORY_ID)
	prepare_button.disabled = not unlocked
	enter_button.disabled = not unlocked or not session.preparation_confirmed
	if not unlocked:
		status_label.text = "Conclua o tutorial para preparar esta missao."
	elif session.preparation_confirmed:
		status_label.text = "Checkpoint pronto. Entre para continuar com o bastao." if session.baton_checkpoint_active else "Preparacao confirmada. Voce pode voltar ao cerebro e revisar seu programa."
	elif session.baton_checkpoint_active:
		status_label.text = "Bastao equipado. Edite e confirme o cerebro para continuar do checkpoint."
	else:
		status_label.text = "Tutorial concluido! Sua cabeca agora tem 10 RAM para a campanha."

func _on_confirm_requested() -> void:
	call_deferred("return_to_briefing", true)

func _on_enter_pressed() -> void:
	if session != null and session.can_prepare_mission(Catalog.LABORATORY_ID) and session.preparation_confirmed:
		mission_requested.emit()

func _on_back_requested() -> void:
	call_deferred("return_to_briefing", false)

func _on_menu_pressed() -> void:
	if brain_editor != null:
		session.keep_draft(brain_editor.capture_snapshot())
		progress_changed.emit()
	menu_requested.emit()

func _on_draft_changed() -> void:
	if session == null or brain_editor == null:
		return
	session.keep_draft(brain_editor.capture_snapshot())
	progress_changed.emit()

func show_save_error() -> void:
	save_error = true
	_on_editor_summary_changed("", "", false)

func clear_save_error() -> void:
	if not save_error:
		return
	save_error = false
	status_label.remove_theme_color_override("font_color")
	if brain_editor != null:
		var snapshot = brain_editor.capture_snapshot()
		_on_editor_summary_changed(snapshot.ram, snapshot.status, snapshot.is_valid)
	else:
		_refresh_briefing()
