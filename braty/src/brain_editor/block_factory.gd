class_name BrainEditorBlockFactory
extends RefCounted

const EditorBlockStateScript = preload("res://src/brain_editor/editor_block_state.gd")

var _next_id := 1

func create_block(kind: int, position: Vector2 = Vector2.ZERO, condition: ProgramCondition = null):
	if not ProgramBlockKind.is_valid(kind):
		return null

	var block_id := "editor_block_%d" % _next_id
	_next_id += 1
	return EditorBlockStateScript.new(block_id, kind, position, condition)

func label_for_kind(kind: int) -> String:
	match kind:
		ProgramBlockKind.Value.WALK:
			return "Andar"
		ProgramBlockKind.Value.RUN:
			return "Correr"
		ProgramBlockKind.Value.JUMP:
			return "Pular"
		ProgramBlockKind.Value.TURN:
			return "Virar"
		ProgramBlockKind.Value.IF:
			return "IF"
		ProgramBlockKind.Value.WHILE:
			return "WHILE"
		_:
			return ""

func output_ports_for_kind(kind: int) -> PackedStringArray:
	if not ProgramBlockKind.is_valid(kind):
		return PackedStringArray()

	return ProgramBlockKind.output_ports(kind)

func palette_kinds() -> Array[int]:
	return [
		ProgramBlockKind.Value.WALK,
		ProgramBlockKind.Value.RUN,
		ProgramBlockKind.Value.JUMP,
		ProgramBlockKind.Value.TURN,
		ProgramBlockKind.Value.IF,
		ProgramBlockKind.Value.WHILE,
	]
