class_name BrainEditorWorkspaceInputController
extends RefCounted

func move_block(graph_state, block_nodes: Dictionary, block_id: String, new_position: Vector2) -> bool:
	if graph_state == null or not graph_state.move_block(block_id, new_position):
		return false

	if block_nodes.has(block_id):
		block_nodes[block_id].move_to(new_position)

	return true

func remove_block(graph_state, block_nodes: Dictionary, workspace: Node, block_id: String) -> bool:
	if graph_state == null or not graph_state.remove_block(block_id):
		return false

	if block_nodes.has(block_id):
		var node = block_nodes[block_id]
		block_nodes.erase(block_id)
		if is_instance_valid(node):
			workspace.remove_child(node)
			node.free()

	return true
