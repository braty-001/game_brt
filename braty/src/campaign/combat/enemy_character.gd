class_name EnemyCharacter
extends CharacterBody2D

const BrainScript = preload("res://src/campaign/combat/enemy_brain.gd")
const HealthPoolScript = preload("res://src/campaign/combat/health_pool.gd")
const MeleeAttackScript = preload("res://src/campaign/combat/melee_attack.gd")

signal strike_requested(attacker)
signal attack_started(actor)
signal damage_received(actor, amount: int)
signal awareness_changed(actor, visible: bool)
signal defeated(enemy)

@export var maximum_health := 2
@export var movement_speed := 95.0
@export var gravity := 980.0
@export var sight_range := 240.0

var brain = BrainScript.new()
var last_intent: int = BrainScript.Intent.PATROL_RIGHT

var _health
var _melee = MeleeAttackScript.new()
var _target
var _visibility_check: Callable
var _patrol_min := 0.0
var _patrol_max := 0.0
var _direction := 1
var _target_was_visible := false

func _ready() -> void:
	_health = HealthPoolScript.new(maximum_health)
	_melee.equip()
	_refresh_visual()

func configure(combat_target, sight_check: Callable, minimum_x: float, maximum_x: float, initial_direction := 1) -> void:
	_target = combat_target
	_visibility_check = sight_check
	_patrol_min = minf(minimum_x, maximum_x)
	_patrol_max = maxf(minimum_x, maximum_x)
	face_direction(initial_direction)

func _physics_process(delta: float) -> void:
	if not is_alive():
		return
	if _melee.advance(delta):
		strike_requested.emit(self)

	var target_alive: bool = _target != null and _target.has_method("is_alive") and _target.is_alive()
	var target_position: Vector2 = combat_position()
	if target_alive and _target.has_method("combat_position"):
		target_position = _target.combat_position()
	var target_visible: bool = target_alive and _can_see_position(target_position)
	if target_visible != _target_was_visible:
		_target_was_visible = target_visible
		awareness_changed.emit(self, target_visible)
	var target_in_range: bool = target_visible and can_reach_combatant(_target)
	last_intent = brain.decide(
		combat_position().x,
		_patrol_min,
		_patrol_max,
		target_visible,
		target_position.x,
		target_in_range,
		_direction
	)
	_apply_intent(last_intent, delta)
	_apply_gravity(delta)
	move_and_slide()
	_refresh_visual()

func _can_see_position(target_position: Vector2) -> bool:
	return _visibility_check.is_valid() and bool(
		_visibility_check.call(combat_position(), facing_direction(), target_position, sight_range)
	)

func _apply_intent(intent: int, delta: float) -> void:
	match intent:
		BrainScript.Intent.ATTACK:
			velocity.x = move_toward(velocity.x, 0.0, movement_speed * 6.0 * delta)
			if _melee.begin():
				attack_started.emit(self)
		BrainScript.Intent.PATROL_LEFT, BrainScript.Intent.APPROACH_LEFT:
			face_direction(-1)
			velocity.x = -movement_speed
		BrainScript.Intent.PATROL_RIGHT, BrainScript.Intent.APPROACH_RIGHT:
			face_direction(1)
			velocity.x = movement_speed

func _apply_gravity(delta: float) -> void:
	if not is_on_floor():
		velocity.y += gravity * delta
	elif velocity.y > 0.0:
		velocity.y = 0.0

func receive_damage(amount: int) -> int:
	if _health == null:
		return 0
	var applied: int = _health.damage(amount)
	if applied > 0:
		damage_received.emit(self, applied)
	if applied > 0 and not is_alive():
		velocity = Vector2.ZERO
		_melee.reset()
		var collision := get_node_or_null("CollisionShape2D") as CollisionShape2D
		if collision != null:
			collision.set_deferred("disabled", true)
		defeated.emit(self)
	_refresh_visual()
	return applied

func is_alive() -> bool:
	return _health != null and _health.is_alive()

func current_health() -> int:
	return _health.current if _health != null else 0

func health_capacity() -> int:
	return _health.maximum if _health != null else maxi(1, maximum_health)

func combat_position() -> Vector2:
	return global_position

func facing_direction() -> int:
	return _direction

func face_direction(next_direction: int) -> bool:
	if next_direction != -1 and next_direction != 1:
		return false
	_direction = next_direction
	var visual := get_node_or_null("Visual") as Node2D
	if visual != null:
		visual.scale = Vector2(_direction, 1.0)
	return true

func can_reach_combatant(other) -> bool:
	return other != null and other.has_method("combat_position") and MeleeAttackScript.can_reach(
		combat_position(),
		facing_direction(),
		other.combat_position()
	)

func melee_damage() -> int:
	return MeleeAttackScript.DAMAGE

func melee_max_distance() -> float:
	return MeleeAttackScript.MAX_CENTER_DISTANCE

func is_attack_busy() -> bool:
	return _melee.busy

func attack_elapsed() -> float:
	return _melee.elapsed

func _refresh_visual() -> void:
	var visual := get_node_or_null("Visual")
	if visual != null:
		visual.queue_redraw()
