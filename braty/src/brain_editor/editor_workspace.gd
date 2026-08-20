class_name BrainEditorWorkspace
extends Control

const Tokens = preload("res://src/ui/design_tokens.gd")

var connection_graph_state
var connection_block_nodes: Dictionary = {}

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_PASS
	clip_contents = true
	queue_redraw()

func _notification(what: int) -> void:
	if what == NOTIFICATION_RESIZED:
		queue_redraw()

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
	var step := 32.0
	var x := 0.0
	while x <= size.x:
		draw_line(Vector2(x, 0), Vector2(x, size.y), grid_color, 1.0)
		x += step
	var y := 0.0
	while y <= size.y:
		draw_line(Vector2(0, y), Vector2(size.x, y), grid_color, 1.0)
		y += step
	_draw_connections()

func _draw_connections() -> void:
	if connection_graph_state == null:
		return

	if not connection_graph_state.start_block_id.is_empty() and connection_block_nodes.has(connection_graph_state.start_block_id):
		_draw_connection(Vector2(152, 51), connection_block_nodes[connection_graph_state.start_block_id].input_position(), Tokens.TEAL)

	for connection in connection_graph_state.connections:
		if not connection_block_nodes.has(connection.from_block_id) or not connection_block_nodes.has(connection.to_block_id):
			continue
		var from_node = connection_block_nodes[connection.from_block_id]
		var to_node = connection_block_nodes[connection.to_block_id]
		_draw_connection(from_node.output_position(connection.from_port), to_node.input_position(), Tokens.category_color(from_node.block_kind))

func _draw_connection(from_position: Vector2, to_position: Vector2, color: Color) -> void:
	var middle_x: float = (from_position.x + to_position.x) * 0.5
	draw_polyline(PackedVector2Array([
		from_position,
		Vector2(middle_x, from_position.y),
		Vector2(middle_x, to_position.y),
		to_position,
	]), color, 4.0, true)

	var direction := (to_position - Vector2(middle_x, to_position.y)).normalized()
	if direction == Vector2.ZERO:
		direction = Vector2.RIGHT
	var perpendicular := Vector2(-direction.y, direction.x)
	draw_colored_polygon(PackedVector2Array([
		to_position,
		to_position - direction * 13.0 + perpendicular * 6.0,
		to_position - direction * 13.0 - perpendicular * 6.0,
	]), color)
