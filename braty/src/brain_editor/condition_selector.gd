class_name BrainEditorConditionSelector
extends RefCounted

const ProgramConditionScript = preload("res://src/programming/domain/program_condition.gd")

func available_options() -> Array:
	return [
		{
			"label": "Visao: caminho livre a frente",
			"modality": ConditionCatalog.Modality.VISION,
			"query": ConditionCatalog.Query.PATH_CLEAR_AHEAD,
		},
		{
			"label": "Visao: buraco a frente",
			"modality": ConditionCatalog.Modality.VISION,
			"query": ConditionCatalog.Query.GAP_AHEAD,
		},
		{
			"label": "Visao: objetivo visivel",
			"modality": ConditionCatalog.Modality.VISION,
			"query": ConditionCatalog.Query.GOAL_VISIBLE,
		},
		{
			"label": "Audicao: sinal ouvido",
			"modality": ConditionCatalog.Modality.HEARING,
			"query": ConditionCatalog.Query.SIGNAL_HEARD,
		},
	]

func create_condition(modality: int, query: int):
	var condition = ProgramConditionScript.new(modality, query)
	if not condition.is_valid():
		return null

	return condition

func apply_condition(graph_state, block_id: String, modality: int, query: int) -> bool:
	if graph_state == null:
		return false

	var condition = create_condition(modality, query)
	if condition == null:
		return false

	return graph_state.set_block_condition(block_id, condition)
