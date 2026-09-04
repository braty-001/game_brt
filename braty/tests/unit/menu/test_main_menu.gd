extends GutTest

const DisplaySettingsScript = preload("res://src/settings/display_settings.gd")
const MainMenuScene = preload("res://scenes/menu/main_menu.tscn")
const TEST_CONFIG_PATH := "user://test_main_menu_display_settings.cfg"

func before_each() -> void:
	_remove_test_config()

func after_each() -> void:
	_remove_test_config()

func test_scene_starts_with_main_actions_and_supported_resolutions() -> void:
	var menu = await _create_menu()

	assert_true(menu.main_actions.visible)
	assert_false(menu.settings_panel.visible)
	assert_eq(menu.start_button.text, "Iniciar")
	assert_eq(menu.settings_button.text, "Configuracoes")
	assert_eq(menu.resolution_selector.item_count, 3)
	assert_eq(menu.selected_resolution(), Vector2i(1600, 900))

func test_settings_and_back_buttons_toggle_panels() -> void:
	var menu = await _create_menu()

	menu.settings_button.pressed.emit()
	assert_false(menu.main_actions.visible)
	assert_true(menu.settings_panel.visible)

	menu.back_button.pressed.emit()
	assert_true(menu.main_actions.visible)
	assert_false(menu.settings_panel.visible)

func test_apply_persists_selected_resolution() -> void:
	var menu = await _create_menu()
	menu.resolution_selector.select(0)

	assert_true(menu.apply_selected_resolution())
	assert_eq(DisplaySettingsScript.new(TEST_CONFIG_PATH).load_size(), Vector2i(960, 540))
	assert_eq(menu.current_resolution_label.text, "Tamanho atual: 960x540")

func test_start_button_requests_the_existing_tutorial() -> void:
	var menu = await _create_menu()
	watch_signals(menu)

	menu.start_button.pressed.emit()

	assert_signal_emitted(menu, "start_requested")
	assert_not_null(load("res://scenes/tutorial/tutorial_mission.tscn"))

func test_menu_card_fits_inside_smallest_supported_viewport() -> void:
	var viewport := SubViewport.new()
	viewport.size = Vector2i(960, 540)
	add_child_autofree(viewport)
	var menu = MainMenuScene.instantiate()
	menu.configure_display_settings(DisplaySettingsScript.new(TEST_CONFIG_PATH))
	menu.set_navigation_enabled(false)
	viewport.add_child(menu)
	await get_tree().process_frame
	await get_tree().process_frame

	var card_rect: Rect2 = menu.menu_card.get_global_rect()
	assert_gte(card_rect.position.x, 0.0)
	assert_gte(card_rect.position.y, 0.0)
	assert_lte(card_rect.end.x, 960.0)
	assert_lte(card_rect.end.y, 540.0)

func _create_menu():
	var menu = MainMenuScene.instantiate()
	menu.configure_display_settings(DisplaySettingsScript.new(TEST_CONFIG_PATH))
	menu.set_navigation_enabled(false)
	add_child_autofree(menu)
	await get_tree().process_frame
	return menu

func _remove_test_config() -> void:
	if FileAccess.file_exists(TEST_CONFIG_PATH):
		DirAccess.remove_absolute(ProjectSettings.globalize_path(TEST_CONFIG_PATH))
