class_name ConditionCatalog
extends RefCounted

enum Modality {
	VISION,
	HEARING,
}

enum Query {
	PATH_CLEAR_AHEAD,
	GAP_AHEAD,
	GOAL_VISIBLE,
	SIGNAL_HEARD,
	STEP_AHEAD,
	ENEMY_VISIBLE,
	ENEMY_IN_MELEE_RANGE,
}

static func is_valid_modality(value: int) -> bool:
	return value >= Modality.VISION and value <= Modality.HEARING

static func is_valid_query(value: int) -> bool:
	return value >= Query.PATH_CLEAR_AHEAD and value <= Query.ENEMY_IN_MELEE_RANGE

static func is_valid_combination(modality: int, query: int) -> bool:
	if not is_valid_modality(modality) or not is_valid_query(query):
		return false

	match modality:
		Modality.VISION:
			return (
				query == Query.PATH_CLEAR_AHEAD
				or query == Query.GAP_AHEAD
				or query == Query.GOAL_VISIBLE
				or query == Query.STEP_AHEAD
				or query == Query.ENEMY_VISIBLE
				or query == Query.ENEMY_IN_MELEE_RANGE
			)
		Modality.HEARING:
			return query == Query.SIGNAL_HEARD

	return false
