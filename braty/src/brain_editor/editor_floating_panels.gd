class_name EditorFloatingPanels
extends Control

var _drawer: Control
var _code: Control
var _workspace: Control

func configure(drawer: Control, code: Control, workspace: Control) -> void:
	_drawer = drawer
	_code = code
	_workspace = workspace
	drawer.reparent($DrawerScroll, false)
	code.reparent($CodeScroll, false)
	drawer.visibility_changed.connect(_refresh)
	code.visibility_changed.connect(_refresh)
	drawer.minimum_size_changed.connect(_refresh_deferred)
	code.minimum_size_changed.connect(_refresh_deferred)
	get_viewport().size_changed.connect(_refresh_deferred)
	resized.connect(_refresh_deferred)
	_refresh()

func _refresh_deferred() -> void:
	call_deferred("_refresh")

func _refresh() -> void:
	if _drawer == null:
		return
	_fit(_drawer, $DrawerScroll, 250.0)
	_fit(_code, $CodeScroll, 420.0)

func _fit(panel: Control, scroll: ScrollContainer, preferred_width: float) -> void:
	scroll.visible = panel.visible
	if not panel.visible:
		return
	var bounds := get_viewport_rect().grow(-16)
	var minimum := panel.get_combined_minimum_size()
	var popup_size := Vector2(
		minf(maxf(preferred_width, minimum.x + 16), bounds.size.x),
		minf(maxf(minimum.y, 250), bounds.size.y)
	)
	scroll.size = popup_size
	var desired := _workspace.global_position + Vector2(12, 12)
	scroll.global_position = Vector2(
		clampf(desired.x, bounds.position.x, bounds.end.x - popup_size.x),
		clampf(desired.y, bounds.position.y, bounds.end.y - popup_size.y)
	)
