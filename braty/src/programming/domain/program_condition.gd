class_name ProgramCondition
extends RefCounted

var modality: int
var query: int

func _init(condition_modality: int, condition_query: int) -> void:
	modality = condition_modality
	query = condition_query

func is_valid() -> bool:
	return ConditionCatalog.is_valid_combination(modality, query)
