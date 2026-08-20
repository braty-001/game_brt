extends GutTest

const AttributesScript = preload("res://src/buneko/domain/buneko_attributes.gd")
const ControllerScript = preload("res://src/buneko/physics/buneko_physics_controller.gd")

func test_starts_facing_right_and_turns_without_moving() -> void:
	var controller = ControllerScript.new()

	assert_eq(controller.direction, ControllerScript.Direction.RIGHT)
	assert_true(controller.turn())

	assert_eq(controller.direction, ControllerScript.Direction.LEFT)
	assert_eq(controller.velocity, Vector2.ZERO)

func test_walk_and_run_apply_short_horizontal_steps_in_current_direction() -> void:
	var attributes = AttributesScript.new(100.0, 180.0, 250.0, 900.0, 1.0)
	var controller = ControllerScript.new(attributes)

	controller.walk()
	assert_eq(controller.velocity.x, 100.0)
	controller.step(controller.walk_step_duration + 0.01, true)
	assert_eq(controller.velocity.x, 0.0)

	controller.turn()
	controller.run()
	assert_eq(controller.velocity.x, -180.0)
	controller.step(controller.run_step_duration + 0.01, true)
	assert_eq(controller.velocity.x, 0.0)

func test_repeating_walk_refreshes_step_duration() -> void:
	var attributes = AttributesScript.new(100.0, 180.0, 250.0, 900.0, 1.0)
	var controller = ControllerScript.new(attributes)

	controller.walk()
	controller.step(controller.walk_step_duration * 0.5, true)
	controller.walk()
	controller.step(controller.walk_step_duration * 0.5, true)

	assert_eq(controller.velocity.x, 100.0)

func test_horizontal_step_keeps_air_momentum_until_landing() -> void:
	var attributes = AttributesScript.new(100.0, 180.0, 250.0, 900.0, 1.0)
	var controller = ControllerScript.new(attributes)

	controller.walk()
	controller.step(controller.walk_step_duration + 0.01, false)
	assert_eq(controller.velocity.x, 100.0)

	controller.step(0.016, true)
	assert_eq(controller.velocity.x, 0.0)

func test_jump_only_applies_impulse_when_grounded() -> void:
	var attributes = AttributesScript.new(100.0, 180.0, 250.0, 900.0, 1.0)
	var controller = ControllerScript.new(attributes)

	assert_false(controller.jump())
	assert_eq(controller.velocity.y, 0.0)

	controller.step(0.016, true)
	assert_true(controller.jump())
	assert_eq(controller.velocity.y, -250.0)
	assert_false(controller.grounded)

func test_run_after_landing_starts_a_fresh_ground_sprint() -> void:
	var attributes = AttributesScript.new(100.0, 180.0, 250.0, 900.0, 1.0)
	var controller = ControllerScript.new(attributes)

	controller.step(0.016, true)
	assert_true(controller.jump())
	controller.step(0.2, false)
	controller.step(0.2, false)
	controller.step(0.016, true)
	controller.run()

	assert_eq(controller.velocity.x, 180.0)
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
