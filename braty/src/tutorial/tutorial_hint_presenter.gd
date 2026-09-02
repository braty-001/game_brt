class_name TutorialHintPresenter
extends RefCounted

const MissionResultScript = preload("res://src/tutorial/mission_result.gd")
const MissionStateScript = preload("res://src/tutorial/mission_state.gd")

func hint_for(state: int, result_kind: int = MissionResultScript.Kind.NONE, program_block_count: int = 0) -> String:
	match state:
		MissionStateScript.Value.ASSEMBLY:
			return "Instale as pecas base para liberar o cerebro."
		MissionStateScript.Value.EDITING:
			if program_block_count <= 0:
				return "Comece com Andar, Pular e um sensor visual de buraco."
			return "Use IF ou WHILE com Visao: buraco a frente para decidir quando pular."
		MissionStateScript.Value.RUNNING:
			return "O Buneko executa o cerebro sozinho. Observe sensores e acoes."
		MissionStateScript.Value.FAILED:
			if result_kind == MissionResultScript.Kind.FAILED_BY_FALL:
				return "Ajuste o sensor visual do buraco e tente pular antes da borda."
			if result_kind == MissionResultScript.Kind.FAILED_BY_EXECUTION_LIMIT:
				return "Revise repeticoes que nao chegam a uma acao de movimento."
			if result_kind == MissionResultScript.Kind.FAILED_BEFORE_OBJECTIVE:
				return "O programa precisa manter o Buneko em movimento ate alcancar o objetivo."
			return "Revise o programa e tente novamente."
		MissionStateScript.Value.COMPLETED:
			return "Objetivo concluido."

	return ""
