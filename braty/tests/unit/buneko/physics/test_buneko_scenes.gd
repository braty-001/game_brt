extends GutTest

const BlockKind = preload("res://src/programming/domain/block_kind.gd")
const AttributesScript = preload("res://src/buneko/domain/buneko_attributes.gd")
const MovementPaceScript = preload("res://src/programming/domain/movement_pace.gd")

func test_buneko_scene_instantiates() -> void:
	var scene: PackedScene = load("res://scenes/buneko/buneko.tscn")

	var instance = scene.instantiate()

	assert_not_null(instance)
	var collision_shape: RectangleShape2D = instance.get_node("CollisionShape2D").shape
	assert_eq(collision_shape.size, Vector2(32, 48))
	instance.free()

func test_buneko_scene_responds_to_movement_intentions() -> void:
	var buneko = await _ready_buneko()

	assert_true(buneko.walk(MovementPaceScript.Value.NORMAL))
	assert_eq(buneko.controller.velocity.x, buneko.movement_speed)
	buneko.controller.stop_horizontal()
	assert_true(buneko.walk(MovementPaceScript.Value.FAST))
	assert_eq(buneko.controller.velocity.x, buneko.movement_speed * 2.0)

	assert_true(buneko.turn())
	assert_eq(buneko.controller.direction, -1)

func test_facing_visual_survives_physics_between_repeated_turns() -> void:
	var buneko = await _ready_buneko()
	buneko.set_physics_process(false)
	var visual = buneko.get_node("Visual")
	for direction in [-1, 1, -1, 1]:
		assert_true(buneko.face_direction(direction))
		buneko._physics_process(1.0 / 60.0)
		await get_tree().physics_frame
		await get_tree().process_frame
		assert_eq(buneko.facing_direction(), direction)
		assert_almost_eq(visual.global_transform.x.x, float(direction), 0.0001, "Rendered forward must follow logical facing after physics")
		assert_almost_eq(visual.global_transform.y.y, 1.0, 0.0001)
		assert_almost_eq(buneko.get_node("CollisionShape2D").global_transform.x.x, 1.0, 0.0001)

func test_buneko_scene_uses_attributes_configured_before_ready() -> void:
	var scene: PackedScene = load("res://scenes/buneko/buneko.tscn")
	var buneko = scene.instantiate()
	assert_true(buneko.configure_attributes(AttributesScript.new(210.0, 75.0, 600.0, 800.0, 2.0)))
	add_child_autofree(buneko)
	await get_tree().process_frame

	assert_eq(buneko.controller.attributes.movement_speed, 210.0)
	assert_eq(buneko.controller.attributes.ground_deceleration, 75.0)
	assert_eq(buneko.controller.attributes.jump_impulse, 600.0)
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

func test_buneko_visual_tracks_attack_damage_landing_and_defeat_events() -> void:
	var buneko = await _ready_buneko()
	var visual = buneko.get_node("Visual")
	buneko.equip_baton()
	assert_true(buneko.attack())
	assert_eq(visual.presentation_snapshot().attack_phase, "windup")
	buneko.melee.advance(buneko.melee.WINDUP_SECONDS)
	assert_eq(visual.presentation_snapshot().attack_phase, "strike")
	buneko.receive_damage(2)
	assert_true(visual.presentation_snapshot().damage_reacting)
	buneko.landed.emit(buneko)
	assert_true(visual.presentation_snapshot().landing_reacting)
	buneko.receive_damage(20)
	assert_true(visual.presentation_snapshot().defeated)

func test_baton_reaches_contact_at_damage_time_and_recovers_continuously() -> void:
	var buneko = await _ready_buneko()
	buneko.set_physics_process(false)
	buneko.equip_baton()
	var visual = buneko.get_node("Visual")
	for direction in [1, -1]:
		buneko.face_direction(direction)
		assert_true(buneko.attack())
		assert_almost_eq(visual.presentation_snapshot().baton_angle, -0.82, 0.0001)
		assert_false(buneko.melee.advance(0.12))
		assert_almost_eq(visual.presentation_snapshot().baton_angle, -1.75, 0.0001)
		assert_false(buneko.melee.advance(0.0799))
		assert_almost_eq(visual.presentation_snapshot().baton_angle, 0.28, 0.003)
		assert_true(buneko.melee.advance(0.0002))
		assert_almost_eq(visual.presentation_snapshot().baton_angle, 0.28, 0.0001)
		visual._process(0.06)
		assert_almost_eq(visual.presentation_snapshot().baton_angle, 0.28, 0.0001, "Presentation time must not advance the suspended attack")
		assert_false(buneko.melee.advance(0.16))
		assert_almost_eq(visual.presentation_snapshot().baton_angle, 0.28, 0.001)
		assert_false(buneko.melee.advance(0.4398))
		assert_almost_eq(visual.presentation_snapshot().baton_angle, -0.82, 0.001)
		assert_false(buneko.melee.advance(0.0002))
		assert_eq(visual.presentation_snapshot().attack_phase, "idle")
		assert_almost_eq(visual.presentation_snapshot().baton_angle, -0.82, 0.0001)

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
