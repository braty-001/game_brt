extends GutTest

const DisplaySettingsScript = preload("res://src/settings/display_settings.gd")
const TEST_CONFIG_PATH := "user://test_display_settings.cfg"

func before_each() -> void:
	_remove_test_config()

func after_each() -> void:
	_remove_test_config()

func test_exposes_only_supported_16_by_9_sizes() -> void:
	var settings = DisplaySettingsScript.new(TEST_CONFIG_PATH)
	var sizes: Array[Vector2i] = settings.supported_sizes()

	assert_eq(sizes.size(), 3)
	assert_eq(sizes[0], Vector2i(960, 540))
	assert_eq(sizes[1], Vector2i(1440, 810))
	assert_eq(sizes[2], Vector2i(1600, 900))
	assert_eq(settings.label_for(sizes[1]), "1440x810")

func test_supported_size_is_saved_and_loaded_by_a_new_instance() -> void:
	var settings = DisplaySettingsScript.new(TEST_CONFIG_PATH)

	assert_true(settings.save_size(Vector2i(960, 540)))
	assert_eq(DisplaySettingsScript.new(TEST_CONFIG_PATH).load_size(), Vector2i(960, 540))

func test_missing_or_invalid_configuration_uses_default_size() -> void:
	var settings = DisplaySettingsScript.new(TEST_CONFIG_PATH)
	assert_eq(settings.load_size(), DisplaySettingsScript.DEFAULT_SIZE)

	var invalid_config := ConfigFile.new()
	invalid_config.set_value(DisplaySettingsScript.CONFIG_SECTION, DisplaySettingsScript.WIDTH_KEY, 1234)
	invalid_config.set_value(DisplaySettingsScript.CONFIG_SECTION, DisplaySettingsScript.HEIGHT_KEY, 567)
	assert_eq(invalid_config.save(TEST_CONFIG_PATH), OK)
	assert_eq(settings.load_size(), DisplaySettingsScript.DEFAULT_SIZE)

func test_unsupported_size_is_rejected_without_creating_configuration() -> void:
	var settings = DisplaySettingsScript.new(TEST_CONFIG_PATH)

	assert_false(settings.apply_size(Vector2i(1280, 720)))
	assert_false(FileAccess.file_exists(TEST_CONFIG_PATH))

func _remove_test_config() -> void:
	if FileAccess.file_exists(TEST_CONFIG_PATH):
		DirAccess.remove_absolute(ProjectSettings.globalize_path(TEST_CONFIG_PATH))
