class_name ProgramRamCalculator
extends RefCounted

const RAM_LIMIT := 5

static func used_ram(program: ProgramDefinition) -> int:
	return program.reachable_block_ids().size()

static func is_within_limit(program: ProgramDefinition) -> bool:
	return used_ram(program) <= RAM_LIMIT
