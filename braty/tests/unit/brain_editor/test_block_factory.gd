extends GutTest

const BlockFactoryScript = preload("res://src/brain_editor/block_factory.gd")
const BlockKind = preload("res://src/programming/domain/block_kind.gd")
const ConditionCatalogScript = preload("res://src/programming/domain/condition_catalog.gd")
const MovementPaceScript = preload("res://src/programming/domain/movement_pace.gd")
const ProgramConditionScript = preload("res://src/programming/domain/program_condition.gd")

func test_palette_contains_mvp_blocks() -> void:
	var factory = BlockFactoryScript.new()

	assert_eq(
		factory.palette_kinds(),
		[
			BlockKind.Value.WALK,
			BlockKind.Value.JUMP,
			BlockKind.Value.TURN,
			BlockKind.Value.IF,
			BlockKind.Value.WHILE,
		]
	)

func test_creates_blocks_with_stable_unique_ids() -> void:
	var factory = BlockFactoryScript.new()

	var walk_block = factory.create_block(BlockKind.Value.WALK, Vector2(12, 24))
	var jump_block = factory.create_block(BlockKind.Value.JUMP)

	assert_ne(walk_block.id, jump_block.id)
	assert_eq(walk_block.kind, BlockKind.Value.WALK)
	assert_eq(walk_block.position, Vector2(12, 24))
	assert_eq(
		MovementPaceScript.from_parameters(walk_block.parameters),
		MovementPaceScript.Value.NORMAL
	)

func test_exposes_ports_for_action_and_control_blocks() -> void:
	var factory = BlockFactoryScript.new()

	assert_eq(factory.output_ports_for_kind(BlockKind.Value.WALK), PackedStringArray(["next"]))
	assert_eq(factory.output_ports_for_kind(BlockKind.Value.IF), PackedStringArray(["true", "false"]))
	assert_eq(factory.output_ports_for_kind(BlockKind.Value.WHILE), PackedStringArray(["body", "next"]))

func test_control_block_can_be_created_with_condition() -> void:
	var condition = ProgramConditionScript.new(
		ConditionCatalogScript.Modality.VISION,
		ConditionCatalogScript.Query.GAP_AHEAD
	)
	var factory = BlockFactoryScript.new()

	var block = factory.create_block(BlockKind.Value.IF, Vector2.ZERO, condition)

	assert_eq(block.condition.query, ConditionCatalogScript.Query.GAP_AHEAD)

func test_invalid_kind_returns_null_and_empty_metadata() -> void:
	var factory = BlockFactoryScript.new()

	assert_null(factory.create_block(999))
	assert_eq(factory.label_for_kind(999), "")
	assert_eq(factory.output_ports_for_kind(999), PackedStringArray())
