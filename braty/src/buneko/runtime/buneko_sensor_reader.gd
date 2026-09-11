class_name BunekoSensorReader
extends SensorReader

var world_sensor

func _init(reader_world_sensor = null) -> void:
	world_sensor = reader_world_sensor

func evaluate(condition: ProgramCondition) -> bool:
	if condition == null or not condition.is_valid() or world_sensor == null:
		return false

	match condition.modality:
		ConditionCatalog.Modality.VISION:
			return _evaluate_vision(condition.query)
		ConditionCatalog.Modality.HEARING:
			return _evaluate_hearing(condition.query)
		_:
			return false

func _evaluate_vision(query: int) -> bool:
	match query:
		ConditionCatalog.Query.PATH_CLEAR_AHEAD:
			return _call_sensor_bool("is_path_clear_ahead")
		ConditionCatalog.Query.GAP_AHEAD:
			return _call_sensor_bool("has_gap_ahead")
		ConditionCatalog.Query.GOAL_VISIBLE:
			return _call_sensor_bool("can_see_goal")
		ConditionCatalog.Query.STEP_AHEAD:
			return _call_sensor_bool("has_step_ahead")
		ConditionCatalog.Query.ENEMY_VISIBLE:
			return _call_sensor_bool("can_see_enemy")
		ConditionCatalog.Query.ENEMY_IN_MELEE_RANGE:
			return _call_sensor_bool("has_enemy_in_melee_range")
		_:
			return false

func _evaluate_hearing(query: int) -> bool:
	match query:
		ConditionCatalog.Query.SIGNAL_HEARD:
			return _call_sensor_bool("heard_signal")
		_:
			return false

func _call_sensor_bool(method_name: String) -> bool:
	if not world_sensor.has_method(method_name):
		return false

	return bool(world_sensor.call(method_name))
