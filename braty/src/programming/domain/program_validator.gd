class_name ProgramValidator
extends RefCounted

static func validate(program: ProgramDefinition) -> Array[ProgramValidationError]:
	var errors: Array[ProgramValidationError] = []
	_validate_start(program, errors)
	_validate_blocks(program, errors)
	_validate_connections(program, errors)
	_validate_cycles(program, errors)
	_validate_ram(program, errors)
	return errors

static func _validate_start(
	program: ProgramDefinition,
	errors: Array[ProgramValidationError]
) -> void:
	if program.start_block_id.is_empty():
		errors.append(ProgramValidationError.new(ProgramValidationError.Code.MISSING_START))
	elif not program.blocks.has(program.start_block_id):
		errors.append(
			ProgramValidationError.new(
				ProgramValidationError.Code.UNKNOWN_START,
				program.start_block_id
			)
		)

static func _validate_blocks(
	program: ProgramDefinition,
	errors: Array[ProgramValidationError]
) -> void:
	for block_id in program.blocks:
		var block: ProgramBlock = program.blocks[block_id]
		if not block.is_valid():
			errors.append(
				ProgramValidationError.new(ProgramValidationError.Code.INVALID_BLOCK, block_id)
			)

static func _validate_connections(
	program: ProgramDefinition,
	errors: Array[ProgramValidationError]
) -> void:
	var output_slots: Dictionary = {}
	var input_slots: Dictionary = {}

	for connection in program.connections:
		if not program.blocks.has(connection.from_block_id) or not program.blocks.has(connection.to_block_id):
			errors.append(
				ProgramValidationError.new(
					ProgramValidationError.Code.UNKNOWN_CONNECTION_BLOCK,
					connection.from_block_id
				)
			)
			continue

		var source_block: ProgramBlock = program.blocks[connection.from_block_id]
		if not ProgramBlockKind.output_ports(source_block.kind).has(connection.from_port):
			errors.append(
				ProgramValidationError.new(
					ProgramValidationError.Code.INVALID_OUTPUT_PORT,
					connection.from_block_id
				)
			)

		if connection.to_port != "input":
			errors.append(
				ProgramValidationError.new(
					ProgramValidationError.Code.INVALID_INPUT_PORT,
					connection.to_block_id
				)
			)

		var output_key := "%s:%s" % [connection.from_block_id, connection.from_port]
		if output_slots.has(output_key):
			errors.append(
				ProgramValidationError.new(
					ProgramValidationError.Code.DUPLICATE_OUTPUT,
					connection.from_block_id
				)
			)
		else:
			output_slots[output_key] = true

		if input_slots.has(connection.to_block_id):
			errors.append(
				ProgramValidationError.new(
					ProgramValidationError.Code.DUPLICATE_INPUT,
					connection.to_block_id
				)
			)
		else:
			input_slots[connection.to_block_id] = true

static func _validate_cycles(
	program: ProgramDefinition,
	errors: Array[ProgramValidationError]
) -> void:
	var visited: Dictionary = {}
	var active: Dictionary = {}
	for block_id in program.blocks:
		if _has_cycle_from(program, block_id, visited, active):
			errors.append(
				ProgramValidationError.new(ProgramValidationError.Code.ARBITRARY_CYCLE, block_id)
			)
			return

static func _has_cycle_from(
	program: ProgramDefinition,
	block_id: String,
	visited: Dictionary,
	active: Dictionary
) -> bool:
	if active.has(block_id):
		return true
	if visited.has(block_id):
		return false

	visited[block_id] = true
	active[block_id] = true
	for connection in program.connections:
		if connection.from_block_id == block_id and program.blocks.has(connection.to_block_id):
			if _has_cycle_from(program, connection.to_block_id, visited, active):
				return true
	active.erase(block_id)
	return false

static func _validate_ram(
	program: ProgramDefinition,
	errors: Array[ProgramValidationError]
) -> void:
	if not ProgramRamCalculator.is_within_limit(program):
		errors.append(ProgramValidationError.new(ProgramValidationError.Code.RAM_LIMIT_EXCEEDED))
