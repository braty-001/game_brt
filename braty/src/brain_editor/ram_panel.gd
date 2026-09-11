class_name BrainEditorRamPanel
extends RefCounted

func summary_for_program(program: ProgramDefinition, ram_capacity: int = ProgramRamCalculator.RAM_LIMIT) -> Dictionary:
	var used_ram := ProgramRamCalculator.used_ram(program)
	var ram_limit := ram_capacity
	return {
		"used": used_ram,
		"limit": ram_limit,
		"is_within_limit": ProgramRamCalculator.is_within_limit(program, ram_capacity),
		"label": "%d/%d RAM" % [used_ram, ram_limit],
	}
