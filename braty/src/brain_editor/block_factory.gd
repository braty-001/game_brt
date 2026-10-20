class_name BrainEditorBlockFactory
extends RefCounted

const EditorBlockStateScript = preload("res://src/brain_editor/editor_block_state.gd")
const MovementPaceScript = preload("res://src/programming/domain/movement_pace.gd")
const PresentationRegistryScript = preload("res://src/brain_editor/block_presentation_registry.gd")

var _next_id := 1
var presentation_registry = PresentationRegistryScript.new()
var allowed_kinds: Array[int] = []

func create_block(kind: int, position: Vector2 = Vector2.ZERO, condition: ProgramCondition = null):
	if not ProgramBlockKind.is_valid(kind) or not palette_kinds().has(kind):
		return null

	var block_id := "editor_block_%d" % _next_id
	_next_id += 1
	var parameters := {}
	if kind == ProgramBlockKind.Value.WALK:
		parameters = MovementPaceScript.default_parameters()
	return EditorBlockStateScript.new(block_id, kind, position, condition, parameters)

func reserve_existing_ids(block_ids: Array) -> void:
	for block_id in block_ids:
		if typeof(block_id) != TYPE_STRING or not block_id.begins_with("editor_block_"):
			continue
		var suffix: String = block_id.trim_prefix("editor_block_")
		if suffix.is_valid_int():
			_next_id = maxi(_next_id, suffix.to_int() + 1)

func label_for_kind(kind: int) -> String:
	return presentation_registry.presentation_for(kind).get("label", "")

func output_ports_for_kind(kind: int) -> PackedStringArray:
	if not ProgramBlockKind.is_valid(kind):
		return PackedStringArray()

	return presentation_registry.presentation_for(kind).get("ports", PackedStringArray())

func palette_kinds() -> Array[int]:
	if not allowed_kinds.is_empty():
		return allowed_kinds.duplicate()
	return [
		ProgramBlockKind.Value.WALK,
		ProgramBlockKind.Value.JUMP,
		ProgramBlockKind.Value.TURN,
		ProgramBlockKind.Value.IF,
		ProgramBlockKind.Value.WHILE,
	]
