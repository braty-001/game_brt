class_name BaseBunekoParts
extends RefCounted

const AssemblyScript = preload("res://src/buneko/domain/buneko_assembly.gd")
const PartScript = preload("res://src/buneko/domain/buneko_part.gd")
const SlotScript = preload("res://src/buneko/domain/part_slot.gd")

const HEAD_ID := "base_head"
const BODY_ID := "base_body"
const LOCOMOTION_ID := "base_locomotion"
const BASE_BRAIN_RAM := 5

static func head():
	return PartScript.new(HEAD_ID, SlotScript.Value.HEAD, "Cabeca Base", {"brain_ram": BASE_BRAIN_RAM})

static func body():
	return PartScript.new(BODY_ID, SlotScript.Value.BODY, "Corpo Base")

static func locomotion():
	return PartScript.new(LOCOMOTION_ID, SlotScript.Value.LOCOMOTION, "Locomocao Base")

static func all() -> Array:
	return [head(), body(), locomotion()]

static func complete_assembly():
	var assembly = AssemblyScript.new()
	for part in all():
		assembly.install_part(part)

	return assembly
