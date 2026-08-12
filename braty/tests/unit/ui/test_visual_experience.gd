extends GutTest

func test_shared_theme_and_header_load() -> void:
	var theme: Theme = load("res://themes/buneko_theme.tres")
	var header_scene: PackedScene = load("res://scenes/ui/mission_step_header.tscn")
	var header = header_scene.instantiate()
	add_child_autofree(header)
	await get_tree().process_frame

	assert_not_null(theme)
	assert_not_null(header.step_label)
	header.configure("ETAPA 1/3", "Objetivo", "Montando", "5 RAM")
	assert_eq(header.step_label.text, "ETAPA 1/3")
	assert_eq(header.ram_label.text, "5 RAM")

func test_assembly_preview_reflects_partial_and_complete_assembly() -> void:
	var preview_scene: PackedScene = load("res://scenes/buneko/buneko_assembly_preview.tscn")
	var preview = preview_scene.instantiate()
	var assembly = BunekoAssembly.new()
	add_child_autofree(preview)
	await get_tree().process_frame

	preview.set_assembly(assembly)
	assert_eq(preview.installed_count(), 0)
	assembly.install_part(BaseBunekoParts.head())
	preview.set_assembly(assembly)
	assert_eq(preview.installed_count(), 1)
	assembly.install_part(BaseBunekoParts.body())
	assembly.install_part(BaseBunekoParts.locomotion())
	preview.set_assembly(assembly)
	assert_eq(preview.installed_count(), 3)

func test_mission_regions_do_not_overlap_at_reference_size() -> void:
	var scene: PackedScene = load("res://scenes/tutorial/tutorial_mission.tscn")
	var mission = scene.instantiate()
	var viewport := SubViewport.new()
	viewport.size = Vector2i(960, 540)
	add_child_autofree(viewport)
	viewport.add_child(mission)
	await get_tree().process_frame
	await get_tree().process_frame

	var header_bottom: float = mission.mission_header.get_global_rect().end.y
	var stage_rect: Rect2 = mission.stage_container.get_global_rect()
	var guidance_rect: Rect2 = mission.feedback_label.get_parent().get_parent().get_global_rect()
	assert_lte(header_bottom, stage_rect.position.y)
	assert_lte(stage_rect.end.y, guidance_rect.position.y)
