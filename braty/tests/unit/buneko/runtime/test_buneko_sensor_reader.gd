extends GutTest

const ConditionCatalogScript = preload("res://src/programming/domain/condition_catalog.gd")
const ProgramConditionScript = preload("res://src/programming/domain/program_condition.gd")
const SensorReaderScript = preload("res://src/buneko/runtime/buneko_sensor_reader.gd")

class FakeWorldSensor:
	var path_clear_ahead := false
	var gap_ahead := false
	var goal_visible := false
	var signal_heard := false

	func is_path_clear_ahead() -> bool:
		return path_clear_ahead

	func has_gap_ahead() -> bool:
		return gap_ahead

	func can_see_goal() -> bool:
		return goal_visible

	func heard_signal() -> bool:
		return signal_heard

func test_reads_vision_conditions_from_world_sensor() -> void:
	var world_sensor := FakeWorldSensor.new()
	world_sensor.gap_ahead = true
	var reader = SensorReaderScript.new(world_sensor)

	var condition = ProgramConditionScript.new(
		ConditionCatalogScript.Modality.VISION,
		ConditionCatalogScript.Query.GAP_AHEAD
	)

	assert_true(reader.evaluate(condition))

func test_reads_path_clear_condition_from_world_sensor() -> void:
	var world_sensor := FakeWorldSensor.new()
	world_sensor.path_clear_ahead = true
	var reader = SensorReaderScript.new(world_sensor)

	var condition = ProgramConditionScript.new(
		ConditionCatalogScript.Modality.VISION,
		ConditionCatalogScript.Query.PATH_CLEAR_AHEAD
	)

	assert_true(reader.evaluate(condition))

func test_reads_hearing_condition_from_world_sensor() -> void:
	var world_sensor := FakeWorldSensor.new()
	world_sensor.signal_heard = true
	var reader = SensorReaderScript.new(world_sensor)

	var condition = ProgramConditionScript.new(
		ConditionCatalogScript.Modality.HEARING,
		ConditionCatalogScript.Query.SIGNAL_HEARD
	)

	assert_true(reader.evaluate(condition))

func test_invalid_or_missing_sensor_returns_false() -> void:
	var reader = SensorReaderScript.new()

	assert_false(reader.evaluate(null))
