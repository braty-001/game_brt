class_name LaboratoryExampleProvider
extends "res://src/brain_editor/editor_example_provider.gd"

enum Example {
	ROUTE,
	MELEE,
	COMBAT_ROUTE,
}

var combat_available := false

func _init(include_combat := false) -> void:
	combat_available = include_combat

func entries() -> Array[Dictionary]:
	var result: Array[Dictionary] = [{"id": Example.ROUTE, "label": "Percurso do laboratorio"}]
	if combat_available:
		result.append({"id": Example.MELEE, "label": "Combate: atacar ate derrubar"})
		result.append({"id": Example.COMBAT_ROUTE, "label": "Combate + fuga / 10 RAM"})
	return result

func default_example_id() -> int:
	return Example.COMBAT_ROUTE if combat_available else Example.ROUTE

func build_program(example_id: int = Example.ROUTE):
	if example_id == Example.MELEE and combat_available:
		return _build_melee_program()
	if example_id == Example.COMBAT_ROUTE and combat_available:
		return _build_combat_route_program()
	return _build_route_program()

func _build_route_program():
	var program := ProgramDefinition.new()
	program.start_block_id = "approach"
	_control(program, "approach", ConditionCatalog.Query.PATH_CLEAR_AHEAD)
	_action(program, "walk_in", ProgramBlockKind.Value.WALK, true)
	_control(program, "stairs", ConditionCatalog.Query.STEP_AHEAD)
	_action(program, "walk_step", ProgramBlockKind.Value.WALK)
	_action(program, "jump_step", ProgramBlockKind.Value.JUMP)
	_action(program, "turn", ProgramBlockKind.Value.TURN)
	_action(program, "run_back", ProgramBlockKind.Value.WALK, true)
	_action(program, "jump_back", ProgramBlockKind.Value.JUMP)
	_control(program, "escape", ConditionCatalog.Query.PATH_CLEAR_AHEAD)
	_action(program, "walk_out", ProgramBlockKind.Value.WALK, true)
	for edge in [
		["approach", "body", "walk_in"], ["approach", "next", "stairs"],
		["stairs", "body", "walk_step"], ["walk_step", "next", "jump_step"],
		["stairs", "next", "turn"], ["turn", "next", "run_back"],
		["run_back", "next", "jump_back"], ["jump_back", "next", "escape"],
		["escape", "body", "walk_out"],
	]:
		program.add_connection(ProgramConnection.new(edge[0], edge[1], edge[2]))
	return program

func _build_melee_program():
	var program := ProgramDefinition.new()
	program.start_block_id = "fight"
	_control(program, "fight", ConditionCatalog.Query.ENEMY_VISIBLE)
	_action(program, "approach_enemy", ProgramBlockKind.Value.WALK)
	_control(program, "enemy_in_range", ConditionCatalog.Query.ENEMY_IN_MELEE_RANGE)
	_action(program, "strike", ProgramBlockKind.Value.ATTACK)
	program.add_connection(ProgramConnection.new("fight", "body", "approach_enemy"))
	program.add_connection(ProgramConnection.new("approach_enemy", "next", "enemy_in_range"))
	program.add_connection(ProgramConnection.new("enemy_in_range", "body", "strike"))
	return program

func _build_combat_route_program():
	var program := ProgramDefinition.new()
	program.start_block_id = "approach"
	_control(program, "approach", ConditionCatalog.Query.PATH_CLEAR_AHEAD)
	_action(program, "walk_in", ProgramBlockKind.Value.WALK, true)
	_action(program, "strike", ProgramBlockKind.Value.ATTACK)
	_control(program, "stairs", ConditionCatalog.Query.STEP_AHEAD)
	_action(program, "walk_step", ProgramBlockKind.Value.WALK)
	_action(program, "jump_step", ProgramBlockKind.Value.JUMP)
	_action(program, "turn", ProgramBlockKind.Value.TURN)
	_action(program, "run_back", ProgramBlockKind.Value.WALK, true)
	_action(program, "jump_back", ProgramBlockKind.Value.JUMP)
	_control(program, "escape", ConditionCatalog.Query.PATH_CLEAR_AHEAD)
	for edge in [
		["approach", "body", "walk_in"], ["walk_in", "next", "strike"],
		["approach", "next", "stairs"], ["stairs", "body", "walk_step"],
		["walk_step", "next", "jump_step"], ["stairs", "next", "turn"],
		["turn", "next", "escape"], ["escape", "body", "run_back"],
		["run_back", "next", "jump_back"],
	]:
		program.add_connection(ProgramConnection.new(edge[0], edge[1], edge[2]))
	return program

func _control(program: ProgramDefinition, id: String, query: int) -> void:
	program.add_block(ProgramBlock.new(id, ProgramBlockKind.Value.WHILE,
		ProgramCondition.new(ConditionCatalog.Modality.VISION, query)))

func _action(program: ProgramDefinition, id: String, kind: int, fast := false) -> void:
	var parameters := {}
	if kind == ProgramBlockKind.Value.WALK:
		parameters = {MovementPace.PARAMETER_KEY: MovementPace.Value.FAST if fast else MovementPace.Value.NORMAL}
	program.add_block(ProgramBlock.new(id, kind, null, parameters))
