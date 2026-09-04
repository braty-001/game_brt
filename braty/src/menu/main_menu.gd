class_name MainMenu
extends Control

const DisplaySettingsScript = preload("res://src/settings/display_settings.gd")
const Tokens = preload("res://src/ui/design_tokens.gd")
const TutorialMissionScene = preload("res://scenes/tutorial/tutorial_mission.tscn")

signal start_requested

var display_settings
var navigation_enabled := true

var menu_card: PanelContainer
var main_actions: VBoxContainer
var settings_panel: VBoxContainer
var start_button: Button
var settings_button: Button
var resolution_selector: OptionButton
var current_resolution_label: Label
var apply_button: Button
var back_button: Button

func _ready() -> void:
	_bind_view()
	_configure_styles()
	if display_settings == null:
		display_settings = DisplaySettingsScript.new()
	_populate_resolutions()
	_select_resolution(display_settings.apply_saved_size())
	show_main_menu()

func configure_display_settings(settings) -> bool:
	if is_node_ready() or settings == null:
		return false
	display_settings = settings
	return true

func set_navigation_enabled(enabled: bool) -> void:
	navigation_enabled = enabled

func show_settings() -> void:
	main_actions.visible = false
	settings_panel.visible = true
	resolution_selector.grab_focus()

func show_main_menu() -> void:
	main_actions.visible = true
	settings_panel.visible = false
	start_button.grab_focus()

func selected_resolution() -> Vector2i:
	if resolution_selector.selected < 0:
		return DisplaySettingsScript.DEFAULT_SIZE
	return resolution_selector.get_item_metadata(resolution_selector.selected)

func apply_selected_resolution() -> bool:
	var size := selected_resolution()
	if not display_settings.apply_size(size):
		current_resolution_label.text = "Nao foi possivel salvar esta configuracao."
		current_resolution_label.add_theme_color_override("font_color", Tokens.ERROR)
		return false

	current_resolution_label.text = "Tamanho atual: %s" % display_settings.label_for(size)
	current_resolution_label.add_theme_color_override("font_color", Tokens.SUCCESS)
	return true

func _bind_view() -> void:
	get_node("Background").color = Tokens.BACKGROUND
	menu_card = get_node("Margin/Center/MenuCard")
	main_actions = get_node("Margin/Center/MenuCard/Page/MainActions")
	settings_panel = get_node("Margin/Center/MenuCard/Page/SettingsPanel")
	start_button = get_node("Margin/Center/MenuCard/Page/MainActions/StartButton")
	settings_button = get_node("Margin/Center/MenuCard/Page/MainActions/SettingsButton")
	resolution_selector = get_node("Margin/Center/MenuCard/Page/SettingsPanel/ResolutionSelector")
	current_resolution_label = get_node("Margin/Center/MenuCard/Page/SettingsPanel/CurrentResolutionLabel")
	apply_button = get_node("Margin/Center/MenuCard/Page/SettingsPanel/SettingsActions/ApplyButton")
	back_button = get_node("Margin/Center/MenuCard/Page/SettingsPanel/SettingsActions/BackButton")

	start_button.pressed.connect(_on_start_pressed)
	settings_button.pressed.connect(show_settings)
	apply_button.pressed.connect(apply_selected_resolution)
	back_button.pressed.connect(show_main_menu)

func _configure_styles() -> void:
	Tokens.apply_panel(menu_card, Color("202b31"))
	Tokens.apply_primary_button(start_button)
	Tokens.apply_secondary_button(settings_button)
	Tokens.apply_primary_button(apply_button)
	Tokens.apply_secondary_button(back_button)
	get_node("Margin/Center/MenuCard/Page/Subtitle").add_theme_color_override("font_color", Tokens.TEXT_MUTED)
	get_node("Margin/Center/MenuCard/Page/SettingsPanel/SettingsHint").add_theme_color_override("font_color", Tokens.TEXT_MUTED)
	current_resolution_label.add_theme_color_override("font_color", Tokens.TEXT_MUTED)

func _populate_resolutions() -> void:
	resolution_selector.clear()
	for size: Vector2i in display_settings.supported_sizes():
		resolution_selector.add_item(display_settings.label_for(size))
		resolution_selector.set_item_metadata(resolution_selector.item_count - 1, size)

func _select_resolution(size: Vector2i) -> void:
	for index in resolution_selector.item_count:
		if resolution_selector.get_item_metadata(index) == size:
			resolution_selector.select(index)
			break
	current_resolution_label.text = "Tamanho atual: %s" % display_settings.label_for(size)

func _on_start_pressed() -> void:
	start_requested.emit()
	if navigation_enabled:
		call_deferred("_open_tutorial")

func _open_tutorial() -> void:
	get_tree().change_scene_to_packed(TutorialMissionScene)
