class_name BrainEditorConditionSelector
extends RefCounted

const ProgramConditionScript = preload("res://src/programming/domain/program_condition.gd")

var queries: Array[int] = [
	ConditionCatalog.Query.PATH_CLEAR_AHEAD,
	ConditionCatalog.Query.GAP_AHEAD,
	ConditionCatalog.Query.GOAL_VISIBLE,
	ConditionCatalog.Query.SIGNAL_HEARD,
]

func available_options() -> Array:
	var options := [
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
		{
			"label": "Visao: degrau a frente",
			"modality": ConditionCatalog.Modality.VISION,
			"query": ConditionCatalog.Query.STEP_AHEAD,
		},
		{
			"label": "Visao: inimigo visivel",
			"modality": ConditionCatalog.Modality.VISION,
			"query": ConditionCatalog.Query.ENEMY_VISIBLE,
		},
		{
			"label": "Visao: inimigo ao alcance",
			"modality": ConditionCatalog.Modality.VISION,
			"query": ConditionCatalog.Query.ENEMY_IN_MELEE_RANGE,
		},
	]
	return options.filter(func(option): return queries.has(option["query"]))

func create_condition(modality: int, query: int):
	var condition = ProgramConditionScript.new(modality, query)
	if not condition.is_valid() or not queries.has(query):
		return null

	return condition
