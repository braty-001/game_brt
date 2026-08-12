class_name ProgramGraphBuilder
extends RefCounted

func build(graph_state) -> ProgramDefinition:
	var program := ProgramDefinition.new()
	if graph_state == null:
		return program

	program.start_block_id = graph_state.start_block_id
	for block_id in graph_state.blocks:
		var block = graph_state.blocks[block_id]
		program.add_block(block.to_program_block())

	for editor_connection in graph_state.connections:
		program.add_connection(editor_connection.to_program_connection())

	return program
