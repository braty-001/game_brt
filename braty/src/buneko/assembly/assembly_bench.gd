class_name AssemblyBench
extends Control

const AssemblyScript = preload("res://src/buneko/domain/buneko_assembly.gd")
const AssemblyValidatorScript = preload("res://src/buneko/domain/buneko_assembly_validator.gd")
const BasePartsScript = preload("res://src/buneko/domain/base_buneko_parts.gd")
const PartItemScript = preload("res://src/buneko/assembly/assembly_part_item.gd")
const SlotScript = preload("res://src/buneko/domain/part_slot.gd")
const Tokens = preload("res://src/ui/design_tokens.gd")

signal assembly_confirmed(assembly)
signal assembly_changed(assembly)

var assembly
var selected_slot := -1
var part_items: Dictionary = {}
var preview
var inspector_title: Label
var inspector_detail: Label
var remove_button: Button
var progress_label: Label
var status_label: Label
var confirm_button: Button

func _ready() -> void:
	_ensure_assembly()
	_build_ui()
	_refresh_ui()

func install_base_part(slot: int) -> bool:
	_ensure_assembly()
	var part = _base_part_for_slot(slot)
	if part == null:
		return false

	var installed: bool = assembly.install_part(part)
	if installed:
		selected_slot = slot
		assembly_changed.emit(assembly)
		_refresh_ui()
	return installed

func remove_part(slot: int) -> bool:
	_ensure_assembly()
	var removed: bool = assembly.remove_part(slot)
	if removed:
		selected_slot = slot
		assembly_changed.emit(assembly)
		_refresh_ui()
	return removed

func can_confirm() -> bool:
	_ensure_assembly()
	return AssemblyValidatorScript.new().is_valid(assembly)

func confirm() -> bool:
	if not can_confirm():
		return false
	assembly_confirmed.emit(assembly)
	return true

func install_all_base_parts() -> void:
	for slot in SlotScript.all_slots():
		install_base_part(slot)
	_refresh_ui()

func installed_count() -> int:
	_ensure_assembly()
	return assembly.parts_by_slot.size()

func select_slot(slot: int) -> void:
	if not SlotScript.is_valid(slot):
		return
	selected_slot = slot
	_refresh_ui()

func _build_ui() -> void:
	if confirm_button != null:
		return

	var background: ColorRect = get_node("Background")
	background.color = Tokens.BACKGROUND
	var subtitle: Label = get_node("Margin/Page/Subtitle")
	subtitle.add_theme_color_override("font_color", Tokens.TEXT_MUTED)
	var tray_panel: PanelContainer = get_node("Margin/Page/Content/TrayPanel")
	Tokens.apply_panel(tray_panel)
	var tray_title: Label = get_node("Margin/Page/Content/TrayPanel/Tray/TrayTitle")
	tray_title.add_theme_color_override("font_color", Tokens.TEXT_MUTED)
	var part_list: VBoxContainer = get_node("Margin/Page/Content/TrayPanel/Tray/PartList")
	_add_part_item(part_list, SlotScript.Value.HEAD, "Cabeca base", "Cerebro - 5 RAM")
	_add_part_item(part_list, SlotScript.Value.BODY, "Corpo base", "Estrutura equilibrada")
	_add_part_item(part_list, SlotScript.Value.LOCOMOTION, "Locomocao base", "Pernas de plataforma")
	var tray_hint: Label = get_node("Margin/Page/Content/TrayPanel/Tray/TrayHint")
	tray_hint.add_theme_color_override("font_color", Tokens.TEXT_MUTED)
	var preview_panel: PanelContainer = get_node("Margin/Page/Content/PreviewPanel")
	Tokens.apply_panel(preview_panel, Color("202b31"))
	preview = get_node("Margin/Page/Content/PreviewPanel/AssemblyPreview")
	preview.part_dropped.connect(_on_part_dropped)
	var inspector_panel: PanelContainer = get_node("Margin/Page/Content/InspectorPanel")
	Tokens.apply_panel(inspector_panel)
	var inspector_heading: Label = get_node("Margin/Page/Content/InspectorPanel/Inspector/InspectorHeading")
	inspector_heading.add_theme_color_override("font_color", Tokens.TEXT_MUTED)
	inspector_title = get_node("Margin/Page/Content/InspectorPanel/Inspector/InspectorTitle")
	inspector_detail = get_node("Margin/Page/Content/InspectorPanel/Inspector/InspectorDetail")
	remove_button = get_node("Margin/Page/Content/InspectorPanel/Inspector/RemoveButton")
	Tokens.apply_secondary_button(remove_button)
	remove_button.pressed.connect(_on_remove_pressed)
	progress_label = get_node("Margin/Page/Content/InspectorPanel/Inspector/ProgressLabel")
	status_label = get_node("Margin/Page/Content/InspectorPanel/Inspector/StatusLabel")
	status_label.add_theme_color_override("font_color", Tokens.TEXT_MUTED)
	confirm_button = get_node("Margin/Page/Content/InspectorPanel/Inspector/ConfirmButton")
	confirm_button.name = "ConfirmButton"
	Tokens.apply_primary_button(confirm_button)
	confirm_button.pressed.connect(confirm)

func _add_part_item(parent: VBoxContainer, slot: int, title: String, detail: String) -> void:
	var item = PartItemScript.new()
	item.name = "Part_%s" % SlotScript.key(slot)
	item.configure(slot, title, detail)
	item.pressed.connect(_on_part_pressed.bind(slot))
	parent.add_child(item)
	part_items[slot] = item

func _refresh_ui() -> void:
	if confirm_button == null:
		return

	for slot in part_items:
		part_items[slot].set_installed(assembly.part_for_slot(slot) != null)

	preview.set_assembly(assembly)
	preview.set_selected_slot(selected_slot)
	progress_label.text = "%d/3 pecas instaladas" % installed_count()
	confirm_button.disabled = not can_confirm()
	status_label.text = "Montagem pronta para programar" if can_confirm() else "Complete os encaixes destacados"
	status_label.add_theme_color_override("font_color", Tokens.SUCCESS if can_confirm() else Tokens.TEXT_MUTED)
	_update_inspector()

func _update_inspector() -> void:
	if not SlotScript.is_valid(selected_slot):
		inspector_title.text = "Nenhuma peca"
		inspector_detail.text = "Selecione uma peca na bandeja para ver como ela participa do Buneko."
		remove_button.visible = false
		return

	var part = assembly.part_for_slot(selected_slot)
	inspector_title.text = _slot_title(selected_slot)
	inspector_detail.text = _slot_detail(selected_slot)
	remove_button.visible = part != null

func _on_part_pressed(slot: int) -> void:
	if assembly.part_for_slot(slot) == null:
		install_base_part(slot)
	else:
		select_slot(slot)

func _on_part_dropped(slot: int) -> void:
	install_base_part(slot)

func _on_remove_pressed() -> void:
	if SlotScript.is_valid(selected_slot):
		remove_part(selected_slot)

func _slot_title(slot: int) -> String:
	match slot:
		SlotScript.Value.HEAD:
			return "Cabeca base"
		SlotScript.Value.BODY:
			return "Corpo base"
		SlotScript.Value.LOCOMOTION:
			return "Locomocao base"
		_:
			return "Peca"

func _slot_detail(slot: int) -> String:
	match slot:
		SlotScript.Value.HEAD:
			return "Abriga o cerebro basico com 5 unidades de RAM. Cada bloco conectado usa 1 RAM."
		SlotScript.Value.BODY:
			return "Estrutura central que conecta a cabeca aos sistemas de movimento."
		SlotScript.Value.LOCOMOTION:
			return "Pernas preparadas para andar, correr, virar e pular em plataformas."
		_:
			return ""

func _ensure_assembly() -> void:
	if assembly == null:
		assembly = AssemblyScript.new()

func _base_part_for_slot(slot: int):
	match slot:
		SlotScript.Value.HEAD:
			return BasePartsScript.head()
		SlotScript.Value.BODY:
			return BasePartsScript.body()
		SlotScript.Value.LOCOMOTION:
			return BasePartsScript.locomotion()
		_:
			return null
