class_name RuntimeFrame
extends RefCounted

enum Kind {
	REPEAT_WHILE,
}

var kind: int
var block_id: String

func _init(frame_kind: int, frame_block_id: String) -> void:
	kind = frame_kind
	block_id = frame_block_id
