class_name HealthPool
extends RefCounted

var maximum: int
var current: int

func _init(maximum_health := 1) -> void:
	maximum = maxi(1, maximum_health)
	current = maximum

func damage(amount: int) -> int:
	if amount <= 0 or current <= 0:
		return 0
	var applied := mini(amount, current)
	current -= applied
	return applied

func restore() -> void:
	current = maximum

func is_alive() -> bool:
	return current > 0
