class_name BunekoPhysicsController
extends RefCounted

const AttributesScript = preload("res://src/buneko/domain/buneko_attributes.gd")
const MovementPaceScript = preload("res://src/programming/domain/movement_pace.gd")

enum Direction {
	LEFT = -1,
	RIGHT = 1,
}

var attributes
var direction: int = Direction.RIGHT
var velocity := Vector2.ZERO
var grounded := false
var fall_limit_y := 720.0
var _has_horizontal_intent := false
var _horizontal_intent_speed := 0.0

func _init(controller_attributes = null) -> void:
	if controller_attributes == null:
		attributes = AttributesScript.new()
	else:
		attributes = controller_attributes

func walk(pace: int = MovementPaceScript.Value.NORMAL) -> bool:
	if not MovementPaceScript.is_valid(pace):
		return false

	_has_horizontal_intent = true
	_horizontal_intent_speed = attributes.movement_speed * MovementPaceScript.speed_multiplier(pace) * direction
	velocity.x = _horizontal_intent_speed
	return true

func jump() -> bool:
	if not grounded:
		return false

	velocity.y = -attributes.jump_impulse
	grounded = false
	return true

func turn() -> bool:
	direction *= -1
	return true

func stop_horizontal() -> void:
	velocity.x = 0.0
	_has_horizontal_intent = false
	_horizontal_intent_speed = 0.0

func step(delta: float, is_on_floor_now: bool) -> Vector2:
	grounded = is_on_floor_now
	_update_horizontal_intent(delta)
	if grounded and velocity.y > 0.0:
		velocity.y = 0.0
	elif not grounded:
		velocity.y += attributes.gravity * delta

	return velocity

func has_fallen(global_position: Vector2) -> bool:
	return global_position.y > fall_limit_y

func is_motion_settled() -> bool:
	return (
		grounded
		and velocity.is_zero_approx()
		and not _has_horizontal_intent
	)

func _update_horizontal_intent(delta: float) -> void:
	if _has_horizontal_intent:
		velocity.x = _horizontal_intent_speed
	elif grounded and velocity.y >= 0.0:
		velocity.x = move_toward(velocity.x, 0.0, attributes.ground_deceleration * delta)

	_has_horizontal_intent = false
	_horizontal_intent_speed = 0.0
