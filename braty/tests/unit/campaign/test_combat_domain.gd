extends GutTest

const Health = preload("res://src/campaign/combat/health_pool.gd")
const Melee = preload("res://src/campaign/combat/melee_attack.gd")
const Brain = preload("res://src/campaign/combat/enemy_brain.gd")
const Resolver = preload("res://src/campaign/combat/melee_combat_resolver.gd")

class FakeCombatant:
	extends RefCounted

	var position: Vector2
	var direction: int
	var health: int

	func _init(initial_position: Vector2, initial_direction: int, initial_health := 2) -> void:
		position = initial_position
		direction = initial_direction
		health = initial_health

	func is_alive() -> bool:
		return health > 0

	func combat_position() -> Vector2:
		return position

	func can_reach_combatant(other) -> bool:
		var target: Vector2 = other.combat_position()
		var forward := (target.x - position.x) * direction
		return forward >= 0.0 and forward <= 80.0 and absf(target.y - position.y) <= 48.0

	func melee_damage() -> int:
		return 2

	func melee_max_distance() -> float:
		return 80.0

	func receive_damage(amount: int) -> int:
		var applied := mini(amount, health)
		health -= applied
		return applied

func test_health_applies_exact_damage_and_never_goes_below_zero() -> void:
	var health = Health.new(10)
	assert_eq(health.damage(2), 2)
	assert_eq(health.current, 8)
	assert_eq(health.damage(20), 8)
	assert_eq(health.current, 0)
	assert_false(health.is_alive())
	assert_eq(health.damage(2), 0)
	health.restore()
	assert_eq(health.current, 10)

func test_melee_emits_one_strike_after_windup_and_finishes_at_cycle() -> void:
	var attack = Melee.new()
	assert_false(attack.begin())
	attack.equip()
	assert_true(attack.begin())
	assert_false(attack.begin())
	assert_false(attack.advance(0.19))
	assert_true(attack.advance(0.01))
	assert_false(attack.advance(0.3))
	assert_true(attack.busy)
	assert_false(attack.advance(0.3))
	assert_false(attack.busy)
	assert_true(attack.begin())

func test_melee_reach_is_frontal_short_and_height_limited() -> void:
	assert_true(Melee.can_reach(Vector2.ZERO, 1, Vector2(80, 48)))
	assert_false(Melee.can_reach(Vector2.ZERO, 1, Vector2(80.1, 0)))
	assert_false(Melee.can_reach(Vector2.ZERO, 1, Vector2(-1, 0)))
	assert_false(Melee.can_reach(Vector2.ZERO, 1, Vector2(40, 48.1)))
	assert_true(Melee.can_reach(Vector2.ZERO, -1, Vector2(-50, 0)))

func test_enemy_brain_patrols_approaches_attacks_and_forgets_immediately() -> void:
	var brain = Brain.new()
	assert_eq(brain.decide(100, 100, 300, false, 0, false, -1), Brain.Intent.PATROL_RIGHT)
	assert_eq(brain.decide(300, 100, 300, false, 0, false, 1), Brain.Intent.PATROL_LEFT)
	assert_eq(brain.decide(200, 100, 300, true, 150, false, 1), Brain.Intent.APPROACH_LEFT)
	assert_eq(brain.decide(200, 100, 300, true, 250, false, -1), Brain.Intent.APPROACH_RIGHT)
	assert_eq(brain.decide(200, 100, 300, true, 230, true, 1), Brain.Intent.ATTACK)
	assert_eq(brain.decide(200, 100, 300, false, 230, true, -1), Brain.Intent.PATROL_LEFT)

func test_combat_resolver_uses_public_contract_and_preserves_simultaneous_hits() -> void:
	var left := FakeCombatant.new(Vector2.ZERO, 1)
	var right := FakeCombatant.new(Vector2(50, 0), -1)
	var resolver = Resolver.new()
	var impacts: int = resolver.resolve_batch(
		[left, right],
		func(attacker): return [right] if attacker == left else [left],
		func(_origin, _target, _radius): return true
	)
	assert_eq(impacts, 2)
	assert_false(left.is_alive())
	assert_false(right.is_alive())

func test_combat_resolver_reports_hits_and_misses_after_applying_the_batch() -> void:
	var left := FakeCombatant.new(Vector2.ZERO, 1)
	var right := FakeCombatant.new(Vector2(50, 0), -1)
	var away := FakeCombatant.new(Vector2(300, 0), -1)
	var resolver = Resolver.new()
	watch_signals(resolver)
	assert_eq(resolver.resolve_batch(
		[left, away],
		func(attacker): return [right] if attacker == left else [left],
		func(_origin, _target, _radius): return true
	), 1)
	assert_signal_emit_count(resolver, "batch_resolved", 1)
	var results: Array = get_signal_parameters(resolver, "batch_resolved")[0]
	assert_eq(results.size(), 2)
	assert_true(results[0].hit)
	assert_eq(results[0].damage, 2)
	assert_same(results[0].target, right)
	assert_false(results[1].hit)
	assert_null(results[1].target)
	assert_eq(right.health, 0)

func test_combat_resolver_rejects_occluded_and_out_of_range_targets() -> void:
	var attacker := FakeCombatant.new(Vector2.ZERO, 1)
	var near_target := FakeCombatant.new(Vector2(50, 0), -1)
	var far_target := FakeCombatant.new(Vector2(120, 0), -1)
	var resolver = Resolver.new()
	assert_eq(resolver.resolve_batch(
		[attacker],
		func(_source): return [far_target],
		func(_origin, _target, _radius): return true
	), 0)
	assert_eq(resolver.resolve_batch(
		[attacker],
		func(_source): return [near_target],
		func(_origin, _target, _radius): return false
	), 0)
	assert_eq(near_target.health, 2)
	assert_eq(far_target.health, 2)
