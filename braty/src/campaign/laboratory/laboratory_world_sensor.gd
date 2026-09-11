class_name LaboratoryWorldSensor
extends RefCounted

const VisionScript = preload("res://src/campaign/laboratory/occluded_vision.gd")
const MeleeAttackScript = preload("res://src/campaign/combat/melee_attack.gd")

var vision = VisionScript.new()
var buneko_position := Vector2.ZERO
var direction := 1
var goal_position := Vector2(70, 350)
var solids: Array[Rect2] = []
var enemies_provider: Callable
var weapon_provider: Callable

func configure(rectangles: Array[Rect2], goal: Vector2) -> void:
	solids = rectangles.duplicate()
	vision.occluders = solids
	goal_position = goal

func configure_combat(enemy_source: Callable, weapon_source: Callable) -> void:
	enemies_provider = enemy_source
	weapon_provider = weapon_source

func update_from_buneko(buneko) -> void:
	buneko_position = buneko.position
	direction = buneko.controller.direction
	vision.origin = buneko_position

func is_path_clear_ahead() -> bool:
	var target := buneko_position + Vector2(direction * 56, 0)
	return vision.can_see(target) and _has_support(target.x)

func has_gap_ahead() -> bool:
	var target := buneko_position + Vector2(direction * 56, 0)
	return vision.can_see(target) and not _has_support(target.x)

func has_step_ahead() -> bool:
	var feet := buneko_position.y + 24
	for rect in solids:
		var rise := feet - rect.position.y
		if rise < 10 or rise > 90:
			continue
		var edge := rect.position.x if direction > 0 else rect.end.x
		var distance := (edge - buneko_position.x) * direction
		if distance < 0 or distance > 100:
			continue
		var surface := Vector2(edge - direction * 0.5, rect.position.y + 2)
		if vision.can_see(surface):
			return true
	return false

func can_see_goal() -> bool:
	return vision.can_see(goal_position)

func heard_signal() -> bool:
	return false

func can_see_enemy() -> bool:
	return _nearest_visible_enemy(false) != null

func has_enemy_in_melee_range() -> bool:
	if not weapon_provider.is_valid() or not bool(weapon_provider.call()):
		return false
	return _nearest_visible_enemy(true) != null

func _nearest_visible_enemy(require_melee_range: bool):
	if not enemies_provider.is_valid():
		return null
	var nearest
	var nearest_distance := INF
	for enemy in enemies_provider.call():
		if enemy == null or not enemy.health.is_alive() or not vision.can_see(enemy.position):
			continue
		if require_melee_range and not MeleeAttackScript.can_reach(buneko_position, direction, enemy.position):
			continue
		var distance := buneko_position.distance_squared_to(enemy.position)
		if distance < nearest_distance:
			nearest = enemy
			nearest_distance = distance
	return nearest

func _has_support(x: float) -> bool:
	for rect in solids:
		var below: float = rect.position.y - buneko_position.y
		if x >= rect.position.x and x <= rect.end.x and below >= 18.0 and below <= 56.0:
			return true
	return false
