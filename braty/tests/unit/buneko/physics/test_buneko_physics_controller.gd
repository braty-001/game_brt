extends GutTest

const AttributesScript = preload("res://src/buneko/domain/buneko_attributes.gd")
const ControllerScript = preload("res://src/buneko/physics/buneko_physics_controller.gd")
const MovementPaceScript = preload("res://src/programming/domain/movement_pace.gd")

func test_starts_facing_right_and_turns_without_moving() -> void:
	var controller = ControllerScript.new()

	assert_eq(controller.direction, ControllerScript.Direction.RIGHT)
	assert_true(controller.turn())

	assert_eq(controller.direction, ControllerScript.Direction.LEFT)
	assert_eq(controller.velocity, Vector2.ZERO)

func test_walk_paces_apply_distinct_speeds_in_current_direction() -> void:
	var attributes = AttributesScript.new(100.0, 180.0, 250.0, 900.0, 1.0)
	var controller = ControllerScript.new(attributes)

	assert_true(controller.walk(MovementPaceScript.Value.NORMAL))
	assert_eq(controller.velocity.x, 100.0)
	controller.turn()
	assert_true(controller.walk(MovementPaceScript.Value.FAST))
	assert_eq(controller.velocity.x, -200.0)
	assert_false(controller.walk(99))

func test_absent_intent_decelerates_on_ground() -> void:
	var attributes = AttributesScript.new(100.0, 200.0, 250.0, 900.0, 1.0)
	var controller = ControllerScript.new(attributes)

	controller.walk()
	controller.step(0.016, true)
	controller.step(0.25, true)
	assert_eq(controller.velocity.x, 50.0)
	controller.step(0.25, true)
	assert_eq(controller.velocity.x, 0.0)
	assert_true(controller.is_motion_settled())

func test_repeating_intent_maintains_requested_speed() -> void:
	var attributes = AttributesScript.new(100.0, 180.0, 250.0, 900.0, 1.0)
	var controller = ControllerScript.new(attributes)

	for cycle in range(4):
		controller.walk(MovementPaceScript.Value.FAST)
		controller.step(0.1, true)
		assert_eq(controller.velocity.x, 200.0, "Cycle %d should renew movement." % cycle)

func test_air_momentum_is_preserved_until_landing() -> void:
	var attributes = AttributesScript.new(100.0, 200.0, 250.0, 900.0, 1.0)
	var controller = ControllerScript.new(attributes)

	controller.walk()
	controller.step(0.016, true)
	controller.step(0.2, false)
	assert_eq(controller.velocity.x, 100.0)

	controller.step(0.05, true)
	assert_eq(controller.velocity.x, 90.0)

func test_intent_does_not_decelerate_during_jump_takeoff() -> void:
	var attributes = AttributesScript.new(100.0, 180.0, 250.0, 900.0, 1.0)
	var controller = ControllerScript.new(attributes)

	controller.walk()
	controller.step(0.016, true)
	assert_true(controller.jump())
	controller.step(0.016, true)

	assert_eq(controller.velocity.x, 100.0)

func test_stop_horizontal_clears_pending_intent() -> void:
	var controller = ControllerScript.new()
	controller.step(0.016, true)
	controller.walk()

	controller.stop_horizontal()

	assert_true(controller.is_motion_settled())
	assert_eq(controller.step(0.016, true).x, 0.0)

func test_jump_only_applies_impulse_when_grounded() -> void:
	var attributes = AttributesScript.new(100.0, 180.0, 250.0, 900.0, 1.0)
	var controller = ControllerScript.new(attributes)

	assert_false(controller.jump())
	assert_eq(controller.velocity.y, 0.0)

	controller.step(0.016, true)
	assert_true(controller.jump())
	assert_eq(controller.velocity.y, -250.0)
	assert_false(controller.grounded)

func test_fast_walk_after_landing_starts_fresh_movement() -> void:
	var attributes = AttributesScript.new(100.0, 180.0, 250.0, 900.0, 1.0)
	var controller = ControllerScript.new(attributes)

	controller.step(0.016, true)
	assert_true(controller.jump())
	controller.step(0.2, false)
	controller.step(0.2, false)
	controller.step(0.016, true)
	controller.walk(MovementPaceScript.Value.FAST)

	assert_eq(controller.velocity.x, 200.0)
	assert_eq(controller.velocity.y, 0.0)

func test_gravity_applies_while_airborne_and_resets_downward_velocity_on_floor() -> void:
	var attributes = AttributesScript.new(100.0, 180.0, 250.0, 1000.0, 1.0)
	var controller = ControllerScript.new(attributes)

	controller.step(0.5, false)
	assert_eq(controller.velocity.y, 500.0)

	controller.step(0.016, true)
	assert_eq(controller.velocity.y, 0.0)

func test_fall_limit_reports_out_of_bounds() -> void:
	var controller = ControllerScript.new()
	controller.fall_limit_y = 100.0

	assert_false(controller.has_fallen(Vector2(0, 100)))
	assert_true(controller.has_fallen(Vector2(0, 101)))
