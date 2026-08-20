class_name BunekoCharacter
extends CharacterBody2D

const AttributesScript = preload("res://src/buneko/domain/buneko_attributes.gd")
const PhysicsControllerScript = preload("res://src/buneko/physics/buneko_physics_controller.gd")

signal fell_out_of_bounds

@export var walk_speed := 160.0
@export var run_speed := 220.0
@export var jump_impulse := 500.0
@export var gravity := 980.0
@export var strength := 1.0
@export var fall_limit_y := 720.0

var controller

func _ready() -> void:
	var attributes = AttributesScript.new(walk_speed, run_speed, jump_impulse, gravity, strength)
	controller = PhysicsControllerScript.new(attributes)
	controller.fall_limit_y = fall_limit_y

func _physics_process(delta: float) -> void:
	if controller == null:
		return

	velocity = controller.step(delta, is_on_floor())
	move_and_slide()
	if controller.has_fallen(global_position):
		fell_out_of_bounds.emit()

func walk() -> bool:
	return controller != null and controller.walk()

func run() -> bool:
	return controller != null and controller.run()

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

func show_action_pulse(action_kind: int, refused := false) -> void:
	var visual = get_node_or_null("Visual")
	if visual != null:
		visual.show_action_pulse(action_kind, refused)
