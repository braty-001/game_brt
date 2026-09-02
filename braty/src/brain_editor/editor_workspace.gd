class_name BrainEditorWorkspace
extends Control

const Tokens = preload("res://src/ui/design_tokens.gd")
const ViewportControllerScript = preload("res://src/brain_editor/editor_viewport_controller.gd")

var connection_graph_state
var connection_block_nodes: Dictionary = {}
var viewport_controller = ViewportControllerScript.new()
var canvas: Control
var navigation_enabled := false
var _panning := false

signal viewport_changed(zoom_label: String)

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_PASS
	clip_contents = true
	_ensure_canvas()
	queue_redraw()

func _notification(what: int) -> void:
	if what == NOTIFICATION_RESIZED:
		if canvas != null:
			canvas.size = size
		queue_redraw()

func add_block_node(block_node: Control) -> void:
	_ensure_canvas()
	canvas.add_child(block_node)

func zoom_in() -> void:
	if viewport_controller.zoom_in():
		_apply_viewport()

func zoom_out() -> void:
	if viewport_controller.zoom_out():
		_apply_viewport()

func center_viewport() -> void:
	if viewport_controller.center():
		_apply_viewport()

func set_navigation_enabled(enabled: bool) -> void:
	navigation_enabled = enabled

func viewport_label() -> String:
	return viewport_controller.zoom_label()

func graph_to_viewport(world_position: Vector2) -> Vector2:
	return viewport_controller.world_to_viewport(world_position)

func viewport_to_graph(viewport_position: Vector2) -> Vector2:
	return viewport_controller.viewport_to_world(viewport_position)

func connection_stroke_width() -> float:
	return 4.0 * viewport_controller.zoom

func connection_arrow_length() -> float:
	return 13.0 * viewport_controller.zoom

func configure_connections(graph_state, block_nodes: Dictionary) -> void:
	connection_graph_state = graph_state
	connection_block_nodes = block_nodes
	queue_redraw()

func visible_connection_count() -> int:
	if connection_graph_state == null:
		return 0

	var count := 0
	if not connection_graph_state.start_block_id.is_empty() and connection_block_nodes.has(connection_graph_state.start_block_id):
		count += 1
	for connection in connection_graph_state.connections:
		if connection_block_nodes.has(connection.from_block_id) and connection_block_nodes.has(connection.to_block_id):
			count += 1
	return count

func _draw() -> void:
	draw_rect(Rect2(Vector2.ZERO, size), Color("1b252a"))
	var grid_color := Color(Tokens.BORDER, 0.22)
	var step: float = 32.0 * viewport_controller.zoom
	var x: float = fposmod(viewport_controller.pan.x, step) - step
	while x <= size.x:
		draw_line(Vector2(x, 0), Vector2(x, size.y), grid_color, 1.0)
		x += step
	var y: float = fposmod(viewport_controller.pan.y, step) - step
	while y <= size.y:
		draw_line(Vector2(0, y), Vector2(size.x, y), grid_color, 1.0)
		y += step
	_draw_connections()

func _draw_connections() -> void:
	if connection_graph_state == null:
		return

	if not connection_graph_state.start_block_id.is_empty() and connection_block_nodes.has(connection_graph_state.start_block_id):
		_draw_connection(Vector2(152, 51), _to_viewport(connection_block_nodes[connection_graph_state.start_block_id].input_position()), Tokens.TEAL)

	for connection in connection_graph_state.connections:
		if not connection_block_nodes.has(connection.from_block_id) or not connection_block_nodes.has(connection.to_block_id):
			continue
		var from_node = connection_block_nodes[connection.from_block_id]
		var to_node = connection_block_nodes[connection.to_block_id]
		_draw_connection(_to_viewport(from_node.output_position(connection.from_port)), _to_viewport(to_node.input_position()), Tokens.category_color(from_node.block_kind))

func _gui_input(event: InputEvent) -> void:
	if not navigation_enabled:
		return
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		_panning = event.pressed
		accept_event()
	elif event is InputEventMouseMotion and _panning:
		if viewport_controller.pan_by(event.relative):
			_apply_viewport()
		accept_event()

func _ensure_canvas() -> void:
	if canvas != null:
		return
	canvas = Control.new()
	canvas.name = "GraphCanvas"
	canvas.mouse_filter = Control.MOUSE_FILTER_PASS
	canvas.size = size
	add_child(canvas)

func _apply_viewport() -> void:
	_ensure_canvas()
	canvas.position = viewport_controller.pan
	canvas.scale = Vector2.ONE * viewport_controller.zoom
	queue_redraw()
	viewport_changed.emit(viewport_controller.zoom_label())

func _to_viewport(world_position: Vector2) -> Vector2:
	return graph_to_viewport(world_position)

func _draw_connection(from_position: Vector2, to_position: Vector2, color: Color) -> void:
	var middle_x: float = (from_position.x + to_position.x) * 0.5
	draw_polyline(PackedVector2Array([
		from_position,
		Vector2(middle_x, from_position.y),
		Vector2(middle_x, to_position.y),
		to_position,
	]), color, connection_stroke_width(), true)

	var direction := (to_position - Vector2(middle_x, to_position.y)).normalized()
	if direction == Vector2.ZERO:
		direction = Vector2.RIGHT
	var perpendicular := Vector2(-direction.y, direction.x)
	draw_colored_polygon(PackedVector2Array([
		to_position,
		to_position - direction * connection_arrow_length() + perpendicular * connection_arrow_length() * 0.46,
		to_position - direction * connection_arrow_length() - perpendicular * connection_arrow_length() * 0.46,
	]), color)
