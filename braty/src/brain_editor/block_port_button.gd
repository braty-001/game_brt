class_name BrainEditorBlockPortButton
extends Button

signal block_dropped(kind: int)

func _can_drop_data(_at_position: Vector2, data) -> bool:
	return data is Dictionary and data.get("type", "") == "brain_block"

func _drop_data(_at_position: Vector2, data) -> void:
	block_dropped.emit(int(data["kind"]))
