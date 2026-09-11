class_name ProgramRamCalculator
extends RefCounted

const RAM_LIMIT := 5

static func used_ram(program: ProgramDefinition) -> int:
	return program.reachable_block_ids().size()

static func is_within_limit(program: ProgramDefinition, ram_capacity: int = RAM_LIMIT) -> bool:
	return ram_capacity > 0 and used_ram(program) <= ram_capacity
