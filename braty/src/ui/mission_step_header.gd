class_name MissionStepHeader
extends PanelContainer

const Tokens = preload("res://src/ui/design_tokens.gd")

var step_label: Label
var objective_label: Label
var status_label: Label
var ram_label: Label

func _ready() -> void:
	_build_ui()

func configure(step: String, objective: String, status: String = "", ram: String = "") -> void:
	_build_ui()
	step_label.text = step
	objective_label.text = objective
	status_label.text = status
	ram_label.text = ram
	status_label.visible = not status.is_empty()
	ram_label.visible = not ram.is_empty()

func set_step(value: String) -> void:
	_build_ui()
	step_label.text = value

func set_status(value: String) -> void:
	_build_ui()
	status_label.text = value
	status_label.visible = not value.is_empty()

func set_ram(value: String) -> void:
	_build_ui()
	ram_label.text = value
	ram_label.visible = not value.is_empty()

func _build_ui() -> void:
	if step_label != null:
		return

	Tokens.apply_panel(self, Tokens.SURFACE)
	custom_minimum_size.y = 66.0

	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 18)
	add_child(row)

	step_label = Label.new()
	step_label.name = "StepLabel"
	step_label.add_theme_color_override("font_color", Tokens.TEAL)
	step_label.add_theme_font_size_override("font_size", 18)
	row.add_child(step_label)

	objective_label = Label.new()
	objective_label.name = "ObjectiveLabel"
	objective_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	objective_label.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	row.add_child(objective_label)

	status_label = Label.new()
	status_label.name = "StatusLabel"
	status_label.add_theme_color_override("font_color", Tokens.TEXT_MUTED)
	row.add_child(status_label)

	ram_label = Label.new()
	ram_label.name = "RamLabel"
	ram_label.add_theme_color_override("font_color", Tokens.AMBER)
	ram_label.add_theme_font_size_override("font_size", 18)
	row.add_child(ram_label)
