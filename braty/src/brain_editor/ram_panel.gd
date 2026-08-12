class_name BrainEditorRamPanel
extends RefCounted

func summary_for_program(program: ProgramDefinition) -> Dictionary:
	var used_ram := ProgramRamCalculator.used_ram(program)
	var ram_limit := ProgramRamCalculator.RAM_LIMIT
	return {
		"used": used_ram,
		"limit": ram_limit,
		"is_within_limit": used_ram <= ram_limit,
		"label": "%d/%d RAM" % [used_ram, ram_limit],
	}
