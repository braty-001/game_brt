extends GutTest

const SaveStoreScript = preload("res://src/campaign/campaign_save_store.gd")
const SaveCodecScript = preload("res://src/campaign/campaign_save_codec.gd")
const SessionScript = preload("res://src/campaign/campaign_session.gd")
const GraphScript = preload("res://src/brain_editor/editor_graph_state.gd")
const BlockScript = preload("res://src/brain_editor/editor_block_state.gd")
const ConnectionScript = preload("res://src/brain_editor/editor_connection_state.gd")

const SAVE_PATH := "user://test_campaign_save.json"

func before_each() -> void:
	_remove_save()

func after_each() -> void:
	_remove_save()

func test_round_trip_preserves_assembly_graph_checkpoint_and_money() -> void:
	var session = _sample_session()
	var store = SaveStoreScript.new(SAVE_PATH)
	assert_true(store.save_progress(session))
	var loaded: Dictionary = SaveStoreScript.new(SAVE_PATH).load_progress()
	assert_eq(loaded["status"], "ok")
	var restored = loaded["session"]
	assert_true(restored.tutorial_completed)
	assert_true(restored.assembly.is_complete())
	assert_eq(restored.assembly.part_for_slot(BunekoPartSlot.Value.HEAD).id, BaseBunekoParts.HEAD_ID)
	assert_true(restored.baton_checkpoint_active)
	assert_true(restored.baton_checkpoint_intro_seen)
	assert_true(restored.preparation_confirmed)
	assert_true(restored.laboratory_first_completed)
	assert_eq(restored.money, 10)
	assert_eq(restored.graph_state.start_block_id, "editor_block_1")
	assert_eq(restored.graph_state.blocks["editor_block_2"].position, Vector2(410, 260))
	assert_eq(restored.graph_state.blocks["editor_block_1"].parameters["pace"], MovementPace.Value.FAST)
	assert_eq(restored.graph_state.connections.size(), 1)
	assert_eq(restored.graph_state.connections[0].to_block_id, "editor_block_2")
	var factory := BrainEditorBlockFactory.new()
	factory.reserve_existing_ids(restored.graph_state.blocks.keys())
	assert_eq(factory.create_block(ProgramBlockKind.Value.WALK).id, "editor_block_3")

func test_invalid_draft_is_restored_without_becoming_executable() -> void:
	var session = _sample_session()
	session.graph_state.add_block(BlockScript.new("unfinished", ProgramBlockKind.Value.IF, Vector2(500, 300)))
	session.preparation_confirmed = false
	assert_true(SaveStoreScript.new(SAVE_PATH).save_progress(session))
	var restored = SaveStoreScript.new(SAVE_PATH).load_progress()["session"]
	assert_true(restored.graph_state.blocks.has("unfinished"))
	assert_false(restored.preparation_confirmed)
	var program = ProgramGraphBuilder.new().build(restored.graph_state)
	assert_false(restored.program_can_run(program))

func test_missing_corrupt_and_unknown_version_do_not_erase_existing_file() -> void:
	var store = SaveStoreScript.new(SAVE_PATH)
	assert_eq(store.load_progress()["status"], "missing")
	var file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	file.store_string("{broken")
	file.close()
	var invalid = SaveStoreScript.new(SAVE_PATH)
	assert_eq(invalid.load_progress()["status"], "invalid")
	assert_false(invalid.save_progress(_sample_session()))
	assert_eq(FileAccess.get_file_as_string(SAVE_PATH), "{broken")
	var versioned := SaveCodecScript.encode(_sample_session())
	versioned["version"] = 999
	file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	file.store_string(JSON.stringify(versioned))
	file.close()
	assert_eq(SaveStoreScript.new(SAVE_PATH).load_progress()["status"], "invalid")

func test_unknown_part_and_block_ids_are_rejected() -> void:
	var data := SaveCodecScript.encode(_sample_session())
	data["parts"][0]["id"] = "unregistered_head"
	assert_null(SaveCodecScript.decode(data))
	data = SaveCodecScript.encode(_sample_session())
	data["graph"]["blocks"][0]["kind"] = 9876
	assert_null(SaveCodecScript.decode(data))

func test_new_game_replaces_only_after_explicit_store_call() -> void:
	var old_session = _sample_session()
	assert_true(SaveStoreScript.new(SAVE_PATH).save_progress(old_session))
	var store = SaveStoreScript.new(SAVE_PATH)
	assert_eq(store.load_progress()["session"].money, 10)
	assert_true(store.replace_with_new_game(SessionScript.new()))
	var restored = SaveStoreScript.new(SAVE_PATH).load_progress()["session"]
	assert_false(restored.tutorial_completed)
	assert_eq(restored.money, 0)

func test_first_completion_pays_once_even_after_reload() -> void:
	var session = _sample_session()
	session.money = 0
	session.laboratory_first_completed = false
	assert_true(session.complete_laboratory())
	assert_true(SaveStoreScript.new(SAVE_PATH).save_progress(session))
	var restored = SaveStoreScript.new(SAVE_PATH).load_progress()["session"]
	assert_false(restored.complete_laboratory())
	assert_eq(restored.money, 10)

func test_failed_write_preserves_existing_progress() -> void:
	var original = _sample_session()
	assert_true(SaveStoreScript.new(SAVE_PATH).save_progress(original))
	var previous_text := FileAccess.get_file_as_string(SAVE_PATH)
	var absolute_directory := ProjectSettings.globalize_path(SAVE_PATH + ".tmp")
	assert_eq(DirAccess.make_dir_absolute(absolute_directory), OK)
	var failed_store = SaveStoreScript.new(SAVE_PATH)
	assert_false(failed_store.save_progress(_sample_session()))
	assert_eq(FileAccess.get_file_as_string(SAVE_PATH), previous_text)
	assert_eq(DirAccess.remove_absolute(absolute_directory), OK)

func _sample_session():
	var graph = GraphScript.new()
	graph.add_block(BlockScript.new("editor_block_1", ProgramBlockKind.Value.WALK, Vector2(230, 108), null, {"pace": MovementPace.Value.FAST}))
	graph.add_block(BlockScript.new("editor_block_2", ProgramBlockKind.Value.JUMP, Vector2(410, 260)))
	graph.set_start_block("editor_block_1")
	graph.add_connection(ConnectionScript.new("editor_block_1", "next", "editor_block_2"))
	var session = SessionScript.new()
	session.complete_tutorial(BaseBunekoParts.complete_assembly(), graph)
	session.preparation_confirmed = true
	session.activate_baton_checkpoint()
	session.preparation_confirmed = true
	session.complete_laboratory()
	return session

func _remove_save() -> void:
	for suffix in ["", ".tmp"]:
		var path: String = SAVE_PATH + suffix
		if FileAccess.file_exists(path):
			DirAccess.remove_absolute(ProjectSettings.globalize_path(path))
