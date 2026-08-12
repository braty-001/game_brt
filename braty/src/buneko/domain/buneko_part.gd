class_name BunekoPart
extends RefCounted

const SlotScript = preload("res://src/buneko/domain/part_slot.gd")

var id: String
var slot: int
var display_name: String
var attribute_modifiers: Dictionary

func _init(
	part_id: String,
	part_slot: int,
	part_display_name: String,
	part_attribute_modifiers: Dictionary = {}
) -> void:
	id = part_id
	slot = part_slot
	display_name = part_display_name
	attribute_modifiers = part_attribute_modifiers.duplicate(true)

func is_valid() -> bool:
	return not id.is_empty() and SlotScript.is_valid(slot)

func fits_slot(target_slot: int) -> bool:
	return is_valid() and slot == target_slot
