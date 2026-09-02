extends GutTest

const ViewportControllerScript = preload("res://src/brain_editor/editor_viewport_controller.gd")

func test_zoom_is_limited_and_has_a_readable_label() -> void:
	var viewport = ViewportControllerScript.new()

	viewport.set_zoom(2.0)
	assert_eq(viewport.zoom, viewport.MAX_ZOOM)
	assert_eq(viewport.zoom_label(), "160%")
	viewport.set_zoom(0.1)
	assert_eq(viewport.zoom, viewport.MIN_ZOOM)
	assert_eq(viewport.zoom_label(), "60%")

func test_pan_and_coordinate_transforms_are_inverse_operations() -> void:
	var viewport = ViewportControllerScript.new()
	viewport.set_zoom(1.4)
	viewport.pan_by(Vector2(32, -18))
	var world_position := Vector2(120, 80)

	assert_eq(viewport.viewport_to_world(viewport.world_to_viewport(world_position)), world_position)

func test_center_restores_default_viewport() -> void:
	var viewport = ViewportControllerScript.new()
	viewport.set_zoom(1.4)
	viewport.pan_by(Vector2(45, 20))

	assert_true(viewport.center())
	assert_eq(viewport.zoom, viewport.DEFAULT_ZOOM)
	assert_eq(viewport.pan, Vector2.ZERO)
