class_name BrainEditorView
extends RefCounted

const Tokens = preload("res://src/ui/design_tokens.gd")

var editor_header
var palette
var block_drawer
var pseudocode_panel
var canvas_toolbar: PanelContainer
var canvas_primary_tools: HBoxContainer
var canvas_navigation_tools: HBoxContainer
var workspace: Control
var inspector_panel: PanelContainer
var ram_label: Label
var validation_label: Label
var state_label: Label
var connection_feedback_label: Label
var parameter_panel
var start_button: Button
var pause_button: Button
var resume_button: Button
var stop_button: Button
var restart_button: Button
var organize_button: Button
var pan_button: Button
var zoom_out_button: Button
var zoom_label_button: Button
var zoom_in_button: Button
var center_view_button: Button
var drawer_button: Button
var pseudocode_button: Button
var back_button: Button
var example_selector: OptionButton
var example_button: Button
var reset_brain_button: Button

func bind(root: Control, block_factory, example_entries: Array[Dictionary] = []) -> void:
	editor_header = root.get_node("Margin/Page/EditorHeader")
	canvas_toolbar = root.get_node("Margin/Page/Body/Center/CanvasToolbar")
	canvas_primary_tools = root.get_node("Margin/Page/Body/Center/CanvasToolbar/CanvasToolbarRow/PrimaryTools")
	canvas_navigation_tools = root.get_node("Margin/Page/Body/Center/CanvasToolbar/CanvasToolbarRow/NavigationTools")
	workspace = root.get_node("Margin/Page/Body/Center/WorkspacePanel/Workspace")
	block_drawer = workspace.get_node("BlockDrawer")
	block_drawer.configure(block_factory)
	palette = block_drawer.palette
	pseudocode_panel = workspace.get_node("PseudocodePanel")
	inspector_panel = root.get_node("Margin/Page/Body/InspectorPanel")
	parameter_panel = inspector_panel.get_node("Inspector/DetailsScroll/Details/ParameterPanel")
	connection_feedback_label = inspector_panel.get_node("Inspector/DetailsScroll/Details/ConnectionFeedback")
	ram_label = inspector_panel.get_node("Inspector/RamLabel")
	state_label = inspector_panel.get_node("Inspector/StateLabel")
	example_selector = inspector_panel.get_node("Inspector/ExampleSelector")
	example_button = inspector_panel.get_node("Inspector/ExampleButton")
	reset_brain_button = inspector_panel.get_node("Inspector/ResetBrainButton")
	back_button = inspector_panel.get_node("Inspector/BackButton")
	validation_label = root.get_node("Margin/Page/Body/Center/RuntimeToolbarPanel/RuntimeToolbar/ValidationLabel")
	start_button = root.get_node("Margin/Page/Body/Center/RuntimeToolbarPanel/RuntimeToolbar/StartButton")
	pause_button = root.get_node("Margin/Page/Body/Center/RuntimeToolbarPanel/RuntimeToolbar/PauseButton")
	resume_button = root.get_node("Margin/Page/Body/Center/RuntimeToolbarPanel/RuntimeToolbar/ResumeButton")
	stop_button = root.get_node("Margin/Page/Body/Center/RuntimeToolbarPanel/RuntimeToolbar/StopButton")
	restart_button = root.get_node("Margin/Page/Body/Center/RuntimeToolbarPanel/RuntimeToolbar/RestartButton")
	drawer_button = canvas_primary_tools.get_node("DrawerButton")
	organize_button = canvas_primary_tools.get_node("OrganizeButton")
	pseudocode_button = canvas_primary_tools.get_node("PseudocodeButton")
	pan_button = canvas_navigation_tools.get_node("PanButton")
	zoom_out_button = canvas_navigation_tools.get_node("ZoomOutButton")
	zoom_label_button = canvas_navigation_tools.get_node("ZoomLabelButton")
	zoom_in_button = canvas_navigation_tools.get_node("ZoomInButton")
	center_view_button = canvas_navigation_tools.get_node("CenterViewButton")

	_configure_examples(example_entries)
	_apply_styles(root)
	_configure_tooltips()
	editor_header.configure("ETAPA 2/3  PROGRAMACAO", "Atravesse o buraco e alcance o objetivo", "Editando", "0/5 RAM")

func _configure_examples(example_entries: Array[Dictionary]) -> void:
	example_selector.clear()
	for entry in example_entries:
		example_selector.add_item(str(entry.get("label", "Exemplo")))
		example_selector.set_item_metadata(example_selector.item_count - 1, int(entry.get("id", -1)))
	if example_selector.item_count > 0:
		example_selector.select(example_selector.item_count - 1)
	example_selector.visible = not example_entries.is_empty()
	example_button.visible = not example_entries.is_empty()

func _apply_styles(root: Control) -> void:
	root.get_node("Background").color = Tokens.BACKGROUND
	Tokens.apply_panel(canvas_toolbar, Color("202d33"))
	Tokens.apply_panel(root.get_node("Margin/Page/Body/Center/WorkspacePanel"), Color("1b252a"))
	Tokens.apply_panel(root.get_node("Margin/Page/Body/Center/RuntimeToolbarPanel"))
	Tokens.apply_panel(inspector_panel)
	workspace.get_node("StartMarker").add_theme_stylebox_override("panel", Tokens.panel_style(Color("173b3c"), 6, Tokens.TEAL))
	root.get_node("Margin/Page/Body/InspectorPanel/Inspector/DetailsScroll/Details/InspectorTitle").add_theme_color_override("font_color", Tokens.TEXT_MUTED)
	connection_feedback_label.add_theme_color_override("font_color", Tokens.TEXT_MUTED)
	for button in [drawer_button, organize_button, pseudocode_button, pan_button, zoom_out_button, zoom_label_button, zoom_in_button, center_view_button, pause_button, stop_button, example_button, reset_brain_button, back_button]:
		Tokens.apply_secondary_button(button)
	for button in [start_button, resume_button, restart_button]:
		Tokens.apply_primary_button(button)

func _configure_tooltips() -> void:
	organize_button.tooltip_text = "Organizar blocos"
	drawer_button.tooltip_text = "Abrir blocos"
	pseudocode_button.tooltip_text = "Ver pseudocodigo"
	pan_button.tooltip_text = "Mover canvas"
	zoom_out_button.tooltip_text = "Diminuir zoom"
	zoom_in_button.tooltip_text = "Aumentar zoom"
	center_view_button.tooltip_text = "Centralizar canvas"
