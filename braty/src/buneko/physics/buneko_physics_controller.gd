class_name BunekoPhysicsController
extends RefCounted

const AttributesScript = preload("res://src/buneko/domain/buneko_attributes.gd")

enum Direction {
	LEFT = -1,
	RIGHT = 1,
}

var attributes
var direction: int = Direction.RIGHT
var velocity := Vector2.ZERO
var grounded := false
var fall_limit_y := 720.0
var walk_step_duration := 0.18
var run_step_duration := 0.16
var _horizontal_step_time_remaining := 0.0
var _horizontal_step_speed := 0.0

func _init(controller_attributes = null) -> void:
	if controller_attributes == null:
		attributes = AttributesScript.new()
	else:
		attributes = controller_attributes

func walk() -> bool:
	_start_horizontal_step(attributes.walk_speed, walk_step_duration)
	return true

func run() -> bool:
	_start_horizontal_step(attributes.run_speed, run_step_duration)
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
	_horizontal_step_time_remaining = 0.0
	_horizontal_step_speed = 0.0

func step(delta: float, is_on_floor_now: bool) -> Vector2:
	grounded = is_on_floor_now
	_update_horizontal_step(delta)
	if grounded and velocity.y > 0.0:
		velocity.y = 0.0
	elif not grounded:
		velocity.y += attributes.gravity * delta

	return velocity

func has_fallen(global_position: Vector2) -> bool:
	return global_position.y > fall_limit_y

func _start_horizontal_step(speed: float, duration: float) -> void:
	_horizontal_step_time_remaining = duration
	_horizontal_step_speed = speed * direction
	velocity.x = _horizontal_step_speed

func _update_horizontal_step(delta: float) -> void:
	if _horizontal_step_time_remaining <= 0.0:
		if grounded:
			velocity.x = 0.0
		return

	_horizontal_step_time_remaining = max(0.0, _horizontal_step_time_remaining - delta)
	if _horizontal_step_time_remaining <= 0.0 and grounded:
		velocity.x = 0.0
	else:
		velocity.x = _horizontal_step_speed
