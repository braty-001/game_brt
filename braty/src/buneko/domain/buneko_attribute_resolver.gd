class_name BunekoAttributeResolver
extends RefCounted

const AttributesScript = preload("res://src/buneko/domain/buneko_attributes.gd")
const SlotScript = preload("res://src/buneko/domain/part_slot.gd")

static func resolve(assembly, base_attributes = null):
	var resolved = AttributesScript.new()
	if base_attributes != null:
		resolved = base_attributes.duplicate_attributes()

	if assembly == null:
		return resolved

	for slot in SlotScript.all_slots():
		var part = assembly.part_for_slot(slot)
		if part != null:
			resolved.apply_modifiers(part.attribute_modifiers)

	return resolved
