class_name BunekoAttributes
extends RefCounted

var movement_speed: float
var ground_deceleration: float
var jump_impulse: float
var gravity: float
var strength: float

func _init(
	attribute_movement_speed: float = 160.0,
	attribute_ground_deceleration: float = 180.0,
	attribute_jump_impulse: float = 500.0,
	attribute_gravity: float = 980.0,
	attribute_strength: float = 1.0
) -> void:
	movement_speed = attribute_movement_speed
	ground_deceleration = attribute_ground_deceleration
	jump_impulse = attribute_jump_impulse
	gravity = attribute_gravity
	strength = attribute_strength

func duplicate_attributes():
	return load("res://src/buneko/domain/buneko_attributes.gd").new(
		movement_speed,
		ground_deceleration,
		jump_impulse,
		gravity,
		strength
	)

func apply_modifiers(modifiers: Dictionary) -> void:
	for key in modifiers:
		match key:
			"movement_speed":
				movement_speed += float(modifiers[key])
			"ground_deceleration":
				ground_deceleration += float(modifiers[key])
			"jump_impulse":
				jump_impulse += float(modifiers[key])
			"gravity":
				gravity += float(modifiers[key])
			"strength":
				strength += float(modifiers[key])
