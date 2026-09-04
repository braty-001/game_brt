class_name DisplaySettings
extends RefCounted

const DEFAULT_SIZE := Vector2i(1600, 900)
const DEFAULT_CONFIG_PATH := "user://display_settings.cfg"
const CONFIG_SECTION := "display"
const WIDTH_KEY := "window_width"
const HEIGHT_KEY := "window_height"
const SUPPORTED_SIZES: Array[Vector2i] = [
	Vector2i(960, 540),
	Vector2i(1440, 810),
	DEFAULT_SIZE,
]

var config_path: String

func _init(settings_path: String = DEFAULT_CONFIG_PATH) -> void:
	config_path = settings_path

func supported_sizes() -> Array[Vector2i]:
	return SUPPORTED_SIZES.duplicate()

func label_for(size: Vector2i) -> String:
	return "%dx%d" % [size.x, size.y]

func is_supported(size: Vector2i) -> bool:
	return SUPPORTED_SIZES.has(size)

func load_size() -> Vector2i:
	var config := ConfigFile.new()
	if config.load(config_path) != OK:
		return DEFAULT_SIZE

	var size := Vector2i(
		int(config.get_value(CONFIG_SECTION, WIDTH_KEY, -1)),
		int(config.get_value(CONFIG_SECTION, HEIGHT_KEY, -1))
	)
	return size if is_supported(size) else DEFAULT_SIZE

func save_size(size: Vector2i) -> bool:
	if not is_supported(size):
		return false

	var config := ConfigFile.new()
	config.set_value(CONFIG_SECTION, WIDTH_KEY, size.x)
	config.set_value(CONFIG_SECTION, HEIGHT_KEY, size.y)
	return config.save(config_path) == OK

func apply_size(size: Vector2i, persist := true) -> bool:
	if not is_supported(size):
		return false
	if persist and not save_size(size):
		return false

	_apply_to_window(size)
	return true

func apply_saved_size() -> Vector2i:
	var size := load_size()
	_apply_to_window(size)
	return size

func _apply_to_window(size: Vector2i) -> void:
	if DisplayServer.get_name() == "headless":
		return

	DisplayServer.window_set_size(size)
	var screen: int = DisplayServer.window_get_current_screen()
	var usable_rect: Rect2i = DisplayServer.screen_get_usable_rect(screen)
	var centered_position := usable_rect.position + (usable_rect.size - size) / 2
	DisplayServer.window_set_position(centered_position)
