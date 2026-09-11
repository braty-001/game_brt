class_name LaboratoryEnemy
extends CharacterBody2D

const BrainScript = preload("res://src/campaign/combat/enemy_brain.gd")
const HealthPoolScript = preload("res://src/campaign/combat/health_pool.gd")
const MeleeAttackScript = preload("res://src/campaign/combat/melee_attack.gd")

signal strike_requested(attacker)
signal defeated(enemy)

const SPEED := 95.0
const GRAVITY := 980.0

var health = HealthPoolScript.new(2)
var melee = MeleeAttackScript.new()
var brain = BrainScript.new()
var target
var visibility_check: Callable
var patrol_min := 0.0
var patrol_max := 0.0
var direction := 1
var last_intent: int = BrainScript.Intent.PATROL_RIGHT

func _ready() -> void:
	melee.equip()
	queue_redraw()

func configure(combat_target, sight_check: Callable, minimum_x: float, maximum_x: float, initial_direction := 1) -> void:
	target = combat_target
	visibility_check = sight_check
	patrol_min = minimum_x
	patrol_max = maximum_x
	direction = initial_direction
	scale.x = absf(scale.x) * direction

func _physics_process(delta: float) -> void:
	if not health.is_alive():
		return
	if melee.advance(delta):
		strike_requested.emit(self)
	var target_alive: bool = target != null and target.health.is_alive()
	var target_visible := target_alive and visibility_check.is_valid() and bool(visibility_check.call(position, target.position, 240.0))
	var in_range := target_visible and MeleeAttackScript.can_reach(position, direction, target.position)
	last_intent = brain.decide(position.x, patrol_min, patrol_max, target_visible, target.position.x if target_alive else position.x, in_range, direction)
	match last_intent:
		BrainScript.Intent.ATTACK:
			velocity.x = move_toward(velocity.x, 0.0, SPEED * 6.0 * delta)
			melee.begin()
		BrainScript.Intent.PATROL_LEFT, BrainScript.Intent.APPROACH_LEFT:
			_set_direction(-1)
			velocity.x = -SPEED
		BrainScript.Intent.PATROL_RIGHT, BrainScript.Intent.APPROACH_RIGHT:
			_set_direction(1)
			velocity.x = SPEED
	if not is_on_floor():
		velocity.y += GRAVITY * delta
	elif velocity.y > 0.0:
		velocity.y = 0.0
	move_and_slide()
	queue_redraw()

func receive_damage(amount: int) -> int:
	var applied := health.damage(amount)
	if applied > 0 and not health.is_alive():
		velocity = Vector2.ZERO
		melee.reset()
		$CollisionShape2D.set_deferred("disabled", true)
		defeated.emit(self)
	queue_redraw()
	return applied

func is_attack_busy() -> bool:
	return melee.busy

func _set_direction(next_direction: int) -> void:
	direction = next_direction
	scale.x = absf(scale.x) * direction

func _draw() -> void:
	if not health.is_alive():
		draw_circle(Vector2(0, 18), 18, Color("354248"))
		draw_line(Vector2(-20, 18), Vector2(20, 18), Color("9b6b62"), 5)
		return
	draw_circle(Vector2(0, -7), 13, Color("cf756c"))
	draw_rect(Rect2(-13, 6, 26, 26), Color("714a4d"))
	draw_line(Vector2(8, 7), Vector2(31, -15), Color("c9a56a"), 5)
	draw_circle(Vector2(5, -9), 2.5, Color("fff1cb"))
	var ratio: float = float(health.current) / float(health.maximum)
	draw_rect(Rect2(-18, -30, 36, 5), Color("321f24"))
	draw_rect(Rect2(-18, -30, 36 * ratio, 5), Color("e66c68"))
	if melee.busy:
		draw_arc(Vector2.ZERO, 38, -0.8, 0.8, 14, Color("ffca72"), 3)
