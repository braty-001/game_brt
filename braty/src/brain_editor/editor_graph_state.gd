class_name EditorGraphState
extends RefCounted

var start_block_id: String
var blocks: Dictionary = {}
var connections: Array = []

func add_block(block) -> bool:
	if block == null or block.id.is_empty() or blocks.has(block.id):
		return false

	blocks[block.id] = block
	return true

func remove_block(block_id: String) -> bool:
	if not blocks.has(block_id):
		return false

	blocks.erase(block_id)
	if start_block_id == block_id:
		start_block_id = ""

	for index in range(connections.size() - 1, -1, -1):
		var connection = connections[index]
		if connection.from_block_id == block_id or connection.to_block_id == block_id:
			connections.remove_at(index)

	return true

func move_block(block_id: String, new_position: Vector2) -> bool:
	if not blocks.has(block_id):
		return false

	var block = blocks[block_id]
	block.position = new_position
	return true

func set_block_condition(block_id: String, condition: ProgramCondition) -> bool:
	if not blocks.has(block_id):
		return false

	var block = blocks[block_id]
	block.condition = condition
	return true

func add_connection(connection) -> bool:
	if connection == null:
		return false

	if not blocks.has(connection.from_block_id) or not blocks.has(connection.to_block_id):
		return false

	connections.append(connection)
	return true

func remove_connection(from_block_id: String, from_port: String) -> int:
	var removed_count := 0
	for index in range(connections.size() - 1, -1, -1):
		var connection = connections[index]
		if connection.from_block_id == from_block_id and connection.from_port == from_port:
			connections.remove_at(index)
			removed_count += 1

	return removed_count
