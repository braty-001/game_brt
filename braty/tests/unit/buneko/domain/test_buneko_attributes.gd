extends GutTest

const AssemblyScript = preload("res://src/buneko/domain/buneko_assembly.gd")
const AttributeResolverScript = preload("res://src/buneko/domain/buneko_attribute_resolver.gd")
const AttributesScript = preload("res://src/buneko/domain/buneko_attributes.gd")
const BasePartsScript = preload("res://src/buneko/domain/base_buneko_parts.gd")
const PartScript = preload("res://src/buneko/domain/buneko_part.gd")
const SlotScript = preload("res://src/buneko/domain/part_slot.gd")

func test_base_assembly_resolves_default_attributes() -> void:
	var assembly = BasePartsScript.complete_assembly()

	var attributes = AttributeResolverScript.new().resolve(assembly)

	assert_gt(attributes.movement_speed, 0.0)
	assert_gt(attributes.ground_deceleration, 0.0)
	assert_gt(attributes.jump_impulse, 0.0)
	assert_gt(attributes.gravity, 0.0)
	assert_eq(attributes.strength, 1.0)

func test_part_modifiers_extend_base_attributes() -> void:
	var assembly = AssemblyScript.new()
	var base_attributes = AttributesScript.new(100.0, 150.0, 200.0, 900.0, 1.0)
	assembly.install_part(PartScript.new(
		"fast_locomotion",
		SlotScript.Value.LOCOMOTION,
		"Locomocao Rapida",
		{"movement_speed": 25.0, "ground_deceleration": 50.0}
	))

	var attributes = AttributeResolverScript.new().resolve(assembly, base_attributes)

	assert_eq(attributes.movement_speed, 125.0)
	assert_eq(attributes.ground_deceleration, 200.0)
	assert_eq(attributes.jump_impulse, 200.0)

func test_unknown_modifiers_are_ignored() -> void:
	var attributes = AttributesScript.new()

	attributes.apply_modifiers({"unknown": 99.0, "strength": 2.0})

	assert_eq(attributes.strength, 3.0)
