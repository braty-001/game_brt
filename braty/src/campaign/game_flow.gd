class_name GameFlow
extends Control

const MenuScene = preload("res://scenes/menu/main_menu.tscn")
const TutorialScene = preload("res://scenes/tutorial/tutorial_mission.tscn")
const SelectionScene = preload("res://scenes/campaign/campaign_selection.tscn")
const SessionScript = preload("res://src/campaign/campaign_session.gd")
const LaboratoryScene = preload("res://scenes/campaign/laboratory_mission.tscn")

var session = SessionScript.new()
var current_screen: Control

func _ready() -> void:
	show_menu()

func show_menu() -> void:
	var menu = MenuScene.instantiate()
	menu.set_navigation_enabled(false)
	menu.start_requested.connect(_on_start_requested)
	_replace_screen(menu)
	if session.tutorial_completed:
		menu.start_button.text = "Campanha"

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
	_replace_screen(mission)
	return true

func _on_mission_requested() -> void:
	call_deferred("show_laboratory")

func _on_editing_requested() -> void:
	call_deferred("show_campaign", true)

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
	call_deferred("show_campaign")
