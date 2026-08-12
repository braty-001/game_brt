extends GutTest

func test_tutorial_level_scene_instantiates_with_required_nodes() -> void:
	var scene: PackedScene = load("res://scenes/tutorial/tutorial_level.tscn")

	var level = scene.instantiate()

	assert_not_null(level)
	assert_true(level.required_nodes_present())
	level.free()

func test_goal_and_fall_zone_emit_signals() -> void:
	var goal_scene_script = load("res://src/tutorial/tutorial_goal.gd")
	var fall_scene_script = load("res://src/tutorial/fall_zone.gd")
	var goal = goal_scene_script.new()
	var fall_zone = fall_scene_script.new()
	add_child_autofree(goal)
	add_child_autofree(fall_zone)
	watch_signals(goal)
	watch_signals(fall_zone)
	await get_tree().process_frame

	var goal_body := Node2D.new()
	var fall_body := Node2D.new()
	goal._on_body_entered(goal_body)
	fall_zone._on_body_entered(fall_body)
	goal_body.free()
	fall_body.free()

	assert_signal_emitted(goal, "reached")
	assert_signal_emitted(fall_zone, "fallen")
