class_name BrainEditorBlockDrawer
extends PanelContainer

const BlockPaletteScript = preload("res://src/brain_editor/block_palette.gd")
const Tokens = preload("res://src/ui/design_tokens.gd")

signal block_requested(kind: int)
signal close_requested

var palette
var insertion_label: Label

func configure(factory) -> void:
	if palette != null:
		return
	name = "BlockDrawer"
	custom_minimum_size.x = 210.0
	position = Vector2(12, 12)
	Tokens.apply_panel(self, Color("202d33"))
	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 6)
	add_child(box)
	var header := HBoxContainer.new()
	box.add_child(header)
	var title := Label.new()
	title.text = "BLOCOS"
	title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	title.add_theme_color_override("font_color", Tokens.TEXT_MUTED)
	header.add_child(title)
	var close_button := Button.new()
	close_button.name = "CloseButton"
	close_button.text = "×"
	close_button.flat = true
	close_button.tooltip_text = "Fechar blocos"
	close_button.pressed.connect(close_requested.emit)
	header.add_child(close_button)
	insertion_label = Label.new()
	insertion_label.name = "InsertionLabel"
	insertion_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	insertion_label.add_theme_color_override("font_color", Tokens.TEXT_MUTED)
	box.add_child(insertion_label)
	show_insertion_hint()
	palette = BlockPaletteScript.new()
	palette.factory = factory
	palette.block_requested.connect(block_requested.emit)
	box.add_child(palette)

func show_insertion_target(block_label: String, port_label: String) -> void:
	insertion_label.text = "Inserir em: %s / %s" % [block_label, port_label]
	insertion_label.add_theme_color_override("font_color", Tokens.TEAL)

func show_insertion_hint() -> void:
	insertion_label.text = "Escolha uma saida vazia."
	insertion_label.add_theme_color_override("font_color", Tokens.TEXT_MUTED)

func show_insertion_error() -> void:
	insertion_label.text = "Escolha uma saida do bloco para inserir aqui."
	insertion_label.add_theme_color_override("font_color", Tokens.AMBER)
