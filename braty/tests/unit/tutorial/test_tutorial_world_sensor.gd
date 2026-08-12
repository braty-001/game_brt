extends GutTest

const WorldSensorScript = preload("res://src/tutorial/tutorial_world_sensor.gd")

func test_gap_is_detected_before_forward_edge() -> void:
	var sensor = WorldSensorScript.new()
	sensor.buneko_position = Vector2(250, 240)
	sensor.buneko_direction = 1
	sensor.gap_start_x = 320.0
	sensor.vision_range = 100.0

	assert_true(sensor.has_gap_ahead())

func test_gap_is_not_detected_after_gap_when_facing_right() -> void:
	var sensor = WorldSensorScript.new()
	sensor.buneko_position = Vector2(460, 240)
	sensor.buneko_direction = 1
	sensor.gap_start_x = 320.0
	sensor.gap_end_x = 440.0
	sensor.vision_range = 200.0

	assert_false(sensor.has_gap_ahead())

func test_path_is_clear_before_decision_distance_reaches_gap() -> void:
	var sensor = WorldSensorScript.new()
	sensor.buneko_position = Vector2(250, 240)
	sensor.buneko_direction = 1
	sensor.gap_start_x = 320.0
	sensor.gap_end_x = 440.0
	sensor.path_decision_distance = 54.0

	assert_true(sensor.is_path_clear_ahead())

func test_path_is_not_clear_near_gap_edge() -> void:
	var sensor = WorldSensorScript.new()
	sensor.buneko_position = Vector2(285, 240)
	sensor.buneko_direction = 1
	sensor.gap_start_x = 320.0
	sensor.gap_end_x = 440.0
	sensor.path_decision_distance = 54.0

	assert_false(sensor.is_path_clear_ahead())

func test_path_is_clear_after_landing_platform() -> void:
	var sensor = WorldSensorScript.new()
	sensor.buneko_position = Vector2(460, 240)
	sensor.buneko_direction = 1
	sensor.gap_start_x = 320.0
	sensor.gap_end_x = 440.0
	sensor.path_decision_distance = 54.0

	assert_true(sensor.is_path_clear_ahead())

func test_path_clear_checks_reverse_direction_and_obstacles() -> void:
	var sensor = WorldSensorScript.new()
	sensor.buneko_position = Vector2(470, 240)
	sensor.buneko_direction = -1
	sensor.gap_start_x = 320.0
	sensor.gap_end_x = 440.0
	sensor.path_decision_distance = 54.0

	assert_false(sensor.is_path_clear_ahead())

	sensor.buneko_position = Vector2(250, 240)
	sensor.buneko_direction = 1
	sensor.obstacles.append(Vector2(282, 240))

	assert_false(sensor.is_path_clear_ahead())

func test_goal_is_visible_when_ahead_in_range() -> void:
	var sensor = WorldSensorScript.new()
	sensor.buneko_position = Vector2(600, 240)
	sensor.buneko_direction = 1
	sensor.goal_position = Vector2(720, 240)
	sensor.vision_range = 150.0

	assert_true(sensor.can_see_goal())

func test_hearing_returns_configured_signal() -> void:
	var sensor = WorldSensorScript.new()
	sensor.signal_heard = true

	assert_true(sensor.heard_signal())
