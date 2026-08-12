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

func _init(controller_attributes = null) -> void:
	if controller_attributes == null:
		attributes = AttributesScript.new()
	else:
		attributes = controller_attributes

func walk() -> bool:
	velocity.x = attributes.walk_speed * direction
	return true

func run() -> bool:
	velocity.x = attributes.run_speed * direction
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

func step(delta: float, is_on_floor_now: bool) -> Vector2:
	grounded = is_on_floor_now
	if grounded and velocity.y > 0.0:
		velocity.y = 0.0
	elif not grounded:
		velocity.y += attributes.gravity * delta

	return velocity

func has_fallen(global_position: Vector2) -> bool:
	return global_position.y > fall_limit_y
