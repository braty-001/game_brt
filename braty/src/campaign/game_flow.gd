class_name GameFlow
extends Control

const MenuScene = preload("res://scenes/menu/main_menu.tscn")
const TutorialScene = preload("res://scenes/tutorial/tutorial_mission.tscn")
const SelectionScene = preload("res://scenes/campaign/campaign_selection.tscn")
const SessionScript = preload("res://src/campaign/campaign_session.gd")
const LaboratoryScene = preload("res://scenes/campaign/laboratory_mission.tscn")
const SaveStoreScript = preload("res://src/campaign/campaign_save_store.gd")

var session = SessionScript.new()
var current_screen: Control
var save_store
var save_status := "missing"
var save_failed := false

func configure_save_store(store) -> bool:
	if is_node_ready() or store == null:
		return false
	save_store = store
	return true

func _ready() -> void:
	if save_store == null:
		save_store = SaveStoreScript.new()
	var loaded: Dictionary = save_store.load_progress()
	save_status = loaded["status"]
	if save_status == "ok":
		session = loaded["session"]
	show_menu()

func show_menu() -> void:
	var menu = MenuScene.instantiate()
	menu.set_navigation_enabled(false)
	menu.start_requested.connect(_on_start_requested)
	menu.new_game_requested.connect(_on_new_game_requested)
	_replace_screen(menu)
	menu.configure_progress(save_status == "ok" or session.tutorial_completed, save_status == "invalid")
	if save_failed:
		menu.show_progress_error("Nao foi possivel salvar o progresso recente.")
	menu.show_main_menu()

func start_selected_flow() -> void:
	if session.tutorial_completed:
		show_campaign()
	else:
		var tutorial = TutorialScene.instantiate()
		tutorial.tutorial_completed.connect(_on_tutorial_completed)
		_replace_screen(tutorial)

func show_campaign(open_editor := false) -> bool:
	if not session.tutorial_completed:
		return false
	var selection = SelectionScene.instantiate()
	selection.configure_session(session)
	selection.menu_requested.connect(_on_menu_requested)
	selection.mission_requested.connect(_on_mission_requested)
	selection.progress_changed.connect(_on_progress_changed)
	_replace_screen(selection)
	if open_editor:
		selection.open_preparation()
	return true

func show_laboratory() -> bool:
	if not session.tutorial_completed or not session.preparation_confirmed:
		return false
	var mission = LaboratoryScene.instantiate()
	mission.configure_session(session)
	mission.editing_requested.connect(_on_editing_requested)
	mission.selection_requested.connect(_on_selection_requested)
	mission.progress_changed.connect(_on_progress_changed)
	_replace_screen(mission)
	return true

func _on_mission_requested() -> void:
	call_deferred("show_laboratory")

func _on_editing_requested() -> void:
	call_deferred("show_campaign", true)

func _on_selection_requested() -> void:
	call_deferred("show_campaign")

func _replace_screen(next_screen: Control) -> void:
	if current_screen != null:
		remove_child(current_screen)
		current_screen.queue_free()
	current_screen = next_screen
	add_child(current_screen)
	current_screen.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)

func _on_start_requested() -> void:
	call_deferred("start_selected_flow")

func _on_menu_requested() -> void:
	call_deferred("show_menu")

func _on_tutorial_completed(assembly, graph_state) -> void:
	session.complete_tutorial(assembly, graph_state)
	var saved := _persist()
	call_deferred("show_campaign")
	if not saved:
		call_deferred("_show_campaign_save_error")

func _on_progress_changed() -> void:
	if _persist():
		if current_screen != null and current_screen.has_method("clear_save_error"):
			current_screen.clear_save_error()
		return
	if current_screen != null and current_screen.has_method("show_save_error"):
		current_screen.show_save_error()

func _persist() -> bool:
	var saved: bool = save_store.save_progress(session)
	save_failed = not saved
	if saved:
		save_status = "ok"
	return saved

func _show_campaign_save_error() -> void:
	if current_screen != null and current_screen.has_method("show_save_error"):
		current_screen.show_save_error()

func _on_new_game_requested() -> void:
	var fresh_session = SessionScript.new()
	if not save_store.replace_with_new_game(fresh_session):
		save_failed = true
		if current_screen != null and current_screen.has_method("show_progress_error"):
			current_screen.show_progress_error("Nao foi possivel iniciar um novo jogo. O progresso anterior foi preservado.")
		return
	session = fresh_session
	save_status = "ok"
	save_failed = false
	start_selected_flow()
