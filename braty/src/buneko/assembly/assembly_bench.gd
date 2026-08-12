class_name AssemblyBench
extends Control

const AssemblyScript = preload("res://src/buneko/domain/buneko_assembly.gd")
const AssemblyValidatorScript = preload("res://src/buneko/domain/buneko_assembly_validator.gd")
const BasePartsScript = preload("res://src/buneko/domain/base_buneko_parts.gd")
const PartItemScript = preload("res://src/buneko/assembly/assembly_part_item.gd")
const PreviewScript = preload("res://src/buneko/assembly/buneko_assembly_preview.gd")
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

	anchors_preset = PRESET_FULL_RECT
	anchor_right = 1.0
	anchor_bottom = 1.0

	var background := ColorRect.new()
	background.color = Tokens.BACKGROUND
	background.set_anchors_preset(PRESET_FULL_RECT)
	background.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(background)

	var margin := MarginContainer.new()
	margin.set_anchors_preset(PRESET_FULL_RECT)
	margin.add_theme_constant_override("margin_left", 18)
	margin.add_theme_constant_override("margin_right", 18)
	margin.add_theme_constant_override("margin_top", 14)
	margin.add_theme_constant_override("margin_bottom", 14)
	add_child(margin)

	var page := VBoxContainer.new()
	page.add_theme_constant_override("separation", 12)
	margin.add_child(page)

	var title := Label.new()
	title.text = "Monte seu Buneko"
	title.add_theme_font_size_override("font_size", 26)
	page.add_child(title)

	var subtitle := Label.new()
	subtitle.text = "Instale cabeca, corpo e locomocao. A cabeca leva o cerebro que executa seu programa."
	subtitle.add_theme_color_override("font_color", Tokens.TEXT_MUTED)
	page.add_child(subtitle)

	var content := HBoxContainer.new()
	content.size_flags_vertical = Control.SIZE_EXPAND_FILL
	content.add_theme_constant_override("separation", 12)
	page.add_child(content)

	var tray_panel := PanelContainer.new()
	tray_panel.custom_minimum_size.x = 230.0
	Tokens.apply_panel(tray_panel)
	content.add_child(tray_panel)
	var tray := VBoxContainer.new()
	tray.add_theme_constant_override("separation", 8)
	tray_panel.add_child(tray)
	var tray_title := Label.new()
	tray_title.text = "PECAS DISPONIVEIS"
	tray_title.add_theme_color_override("font_color", Tokens.TEXT_MUTED)
	tray.add_child(tray_title)
	_add_part_item(tray, SlotScript.Value.HEAD, "Cabeca base", "Cerebro - 5 RAM")
	_add_part_item(tray, SlotScript.Value.BODY, "Corpo base", "Estrutura equilibrada")
	_add_part_item(tray, SlotScript.Value.LOCOMOTION, "Locomocao base", "Pernas de plataforma")
	var tray_hint := Label.new()
	tray_hint.text = "Clique em uma peca para instalar. Clique novamente para inspecionar."
	tray_hint.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	tray_hint.add_theme_color_override("font_color", Tokens.TEXT_MUTED)
	tray.add_child(tray_hint)

	var preview_panel := PanelContainer.new()
	preview_panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	Tokens.apply_panel(preview_panel, Color("202b31"))
	content.add_child(preview_panel)
	preview = PreviewScript.new()
	preview.name = "AssemblyPreview"
	preview.part_dropped.connect(_on_part_dropped)
	preview_panel.add_child(preview)

	var inspector_panel := PanelContainer.new()
	inspector_panel.custom_minimum_size.x = 245.0
	Tokens.apply_panel(inspector_panel)
	content.add_child(inspector_panel)
	var inspector := VBoxContainer.new()
	inspector.add_theme_constant_override("separation", 6)
	inspector_panel.add_child(inspector)
	var inspector_heading := Label.new()
	inspector_heading.text = "PECA SELECIONADA"
	inspector_heading.add_theme_color_override("font_color", Tokens.TEXT_MUTED)
	inspector.add_child(inspector_heading)
	inspector_title = Label.new()
	inspector_title.add_theme_font_size_override("font_size", 20)
	inspector.add_child(inspector_title)
	inspector_detail = Label.new()
	inspector_detail.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	inspector_detail.size_flags_vertical = Control.SIZE_EXPAND_FILL
	inspector.add_child(inspector_detail)
	remove_button = Button.new()
	remove_button.text = "Remover peca"
	Tokens.apply_secondary_button(remove_button)
	remove_button.pressed.connect(_on_remove_pressed)
	inspector.add_child(remove_button)
	var inspector_separator := HSeparator.new()
	inspector.add_child(inspector_separator)
	progress_label = Label.new()
	progress_label.add_theme_font_size_override("font_size", 16)
	inspector.add_child(progress_label)
	status_label = Label.new()
	status_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	status_label.add_theme_color_override("font_color", Tokens.TEXT_MUTED)
	inspector.add_child(status_label)
	confirm_button = Button.new()
	confirm_button.name = "ConfirmButton"
	confirm_button.text = "Confirmar montagem"
	confirm_button.custom_minimum_size.x = 220.0
	Tokens.apply_primary_button(confirm_button)
	confirm_button.pressed.connect(confirm)
	inspector.add_child(confirm_button)

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
