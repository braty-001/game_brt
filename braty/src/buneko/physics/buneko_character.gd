class_name BunekoCharacter
extends CharacterBody2D

const AttributesScript = preload("res://src/buneko/domain/buneko_attributes.gd")
const PhysicsControllerScript = preload("res://src/buneko/physics/buneko_physics_controller.gd")
const MovementPaceScript = preload("res://src/programming/domain/movement_pace.gd")
const HealthPoolScript = preload("res://src/campaign/combat/health_pool.gd")
const MeleeAttackScript = preload("res://src/campaign/combat/melee_attack.gd")

signal fell_out_of_bounds
signal attack_started(actor)
signal strike_requested(attacker)
signal damage_received(actor, amount: int)
signal landed(actor)
signal defeated

@export var movement_speed := 160.0
@export var ground_deceleration := 180.0
@export var jump_impulse := 500.0
@export var gravity := 980.0
@export var strength := 1.0
@export var fall_limit_y := 720.0

var controller
var _configured_attributes
var health = HealthPoolScript.new(10)
var melee = MeleeAttackScript.new()
var _has_been_grounded := false
var _was_airborne_after_grounding := false

func _ready() -> void:
	var attributes = AttributesScript.new(
		movement_speed,
		ground_deceleration,
		jump_impulse,
		gravity,
		strength
	)
	if _configured_attributes != null:
		attributes = _configured_attributes.duplicate_attributes()
	controller = PhysicsControllerScript.new(attributes)
	controller.fall_limit_y = fall_limit_y

func configure_attributes(attributes) -> bool:
	if attributes == null:
		return false

	_configured_attributes = attributes.duplicate_attributes()
	if controller != null:
		controller.attributes = _configured_attributes.duplicate_attributes()
	return true

func _physics_process(delta: float) -> void:
	if controller == null:
		return

	velocity = controller.step(delta, is_on_floor())
	move_and_slide()
	_track_ground_transition()
	if melee.advance(delta):
		strike_requested.emit(self)
	if controller.has_fallen(global_position):
		fell_out_of_bounds.emit()

func walk(pace: int = MovementPaceScript.Value.NORMAL) -> bool:
	return controller != null and controller.walk(pace)

func jump() -> bool:
	if controller != null:
		controller.grounded = is_on_floor()
	return controller != null and controller.jump()

func turn() -> bool:
	if controller == null:
		return false

	var turned: bool = controller.turn()
	$Visual.scale = Vector2(controller.direction, 1.0)
	return turned

func attack() -> bool:
	var accepted := health.is_alive() and melee.begin()
	if accepted:
		attack_started.emit(self)
	return accepted

func equip_baton() -> void:
	melee.equip()
	$Visual.queue_redraw()

func has_baton() -> bool:
	return melee.equipped

func is_attack_busy() -> bool:
	return melee.busy

func receive_damage(amount: int) -> int:
	var applied := health.damage(amount)
	if applied > 0:
		damage_received.emit(self, applied)
	if applied > 0 and not health.is_alive():
		defeated.emit()
	return applied

func is_alive() -> bool:
	return health.is_alive()

func current_health() -> int:
	return health.current

func health_capacity() -> int:
	return health.maximum

func combat_position() -> Vector2:
	return global_position

func facing_direction() -> int:
	return controller.direction if controller != null else 1

func face_direction(next_direction: int) -> bool:
	if controller == null or (next_direction != -1 and next_direction != 1):
		return false
	if controller.direction != next_direction:
		return turn()
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

func attack_elapsed() -> float:
	return melee.elapsed

func is_motion_settled() -> bool:
	return controller != null and controller.is_motion_settled()

func show_action_pulse(action_kind: int, refused := false) -> void:
	var visual = get_node_or_null("Visual")
	if visual != null:
		visual.show_action_pulse(action_kind, refused)

func set_visual_overlay_z(next_z_index: int) -> void:
	var visual := get_node_or_null("Visual") as CanvasItem
	if visual != null:
		visual.z_index = next_z_index

func _track_ground_transition() -> void:
	var grounded := is_on_floor()
	if grounded:
		if _has_been_grounded and _was_airborne_after_grounding:
			landed.emit(self)
		_was_airborne_after_grounding = false
		_has_been_grounded = true
	elif _has_been_grounded:
		_was_airborne_after_grounding = true
