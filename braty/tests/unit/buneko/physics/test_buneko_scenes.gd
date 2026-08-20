extends GutTest

const BlockKind = preload("res://src/programming/domain/block_kind.gd")

func test_buneko_scene_instantiates() -> void:
	var scene: PackedScene = load("res://scenes/buneko/buneko.tscn")

	var instance = scene.instantiate()

	assert_not_null(instance)
	instance.free()

func test_buneko_scene_responds_to_movement_intentions() -> void:
	var buneko = await _ready_buneko()

	assert_true(buneko.walk())
	assert_eq(buneko.controller.velocity.x, buneko.walk_speed)
	buneko.controller.step(buneko.controller.walk_step_duration + 0.01, true)
	assert_eq(buneko.controller.velocity.x, 0.0)

	assert_true(buneko.run())
	assert_eq(buneko.controller.velocity.x, buneko.run_speed)
	buneko.controller.step(buneko.controller.run_step_duration + 0.01, true)
	assert_eq(buneko.controller.velocity.x, 0.0)

	assert_true(buneko.turn())
	assert_eq(buneko.controller.direction, -1)

func test_buneko_scene_blocks_air_jump_and_allows_ground_jump() -> void:
	var buneko = await _ready_buneko()

	assert_false(buneko.jump())

	buneko.controller.grounded = true
	assert_true(buneko.controller.jump())
	assert_eq(buneko.controller.velocity.y, -buneko.jump_impulse)

func test_buneko_scene_reports_fall_limit() -> void:
	var buneko = await _ready_buneko()
	buneko.fall_limit_y = 100.0
	buneko.controller.fall_limit_y = 100.0

	assert_false(buneko.controller.has_fallen(Vector2(0, 100)))
	assert_true(buneko.controller.has_fallen(Vector2(0, 101)))

func test_buneko_scene_shows_and_clears_action_pulses() -> void:
	var buneko = await _ready_buneko()
	var visual = buneko.get_node("Visual")

	buneko.show_action_pulse(BlockKind.Value.JUMP)
	assert_true(visual.is_pulsing())
	buneko.show_action_pulse(BlockKind.Value.JUMP, true)
	assert_true(visual.is_pulsing())

	visual._process(visual.PULSE_DURATION + 0.01)
	assert_false(visual.is_pulsing())

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
