class_name MeleeCombatResolver
extends RefCounted

signal batch_resolved(results: Array)

func resolve_batch(attackers: Array, opponents_provider: Callable, sight_check: Callable) -> int:
	if not opponents_provider.is_valid() or not sight_check.is_valid():
		return 0
	var pending_results: Array = []
	for attacker in attackers:
		if not _can_attack(attacker):
			continue
		var opponents = opponents_provider.call(attacker)
		if not opponents is Array:
			continue
		var target = _nearest_target(attacker, opponents)
		if target == null:
			pending_results.append(_result(attacker, null, 0))
			continue
		if not bool(sight_check.call(
			attacker.combat_position(),
			target.combat_position(),
			attacker.melee_max_distance()
		)):
			pending_results.append(_result(attacker, null, 0))
			continue
		pending_results.append(_result(attacker, target, attacker.melee_damage()))

	var hit_count := 0
	for result in pending_results:
		var target = result.target
		if target != null:
			result.damage = target.receive_damage(result.damage)
			result.hit = result.damage > 0
			if result.hit:
				hit_count += 1
	batch_resolved.emit(pending_results)
	return hit_count

func _result(attacker, target, damage: int) -> Dictionary:
	return {
		"attacker": attacker,
		"target": target,
		"damage": damage,
		"hit": false,
	}

func _nearest_target(attacker, opponents):
	var nearest
	var nearest_distance := INF
	for target in opponents:
		if not _is_combatant_alive(target) or not attacker.can_reach_combatant(target):
			continue
		var distance: float = attacker.combat_position().distance_squared_to(target.combat_position())
		if distance < nearest_distance:
			nearest = target
			nearest_distance = distance
	return nearest

func _is_combatant_alive(combatant) -> bool:
	return (
		combatant != null
		and combatant.has_method("is_alive")
		and combatant.has_method("combat_position")
		and combatant.has_method("receive_damage")
		and combatant.is_alive()
	)

func _can_attack(combatant) -> bool:
	return (
		_is_combatant_alive(combatant)
		and combatant.has_method("can_reach_combatant")
		and combatant.has_method("melee_damage")
		and combatant.has_method("melee_max_distance")
	)
