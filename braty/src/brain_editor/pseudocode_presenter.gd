class_name BrainEditorPseudocodePresenter
extends RefCounted

const ProgramGraphBuilderScript = preload("res://src/brain_editor/program_graph_builder.gd")
const ProgramValidatorScript = preload("res://src/programming/domain/program_validator.gd")
const MovementPaceScript = preload("res://src/programming/domain/movement_pace.gd")

func present(graph_state, ram_capacity: int = ProgramRamCalculator.RAM_LIMIT) -> Dictionary:
	var program = ProgramGraphBuilderScript.new().build(graph_state)
	if not ProgramValidatorScript.validate(program, ram_capacity).is_empty():
		return {"is_valid": false, "text": "Programa incompleto. Complete condicoes e conexoes para ver o pseudocodigo."}
	var lines := PackedStringArray()
	_append_block(graph_state, graph_state.start_block_id, 0, lines)
	return {"is_valid": true, "text": "\n".join(lines)}

func _append_block(graph_state, block_id: String, depth: int, lines: PackedStringArray) -> void:
	if block_id.is_empty() or not graph_state.blocks.has(block_id):
		return
	var block = graph_state.blocks[block_id]
	var prefix := "  ".repeat(depth)
	match block.kind:
		ProgramBlockKind.Value.IF:
			lines.append("%sSE %s ENTAO" % [prefix, _condition_text(block.condition.query)])
			_append_block(graph_state, _target_for(graph_state, block_id, "true"), depth + 1, lines)
			lines.append("%sSENAO" % prefix)
			_append_block(graph_state, _target_for(graph_state, block_id, "false"), depth + 1, lines)
			lines.append("%sFIM" % prefix)
		ProgramBlockKind.Value.WHILE:
			lines.append("%sENQUANTO %s FACA" % [prefix, _condition_text(block.condition.query)])
			_append_block(graph_state, _target_for(graph_state, block_id, "body"), depth + 1, lines)
			lines.append("%sFIM" % prefix)
			_append_block(graph_state, _target_for(graph_state, block_id, "next"), depth, lines)
		_:
			lines.append("%s%s" % [prefix, _action_text(block)])
			_append_block(graph_state, _target_for(graph_state, block_id, "next"), depth, lines)

func _target_for(graph_state, block_id: String, port: String) -> String:
	for connection in graph_state.connections:
		if connection.from_block_id == block_id and connection.from_port == port:
			return connection.to_block_id
	return ""

func _action_text(block) -> String:
	match block.kind:
		ProgramBlockKind.Value.WALK:
			return "ANDAR %s" % MovementPaceScript.label(
				MovementPaceScript.from_parameters(block.parameters)
			).to_upper()
		ProgramBlockKind.Value.JUMP: return "PULAR"
		ProgramBlockKind.Value.TURN: return "VIRAR"
		ProgramBlockKind.Value.ATTACK: return "ATACAR"
		_: return "ACAO"

func _condition_text(query: int) -> String:
	match query:
		ConditionCatalog.Query.PATH_CLEAR_AHEAD: return "CAMINHO LIVRE A FRENTE"
		ConditionCatalog.Query.GAP_AHEAD: return "BURACO A FRENTE"
		ConditionCatalog.Query.GOAL_VISIBLE: return "OBJETIVO VISIVEL"
		ConditionCatalog.Query.STEP_AHEAD: return "DEGRAU A FRENTE"
		ConditionCatalog.Query.SIGNAL_HEARD: return "SINAL OUVIDO"
		ConditionCatalog.Query.ENEMY_VISIBLE: return "INIMIGO VISIVEL"
		ConditionCatalog.Query.ENEMY_IN_MELEE_RANGE: return "INIMIGO AO ALCANCE"
		_: return "CONDICAO"
