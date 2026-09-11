extends GutTest

const Health = preload("res://src/campaign/combat/health_pool.gd")
const Melee = preload("res://src/campaign/combat/melee_attack.gd")
const Brain = preload("res://src/campaign/combat/enemy_brain.gd")

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
