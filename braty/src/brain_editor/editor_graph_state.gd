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
	BATCH_CHANGED,
}

signal changed(change: int, affected_block_ids: PackedStringArray)

var start_block_id: String
var blocks: Dictionary = {}
var connections: Array = []
var _is_batching := false
var _batched_block_ids := PackedStringArray()

func begin_batch() -> bool:
	if _is_batching:
		return false
	_is_batching = true
	_batched_block_ids.clear()
	return true

func commit_batch() -> bool:
	if not _is_batching:
		return false
	_is_batching = false
	var affected_block_ids := _batched_block_ids.duplicate()
	_batched_block_ids.clear()
	changed.emit(Change.BATCH_CHANGED, affected_block_ids)
	return true

func discard_batch() -> bool:
	if not _is_batching:
		return false
	_is_batching = false
	_batched_block_ids.clear()
	return true

func add_block(block) -> bool:
	if block == null or block.id.is_empty() or blocks.has(block.id):
		return false

	blocks[block.id] = block
	_publish_change(Change.BLOCK_ADDED, PackedStringArray([block.id]))
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

	_publish_change(Change.BLOCK_REMOVED, affected_block_ids)
	return true

func move_block(block_id: String, new_position: Vector2) -> bool:
	if not blocks.has(block_id):
		return false

	var block = blocks[block_id]
	block.position = new_position
	_publish_change(Change.BLOCK_MOVED, PackedStringArray([block_id]))
	return true

func set_block_condition(block_id: String, condition: ProgramCondition) -> bool:
	if not blocks.has(block_id):
		return false

	var block = blocks[block_id]
	block.condition = condition
	_publish_change(Change.CONDITION_CHANGED, PackedStringArray([block_id]))
	return true

func set_block_parameter(block_id: String, key: String, value) -> bool:
	if not blocks.has(block_id) or key.is_empty():
		return false

	blocks[block_id].parameters[key] = value
	_publish_change(Change.PARAMETER_CHANGED, PackedStringArray([block_id]))
	return true

func set_start_block(block_id: String) -> bool:
	if not block_id.is_empty() and not blocks.has(block_id):
		return false
	if start_block_id == block_id:
		return true

	start_block_id = block_id
	_publish_change(Change.START_CHANGED, PackedStringArray([block_id]))
	return true

func add_connection(connection) -> bool:
	if connection == null:
		return false

	if not blocks.has(connection.from_block_id) or not blocks.has(connection.to_block_id):
		return false

	connections.append(connection)
	_publish_change(Change.CONNECTION_ADDED, PackedStringArray([connection.from_block_id, connection.to_block_id]))
	return true

func remove_connection(from_block_id: String, from_port: String) -> int:
	var removed_count := 0
	for index in range(connections.size() - 1, -1, -1):
		var connection = connections[index]
		if connection.from_block_id == from_block_id and connection.from_port == from_port:
			connections.remove_at(index)
			removed_count += 1

	if removed_count > 0:
		_publish_change(Change.CONNECTION_REMOVED, PackedStringArray([from_block_id]))
	return removed_count

func _publish_change(change: int, affected_block_ids: PackedStringArray) -> void:
	if not _is_batching:
		changed.emit(change, affected_block_ids)
		return

	for block_id in affected_block_ids:
		if not _batched_block_ids.has(block_id):
			_batched_block_ids.append(block_id)
