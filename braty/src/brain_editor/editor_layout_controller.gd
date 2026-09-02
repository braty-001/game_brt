class_name BrainEditorLayoutController
extends RefCounted

const ORIGIN := Vector2(205, 105)
const FLOW_OFFSET := Vector2(205, 0)
const BODY_OFFSET := Vector2(135, 115)
const TRUE_OFFSET := Vector2(205, -80)
const FALSE_OFFSET := Vector2(205, 105)

func positions_for(graph_state) -> Dictionary:
	var positions: Dictionary = {}
	if graph_state == null or graph_state.start_block_id.is_empty() or not graph_state.blocks.has(graph_state.start_block_id):
		return positions

	var queue: Array[Dictionary] = [{"id": graph_state.start_block_id, "position": ORIGIN}]
	while not queue.is_empty():
		var current: Dictionary = queue.pop_front()
		var block_id: String = current["id"]
		if positions.has(block_id) or not graph_state.blocks.has(block_id):
			continue

		var position: Vector2 = current["position"]
		positions[block_id] = position
		for connection in graph_state.connections:
			if connection.from_block_id != block_id:
				continue
			queue.append({
				"id": connection.to_block_id,
				"position": position + _offset_for_port(connection.from_port),
			})

	return positions

func _offset_for_port(port: String) -> Vector2:
	match port:
		"body":
			return BODY_OFFSET
		"true":
			return TRUE_OFFSET
		"false":
			return FALSE_OFFSET
		_:
			return FLOW_OFFSET
