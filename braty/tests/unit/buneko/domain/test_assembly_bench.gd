extends GutTest

const AssemblyBenchScript = preload("res://src/buneko/assembly/assembly_bench.gd")
const SlotScript = preload("res://src/buneko/domain/part_slot.gd")

func test_confirm_is_blocked_until_assembly_is_complete() -> void:
	var bench = AssemblyBenchScript.new()

	assert_false(bench.can_confirm())

	assert_true(bench.install_base_part(SlotScript.Value.HEAD))
	assert_false(bench.can_confirm())

	bench.install_base_part(SlotScript.Value.BODY)
	bench.install_base_part(SlotScript.Value.LOCOMOTION)
	assert_true(bench.can_confirm())
	bench.free()

func test_remove_part_blocks_confirmation_again() -> void:
	var bench = AssemblyBenchScript.new()
	bench.install_all_base_parts()

	assert_true(bench.can_confirm())
	assert_true(bench.remove_part(SlotScript.Value.HEAD))

	assert_false(bench.can_confirm())
	bench.free()

func test_invalid_slot_cannot_install_part() -> void:
	var bench = AssemblyBenchScript.new()

	assert_false(bench.install_base_part(999))
	bench.free()

func test_visual_bench_updates_preview_progress_and_confirmation() -> void:
	var scene: PackedScene = load("res://scenes/buneko/assembly_bench.tscn")
	var bench = scene.instantiate()
	add_child_autofree(bench)
	await get_tree().process_frame

	assert_not_null(bench.preview)
	assert_eq(bench.progress_label.text, "0/3 pecas instaladas")
	assert_true(bench.confirm_button.disabled)

	bench.install_all_base_parts()

	assert_eq(bench.preview.installed_count(), 3)
	assert_eq(bench.progress_label.text, "3/3 pecas instaladas")
	assert_false(bench.confirm_button.disabled)
	assert_true(bench.inspector_detail.text.length() > 0)

func test_preview_drop_uses_regular_installation_flow() -> void:
	var scene: PackedScene = load("res://scenes/buneko/assembly_bench.tscn")
	var bench = scene.instantiate()
	add_child_autofree(bench)
	await get_tree().process_frame

	bench.preview.part_dropped.emit(SlotScript.Value.HEAD)

	assert_not_null(bench.assembly.part_for_slot(SlotScript.Value.HEAD))
	assert_eq(bench.installed_count(), 1)
