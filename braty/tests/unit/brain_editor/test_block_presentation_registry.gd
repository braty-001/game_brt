extends GutTest

const BlockKind = preload("res://src/programming/domain/block_kind.gd")
const RegistryScript = preload("res://src/brain_editor/block_presentation_registry.gd")

func test_control_blocks_have_distinct_shapes_and_ports() -> void:
	var registry = RegistryScript.new()
	var if_presentation: Dictionary = registry.presentation_for(BlockKind.Value.IF)
	var while_presentation: Dictionary = registry.presentation_for(BlockKind.Value.WHILE)

	assert_eq(if_presentation["shape"], RegistryScript.Shape.BRANCH)
	assert_eq(if_presentation["ports"], PackedStringArray(["true", "false"]))
	assert_eq(while_presentation["shape"], RegistryScript.Shape.LOOP)
	assert_eq(while_presentation["ports"], PackedStringArray(["body", "next"]))

func test_actions_share_a_compact_presentation_contract() -> void:
	var presentation: Dictionary = RegistryScript.new().presentation_for(BlockKind.Value.JUMP)

	assert_eq(presentation["shape"], RegistryScript.Shape.ACTION)
	assert_eq(presentation["label"], "Pular")
	assert_eq(presentation["pseudocode"], "PULAR")
