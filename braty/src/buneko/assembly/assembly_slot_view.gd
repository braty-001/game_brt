class_name AssemblySlotView
extends Button

var slot: int
var installed_part_id: String

func configure(slot_value: int, label: String) -> void:
	slot = slot_value
	text = label
	_update_text()

func set_installed_part(part) -> void:
	if part == null:
		installed_part_id = ""
	else:
		installed_part_id = part.id
	_update_text()

func _update_text() -> void:
	if installed_part_id.is_empty():
		return

	text = "%s: %s" % [text.get_slice(":", 0), installed_part_id]
