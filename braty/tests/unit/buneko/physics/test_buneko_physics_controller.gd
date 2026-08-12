extends GutTest

const AttributesScript = preload("res://src/buneko/domain/buneko_attributes.gd")
const ControllerScript = preload("res://src/buneko/physics/buneko_physics_controller.gd")

func test_starts_facing_right_and_turns_without_moving() -> void:
	var controller = ControllerScript.new()

	assert_eq(controller.direction, ControllerScript.Direction.RIGHT)
	assert_true(controller.turn())

	assert_eq(controller.direction, ControllerScript.Direction.LEFT)
	assert_eq(controller.velocity, Vector2.ZERO)

func test_walk_and_run_apply_horizontal_velocity_in_current_direction() -> void:
	var attributes = AttributesScript.new(100.0, 180.0, 250.0, 900.0, 1.0)
	var controller = ControllerScript.new(attributes)

	controller.walk()
	assert_eq(controller.velocity.x, 100.0)

	controller.turn()
	controller.run()
	assert_eq(controller.velocity.x, -180.0)

func test_jump_only_applies_impulse_when_grounded() -> void:
	var attributes = AttributesScript.new(100.0, 180.0, 250.0, 900.0, 1.0)
	var controller = ControllerScript.new(attributes)

	assert_false(controller.jump())
	assert_eq(controller.velocity.y, 0.0)

	controller.step(0.016, true)
	assert_true(controller.jump())
	assert_eq(controller.velocity.y, -250.0)
	assert_false(controller.grounded)

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
