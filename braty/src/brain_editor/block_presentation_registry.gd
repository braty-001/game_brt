class_name BrainEditorBlockPresentationRegistry
extends RefCounted

enum Shape {
	ACTION,
	BRANCH,
	LOOP,
}

func presentation_for(kind: int) -> Dictionary:
	match kind:
		ProgramBlockKind.Value.WALK:
			return _action("Andar", "ANDAR")
		ProgramBlockKind.Value.JUMP:
			return _action("Pular", "PULAR")
		ProgramBlockKind.Value.TURN:
			return _action("Virar", "VIRAR")
		ProgramBlockKind.Value.ATTACK:
			return _action("Atacar", "ATACAR")
		ProgramBlockKind.Value.IF:
			return {
				"label": "IF",
				"shape": Shape.BRANCH,
				"ports": PackedStringArray(["true", "false"]),
				"size": Vector2(184, 94),
			}
		ProgramBlockKind.Value.WHILE:
			return {
				"label": "WHILE",
				"shape": Shape.LOOP,
				"ports": PackedStringArray(["body", "next"]),
				"size": Vector2(176, 90),
			}
		_:
			return {}

func _action(label: String, pseudocode: String) -> Dictionary:
	return {
		"label": label,
		"shape": Shape.ACTION,
		"ports": PackedStringArray(["next"]),
		"size": Vector2(154, 76),
		"pseudocode": pseudocode,
	}
