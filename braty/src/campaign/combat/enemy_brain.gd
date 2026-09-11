class_name EnemyBrain
extends RefCounted

enum Intent {
	PATROL_LEFT,
	PATROL_RIGHT,
	APPROACH_LEFT,
	APPROACH_RIGHT,
	ATTACK,
}

func decide(current_x: float, patrol_min: float, patrol_max: float, target_visible: bool, target_x: float, target_in_range: bool, direction: int) -> int:
	if target_visible:
		if target_in_range:
			return Intent.ATTACK
		return Intent.APPROACH_LEFT if target_x < current_x else Intent.APPROACH_RIGHT
	if current_x <= patrol_min:
		return Intent.PATROL_RIGHT
	if current_x >= patrol_max:
		return Intent.PATROL_LEFT
	return Intent.PATROL_LEFT if direction < 0 else Intent.PATROL_RIGHT
