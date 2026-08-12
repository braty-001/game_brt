extends GutTest

const HintPresenterScript = preload("res://src/tutorial/tutorial_hint_presenter.gd")
const MissionResultScript = preload("res://src/tutorial/mission_result.gd")
const MissionStateScript = preload("res://src/tutorial/mission_state.gd")

func test_hints_cover_main_mission_states() -> void:
	var presenter := HintPresenterScript.new()

	assert_ne(presenter.hint_for(MissionStateScript.Value.ASSEMBLY), "")
	assert_ne(presenter.hint_for(MissionStateScript.Value.EDITING, MissionResultScript.Kind.NONE, 0), "")
	assert_ne(presenter.hint_for(MissionStateScript.Value.RUNNING), "")
	assert_ne(
		presenter.hint_for(MissionStateScript.Value.FAILED, MissionResultScript.Kind.FAILED_BY_FALL),
		""
	)
	assert_ne(presenter.hint_for(MissionStateScript.Value.COMPLETED), "")

func test_editing_hint_introduces_visual_sensor_and_control_blocks() -> void:
	var presenter := HintPresenterScript.new()
	var hint := presenter.hint_for(MissionStateScript.Value.EDITING, MissionResultScript.Kind.NONE, 1)

	assert_true(hint.contains("Visao"))
	assert_true(hint.contains("buraco"))
	assert_true(hint.contains("IF") or hint.contains("WHILE"))
