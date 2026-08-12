class_name BunekoAssemblyValidator
extends RefCounted

const SlotScript = preload("res://src/buneko/domain/part_slot.gd")

enum Code {
	MISSING_PART,
	INVALID_PART,
	WRONG_SLOT,
}

class Error:
	var code: int
	var slot: int
	var part_id: String

	func _init(error_code: int, error_slot: int, error_part_id: String = "") -> void:
		code = error_code
		slot = error_slot
		part_id = error_part_id

static func validate(assembly) -> Array:
	var errors: Array = []
	if assembly == null:
		for slot in SlotScript.all_slots():
			errors.append(Error.new(Code.MISSING_PART, slot))
		return errors

	for slot in SlotScript.all_slots():
		var part = assembly.part_for_slot(slot)
		if part == null:
			errors.append(Error.new(Code.MISSING_PART, slot))
			continue

		if not part.is_valid():
			errors.append(Error.new(Code.INVALID_PART, slot, part.id))
		elif not part.fits_slot(slot):
			errors.append(Error.new(Code.WRONG_SLOT, slot, part.id))

	return errors

static func is_valid(assembly) -> bool:
	return validate(assembly).is_empty()
