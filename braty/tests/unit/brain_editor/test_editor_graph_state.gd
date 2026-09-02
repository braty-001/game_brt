extends GutTest

const BlockKind = preload("res://src/programming/domain/block_kind.gd")
const ConditionCatalogScript = preload("res://src/programming/domain/condition_catalog.gd")
const EditorBlockStateScript = preload("res://src/brain_editor/editor_block_state.gd")
const EditorConnectionStateScript = preload("res://src/brain_editor/editor_connection_state.gd")
const EditorGraphStateScript = preload("res://src/brain_editor/editor_graph_state.gd")
const MovementPaceScript = preload("res://src/programming/domain/movement_pace.gd")
const ProgramConditionScript = preload("res://src/programming/domain/program_condition.gd")

func test_valid_mutations_emit_the_change_and_affected_blocks() -> void:
	var graph = EditorGraphStateScript.new()
	var events: Array[Dictionary] = []
	graph.changed.connect(func(change: int, block_ids: PackedStringArray) -> void:
		events.append({"change": change, "block_ids": block_ids})
	)
	var walk = EditorBlockStateScript.new("walk", BlockKind.Value.WALK)
	var jump = EditorBlockStateScript.new("jump", BlockKind.Value.JUMP)

	assert_true(graph.add_block(walk))
	assert_true(graph.set_start_block("walk"))
	assert_true(graph.move_block("walk", Vector2(80, 40)))
	assert_true(graph.set_block_condition("walk", _gap_condition()))
	assert_true(graph.add_block(jump))
	assert_true(graph.add_connection(EditorConnectionStateScript.new("walk", "next", "jump")))
	assert_eq(graph.remove_connection("walk", "next"), 1)
	assert_true(graph.remove_block("walk"))

	assert_eq(events.size(), 8)
	assert_eq(events[0]["change"], EditorGraphStateScript.Change.BLOCK_ADDED)
	assert_eq(events[1]["change"], EditorGraphStateScript.Change.START_CHANGED)
	assert_eq(events[2]["change"], EditorGraphStateScript.Change.BLOCK_MOVED)
	assert_eq(events[3]["change"], EditorGraphStateScript.Change.CONDITION_CHANGED)
	assert_eq(events[5]["change"], EditorGraphStateScript.Change.CONNECTION_ADDED)
	assert_eq(events[6]["change"], EditorGraphStateScript.Change.CONNECTION_REMOVED)
	assert_eq(events[7]["change"], EditorGraphStateScript.Change.BLOCK_REMOVED)
	assert_true(events[7]["block_ids"].has("walk"))

func test_refused_mutations_do_not_emit_changes() -> void:
	var graph = EditorGraphStateScript.new()
	var change_count := 0
	graph.changed.connect(func(_change: int, _block_ids: PackedStringArray) -> void:
		change_count += 1
	)

	assert_false(graph.move_block("unknown", Vector2.ONE))
	assert_false(graph.set_start_block("unknown"))
	assert_false(graph.add_connection(EditorConnectionStateScript.new("a", "next", "b")))
	assert_eq(graph.remove_connection("a", "next"), 0)

	assert_eq(change_count, 0)

func test_parameter_mutation_is_observable() -> void:
	var graph = EditorGraphStateScript.new()
	var changes: Array[int] = []
	graph.changed.connect(func(change: int, _block_ids: PackedStringArray) -> void:
		changes.append(change)
	)
	graph.add_block(EditorBlockStateScript.new("walk", BlockKind.Value.WALK))

	assert_true(graph.set_block_parameter(
		"walk",
		MovementPaceScript.PARAMETER_KEY,
		MovementPaceScript.Value.FAST
	))

	assert_eq(changes[-1], EditorGraphStateScript.Change.PARAMETER_CHANGED)
	assert_eq(
		MovementPaceScript.from_parameters(graph.blocks["walk"].parameters),
		MovementPaceScript.Value.FAST
	)

func _gap_condition() -> ProgramCondition:
	return ProgramConditionScript.new(
		ConditionCatalogScript.Modality.VISION,
		ConditionCatalogScript.Query.GAP_AHEAD
	)
