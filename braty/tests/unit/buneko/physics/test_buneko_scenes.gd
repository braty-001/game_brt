extends GutTest

func test_buneko_scene_instantiates() -> void:
	var scene: PackedScene = load("res://scenes/buneko/buneko.tscn")

	var instance = scene.instantiate()

	assert_not_null(instance)
	instance.free()

func test_buneko_scene_responds_to_movement_intentions() -> void:
	var buneko = await _ready_buneko()

	assert_true(buneko.walk())
	assert_eq(buneko.controller.velocity.x, buneko.walk_speed)

	assert_true(buneko.run())
	assert_eq(buneko.controller.velocity.x, buneko.run_speed)

	assert_true(buneko.turn())
	assert_eq(buneko.controller.direction, -1)

func test_buneko_scene_blocks_air_jump_and_allows_ground_jump() -> void:
	var buneko = await _ready_buneko()

	assert_false(buneko.jump())

	buneko.controller.grounded = true
	assert_true(buneko.jump())
	assert_eq(buneko.controller.velocity.y, -buneko.jump_impulse)

func test_buneko_scene_reports_fall_limit() -> void:
	var buneko = await _ready_buneko()
	buneko.fall_limit_y = 100.0
	buneko.controller.fall_limit_y = 100.0

	assert_false(buneko.controller.has_fallen(Vector2(0, 100)))
	assert_true(buneko.controller.has_fallen(Vector2(0, 101)))

func test_buneko_test_stage_instantiates() -> void:
	var scene: PackedScene = load("res://scenes/buneko/buneko_test_stage.tscn")

	var instance = scene.instantiate()

	assert_not_null(instance)
	instance.free()

func _ready_buneko():
	var scene: PackedScene = load("res://scenes/buneko/buneko.tscn")
	var buneko = scene.instantiate()
	add_child_autofree(buneko)
	await get_tree().process_frame
	return buneko
