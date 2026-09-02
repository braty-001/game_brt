class_name EditorGraphState
extends RefCounted

enum Change {
	BLOCK_ADDED,
	BLOCK_REMOVED,
	BLOCK_MOVED,
	CONNECTION_ADDED,
	CONNECTION_REMOVED,
	CONDITION_CHANGED,
	PARAMETER_CHANGED,
	START_CHANGED,
}

signal changed(change: int, affected_block_ids: PackedStringArray)

var start_block_id: String
var blocks: Dictionary = {}
var connections: Array = []

func add_block(block) -> bool:
	if block == null or block.id.is_empty() or blocks.has(block.id):
		return false

	blocks[block.id] = block
	changed.emit(Change.BLOCK_ADDED, PackedStringArray([block.id]))
	return true

func remove_block(block_id: String) -> bool:
	if not blocks.has(block_id):
		return false

	var affected_block_ids := PackedStringArray([block_id])
	blocks.erase(block_id)
	if start_block_id == block_id:
		start_block_id = ""

	for index in range(connections.size() - 1, -1, -1):
		var connection = connections[index]
		if connection.from_block_id == block_id or connection.to_block_id == block_id:
			affected_block_ids.append(connection.from_block_id)
			affected_block_ids.append(connection.to_block_id)
			connections.remove_at(index)

	changed.emit(Change.BLOCK_REMOVED, affected_block_ids)
	return true

func move_block(block_id: String, new_position: Vector2) -> bool:
	if not blocks.has(block_id):
		return false

	var block = blocks[block_id]
	block.position = new_position
	changed.emit(Change.BLOCK_MOVED, PackedStringArray([block_id]))
	return true

func set_block_condition(block_id: String, condition: ProgramCondition) -> bool:
	if not blocks.has(block_id):
		return false

	var block = blocks[block_id]
	block.condition = condition
	changed.emit(Change.CONDITION_CHANGED, PackedStringArray([block_id]))
	return true

func set_block_parameter(block_id: String, key: String, value) -> bool:
	if not blocks.has(block_id) or key.is_empty():
		return false

	blocks[block_id].parameters[key] = value
	changed.emit(Change.PARAMETER_CHANGED, PackedStringArray([block_id]))
	return true

func set_start_block(block_id: String) -> bool:
	if not block_id.is_empty() and not blocks.has(block_id):
		return false
	if start_block_id == block_id:
		return true

	start_block_id = block_id
	changed.emit(Change.START_CHANGED, PackedStringArray([block_id]))
	return true

func add_connection(connection) -> bool:
	if connection == null:
		return false

	if not blocks.has(connection.from_block_id) or not blocks.has(connection.to_block_id):
		return false

	connections.append(connection)
	changed.emit(Change.CONNECTION_ADDED, PackedStringArray([connection.from_block_id, connection.to_block_id]))
	return true

func remove_connection(from_block_id: String, from_port: String) -> int:
	var removed_count := 0
	for index in range(connections.size() - 1, -1, -1):
		var connection = connections[index]
		if connection.from_block_id == from_block_id and connection.from_port == from_port:
			connections.remove_at(index)
			removed_count += 1

	if removed_count > 0:
		changed.emit(Change.CONNECTION_REMOVED, PackedStringArray([from_block_id]))
	return removed_count
