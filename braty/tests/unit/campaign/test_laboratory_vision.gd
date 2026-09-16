extends GutTest

const Vision = preload("res://src/campaign/laboratory/occluded_vision.gd")
const Sensor = preload("res://src/campaign/laboratory/laboratory_world_sensor.gd")
const Fog = preload("res://src/campaign/laboratory/laboratory_fog.gd")
const Reader = preload("res://src/buneko/runtime/buneko_sensor_reader.gd")
const Selector = preload("res://src/brain_editor/condition_selector.gd")
const Examples = preload("res://src/campaign/laboratory/laboratory_example_provider.gd")
const Importer = preload("res://src/brain_editor/program_graph_importer.gd")
const Presenter = preload("res://src/brain_editor/pseudocode_presenter.gd")

func test_directional_cone_includes_edges_and_excludes_back_and_outside() -> void:
	var vision = Vision.new()
	assert_true(vision.can_see(Vector2(240, 0)))
	assert_true(vision.can_see(Vector2.from_angle(deg_to_rad(-60.0)) * 240.0))
	assert_true(vision.can_see(Vector2.from_angle(deg_to_rad(60.0)) * 240.0))
	assert_false(vision.can_see(Vector2.from_angle(deg_to_rad(-60.01)) * 200.0))
	assert_false(vision.can_see(Vector2.from_angle(deg_to_rad(60.01)) * 200.0))
	assert_false(vision.can_see(Vector2(-100, 0)))
	assert_false(vision.can_see(Vector2(241, 0)))
	assert_false(vision.can_see(Vector2(200, 200)))
	vision.facing_direction = -1
	assert_true(vision.can_see(Vector2(-240, 0)))
	assert_false(vision.can_see(Vector2(100, 0)))

func test_direction_change_has_no_exploration_memory() -> void:
	var vision = Vision.new()
	assert_true(vision.can_see(Vector2(100, 0)))
	vision.facing_direction = -1
	assert_false(vision.can_see(Vector2(100, 0)))
	assert_true(vision.can_see(Vector2(-100, 0)))
	vision.origin = Vector2(500, 0)
	assert_false(vision.can_see(Vector2.ZERO))
	vision.origin = Vector2.ZERO
	assert_true(vision.can_see(Vector2.ZERO))
	vision.radius = 0
	assert_false(vision.can_see(Vector2.ZERO))

func test_walls_and_floors_occlude_in_both_directions() -> void:
	var vision = Vision.new()
	vision.occluders.assign([Rect2(40, -40, 20, 80)])
	assert_true(vision.can_see(Vector2(40, 0)))
	assert_false(vision.can_see(Vector2(80, 0)))
	vision.origin = Vector2(80, 0)
	vision.facing_direction = -1
	assert_false(vision.can_see(Vector2.ZERO))
	vision.origin = Vector2.ZERO
	vision.facing_direction = 1
	vision.occluders.assign([Rect2(20, -30, 100, 10)])
	assert_false(vision.can_see(Vector2(80, -80)))
	vision.origin = Vector2(80, -80)
	vision.facing_direction = -1
	assert_false(vision.can_see(Vector2.ZERO))

func test_fog_boundary_matches_sensor_cone_occlusion_and_radius() -> void:
	var vision = Vision.new()
	vision.occluders.assign([Rect2(80, -60, 30, 120)])
	var boundary: PackedVector2Array = vision.boundary()
	assert_gt(boundary.size(), 120)
	for point in boundary:
		assert_lte(point.length(), 240.001)
		assert_true(vision.can_see(point), str(point))
	assert_almost_eq((boundary[0] - vision.origin).angle(), deg_to_rad(-60.0), 0.001)
	assert_almost_eq((boundary[-1] - vision.origin).angle(), deg_to_rad(60.0), 0.001)
	assert_almost_eq(boundary[boundary.size() / 2].x, 80.0, 0.1)

func test_fog_tracks_position_and_direction_changes() -> void:
	var vision = Vision.new()
	var fog = Fog.new()
	fog.vision = vision
	add_child_autofree(fog)
	fog._process(0.0)
	assert_eq(fog._last_origin, Vector2.ZERO)
	assert_eq(fog._last_facing_direction, 1)
	vision.origin = Vector2(20, 30)
	vision.facing_direction = -1
	fog._process(0.0)
	assert_eq(fog._last_origin, Vector2(20, 30))
	assert_eq(fog._last_facing_direction, -1)

func test_step_support_gap_and_direction_are_distinct() -> void:
	var sensor = Sensor.new()
	var solids: Array[Rect2] = [Rect2(0, 200, 200, 30), Rect2(200, 140, 80, 90)]
	sensor.configure(solids, Vector2(0, 0))
	_place(sensor, Vector2(150, 176), 1)
	assert_true(sensor.has_step_ahead())
	assert_false(sensor.is_path_clear_ahead())
	assert_false(sensor.has_gap_ahead())
	_place(sensor, Vector2(80, 176), 1)
	assert_false(sensor.has_step_ahead())
	assert_true(sensor.is_path_clear_ahead())
	assert_false(sensor.has_gap_ahead())
	_place(sensor, Vector2(240, 116), 1)
	assert_false(sensor.has_step_ahead())
	assert_false(sensor.is_path_clear_ahead())
	assert_true(sensor.has_gap_ahead())
	_place(sensor, Vector2(150, 176), -1)
	assert_false(sensor.has_step_ahead())
	assert_true(sensor.is_path_clear_ahead())

func test_hidden_steps_and_goal_are_not_detected_and_hearing_is_unavailable() -> void:
	var sensor = Sensor.new()
	var solids: Array[Rect2] = [Rect2(0, 200, 200, 30), Rect2(200, 140, 80, 90), Rect2(170, 50, 10, 150)]
	sensor.configure(solids, Vector2(220, 176))
	_place(sensor, Vector2(150, 176), 1)
	assert_false(sensor.has_step_ahead())
	assert_false(sensor.can_see_goal())
	assert_false(sensor.heard_signal())
	sensor.goal_position = Vector2(160, 176)
	assert_true(sensor.can_see_goal())
	sensor.goal_position = Vector2(-100, 176)
	assert_false(sensor.can_see_goal())

func test_step_query_uses_existing_condition_and_tutorial_keeps_original_catalog() -> void:
	var sensor = Sensor.new()
	var solids: Array[Rect2] = [Rect2(0, 200, 200, 30), Rect2(200, 140, 80, 90)]
	sensor.configure(solids, Vector2.ZERO)
	_place(sensor, Vector2(150, 176), 1)
	var condition := ProgramCondition.new(ConditionCatalog.Modality.VISION, ConditionCatalog.Query.STEP_AHEAD)
	assert_true(condition.is_valid())
	assert_true(Reader.new(sensor).evaluate(condition))
	assert_false(ProgramCondition.new(ConditionCatalog.Modality.HEARING, ConditionCatalog.Query.STEP_AHEAD).is_valid())
	var selector = Selector.new()
	assert_eq(selector.available_options().size(), 4)
	assert_null(selector.create_condition(condition.modality, condition.query))
	var graph = Importer.new().import_program(Examples.new().build_program())
	var presentation = Presenter.new().present(graph, 10)
	assert_true(presentation.is_valid)
	assert_string_contains(presentation.text, "ENQUANTO DEGRAU A FRENTE")

func _place(sensor, position: Vector2, direction: int) -> void:
	sensor.buneko_position = position
	sensor.vision.origin = position
	sensor.direction = direction
	sensor.vision.facing_direction = direction
