class_name BunekoAttributes
extends RefCounted

var walk_speed: float
var run_speed: float
var jump_impulse: float
var gravity: float
var strength: float

func _init(
	attribute_walk_speed: float = 160.0,
	attribute_run_speed: float = 220.0,
	attribute_jump_impulse: float = 500.0,
	attribute_gravity: float = 980.0,
	attribute_strength: float = 1.0
) -> void:
	walk_speed = attribute_walk_speed
	run_speed = attribute_run_speed
	jump_impulse = attribute_jump_impulse
	gravity = attribute_gravity
	strength = attribute_strength

func duplicate_attributes():
	return load("res://src/buneko/domain/buneko_attributes.gd").new(
		walk_speed,
		run_speed,
		jump_impulse,
		gravity,
		strength
	)

func apply_modifiers(modifiers: Dictionary) -> void:
	for key in modifiers:
		match key:
			"walk_speed":
				walk_speed += float(modifiers[key])
			"run_speed":
				run_speed += float(modifiers[key])
			"jump_impulse":
				jump_impulse += float(modifiers[key])
			"gravity":
				gravity += float(modifiers[key])
			"strength":
				strength += float(modifiers[key])
