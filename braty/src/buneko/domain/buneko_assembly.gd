class_name BunekoAssembly
extends RefCounted

const SlotScript = preload("res://src/buneko/domain/part_slot.gd")

var parts_by_slot: Dictionary = {}

func install_part(part) -> bool:
	if part == null or not part.is_valid():
		return false

	parts_by_slot[part.slot] = part
	return true

func remove_part(slot: int) -> bool:
	if not parts_by_slot.has(slot):
		return false

	parts_by_slot.erase(slot)
	return true

func part_for_slot(slot: int):
	if not parts_by_slot.has(slot):
		return null

	return parts_by_slot[slot]

func is_complete() -> bool:
	for slot in SlotScript.all_slots():
		if not parts_by_slot.has(slot):
			return false

	return true
