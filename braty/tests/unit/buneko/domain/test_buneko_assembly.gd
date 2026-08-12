extends GutTest

const AssemblyScript = preload("res://src/buneko/domain/buneko_assembly.gd")
const AssemblyValidatorScript = preload("res://src/buneko/domain/buneko_assembly_validator.gd")
const BasePartsScript = preload("res://src/buneko/domain/base_buneko_parts.gd")
const PartScript = preload("res://src/buneko/domain/buneko_part.gd")
const SlotScript = preload("res://src/buneko/domain/part_slot.gd")

func test_base_parts_fit_only_their_slots() -> void:
	var head = BasePartsScript.head()
	var body = BasePartsScript.body()
	var locomotion = BasePartsScript.locomotion()

	assert_true(head.fits_slot(SlotScript.Value.HEAD))
	assert_false(head.fits_slot(SlotScript.Value.BODY))
	assert_true(body.fits_slot(SlotScript.Value.BODY))
	assert_true(locomotion.fits_slot(SlotScript.Value.LOCOMOTION))

func test_incomplete_assembly_reports_missing_parts() -> void:
	var assembly = AssemblyScript.new()
	assembly.install_part(BasePartsScript.head())

	var errors = AssemblyValidatorScript.new().validate(assembly)

	assert_eq(errors.size(), 2)
	assert_false(assembly.is_complete())
	assert_false(AssemblyValidatorScript.new().is_valid(assembly))

func test_complete_base_assembly_is_valid() -> void:
	var assembly = BasePartsScript.complete_assembly()

	assert_true(assembly.is_complete())
	assert_eq(AssemblyValidatorScript.new().validate(assembly).size(), 0)

func test_wrong_slot_is_reported_when_part_is_forced_into_slot() -> void:
	var assembly = AssemblyScript.new()
	assembly.parts_by_slot[SlotScript.Value.HEAD] = BasePartsScript.body()
	assembly.install_part(BasePartsScript.body())
	assembly.install_part(BasePartsScript.locomotion())

	var errors = AssemblyValidatorScript.new().validate(assembly)

	assert_eq(errors.size(), 1)
	assert_eq(errors[0].code, AssemblyValidatorScript.Code.WRONG_SLOT)
	assert_eq(errors[0].slot, SlotScript.Value.HEAD)

func test_removing_part_updates_completion() -> void:
	var assembly = BasePartsScript.complete_assembly()

	assert_true(assembly.remove_part(SlotScript.Value.BODY))

	assert_false(assembly.is_complete())
	assert_null(assembly.part_for_slot(SlotScript.Value.BODY))
