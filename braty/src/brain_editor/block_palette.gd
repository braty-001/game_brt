class_name BrainEditorBlockPalette
extends VBoxContainer

const BlockFactoryScript = preload("res://src/brain_editor/block_factory.gd")
const PaletteItemScript = preload("res://src/brain_editor/block_palette_item.gd")
const Tokens = preload("res://src/ui/design_tokens.gd")

signal block_requested(kind: int)

var factory
var item_buttons: Array[Button] = []

func _ready() -> void:
	if factory == null:
		factory = BlockFactoryScript.new()
	if get_child_count() == 0:
		populate()

func populate() -> void:
	for child in get_children():
		child.queue_free()
	item_buttons.clear()

	_add_heading("ACOES", Tokens.ACTION)
	_add_item(ProgramBlockKind.Value.WALK)
	_add_item(ProgramBlockKind.Value.RUN)
	_add_item(ProgramBlockKind.Value.JUMP)
	_add_item(ProgramBlockKind.Value.TURN)
	_add_heading("CONTROLE", Tokens.CONTROL)
	_add_item(ProgramBlockKind.Value.IF)
	_add_item(ProgramBlockKind.Value.WHILE)

func item_for_kind(kind: int) -> Button:
	for item in item_buttons:
		if item.block_kind == kind:
			return item
	return null

func _add_heading(title: String, color: Color) -> void:
	var label := Label.new()
	label.text = title
	label.add_theme_color_override("font_color", color)
	label.add_theme_font_size_override("font_size", 13)
	label.custom_minimum_size.y = 26.0
	add_child(label)

func _add_item(kind: int) -> void:
	var item = PaletteItemScript.new()
	item.configure(kind, factory.label_for_kind(kind))
	item.pressed.connect(_on_item_pressed.bind(kind))
	add_child(item)
	item_buttons.append(item)

func _on_item_pressed(kind: int) -> void:
	block_requested.emit(kind)
