extends GutTest

const Cue = preload("res://src/campaign/presentation/danger_time_cue.gd")

func test_visible_entry_slows_once_and_returns_to_normal() -> void:
	var cue = Cue.new()
	assert_false(cue.observe(false, 1000))
	assert_true(cue.observe(true, 1100))
	assert_eq(cue.factor(1100), 0.4)
	assert_false(cue.observe(true, 1200))
	assert_eq(cue.factor(1450), 0.4)
	assert_gt(cue.factor(1525), 0.4)
	assert_lt(cue.factor(1525), 1.0)
	assert_eq(cue.factor(1600), 1.0)
	assert_false(cue.observe(true, 1700))
	assert_eq(cue.factor(1700), 1.0)
	assert_false(cue.observe(false, 1800))
	assert_true(cue.observe(true, 1900))
	assert_eq(cue.factor(1900), 0.4)

func test_cancel_keeps_visible_enemy_from_retriggering_until_new_entry() -> void:
	var cue = Cue.new()
	assert_true(cue.observe(true, 100))
	cue.cancel()
	assert_false(cue.observe(true, 200))
	assert_eq(cue.factor(200), 1.0)
	cue.reset()
	assert_true(cue.observe(true, 300))
