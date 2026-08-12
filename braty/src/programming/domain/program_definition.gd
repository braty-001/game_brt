class_name ProgramDefinition
extends RefCounted

var start_block_id: String
var blocks: Dictionary = {}
var connections: Array[ProgramConnection] = []

func add_block(block: ProgramBlock) -> bool:
	if block == null or blocks.has(block.id):
		return false

	blocks[block.id] = block
	return true

func add_connection(connection: ProgramConnection) -> void:
	connections.append(connection)

func reachable_block_ids() -> Dictionary:
	var reachable: Dictionary = {}
	if start_block_id.is_empty() or not blocks.has(start_block_id):
		return reachable

	var pending: Array[String] = [start_block_id]
	while not pending.is_empty():
		var current_id: String = pending.pop_back()
		if reachable.has(current_id):
			continue

		reachable[current_id] = true
		for connection in connections:
			if connection.from_block_id == current_id and blocks.has(connection.to_block_id):
				pending.append(connection.to_block_id)

	return reachable
