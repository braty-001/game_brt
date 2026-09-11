class_name BunekoCharacter
extends CharacterBody2D

const AttributesScript = preload("res://src/buneko/domain/buneko_attributes.gd")
const PhysicsControllerScript = preload("res://src/buneko/physics/buneko_physics_controller.gd")
const MovementPaceScript = preload("res://src/programming/domain/movement_pace.gd")
const HealthPoolScript = preload("res://src/campaign/combat/health_pool.gd")
const MeleeAttackScript = preload("res://src/campaign/combat/melee_attack.gd")

signal fell_out_of_bounds
signal strike_requested(attacker)
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
	scale.x = abs(scale.x) * controller.direction
	return turned

func attack() -> bool:
	return health.is_alive() and melee.begin()

func equip_baton() -> void:
	melee.equip()
	$Visual.queue_redraw()

func has_baton() -> bool:
	return melee.equipped

func is_attack_busy() -> bool:
	return melee.busy

func receive_damage(amount: int) -> int:
	var applied := health.damage(amount)
	if applied > 0 and not health.is_alive():
		defeated.emit()
	return applied

func is_motion_settled() -> bool:
	return controller != null and controller.is_motion_settled()

func show_action_pulse(action_kind: int, refused := false) -> void:
	var visual = get_node_or_null("Visual")
	if visual != null:
		visual.show_action_pulse(action_kind, refused)
