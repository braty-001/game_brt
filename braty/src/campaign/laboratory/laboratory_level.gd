class_name LaboratoryLevel
extends Node2D

const SensorScript = preload("res://src/campaign/laboratory/laboratory_world_sensor.gd")
const BunekoScene = preload("res://scenes/buneko/buneko.tscn")
const EnemyScene = preload("res://scenes/campaign/laboratory_enemy.tscn")
const VisionScript = preload("res://src/campaign/laboratory/occluded_vision.gd")
const MeleeAttackScript = preload("res://src/campaign/combat/melee_attack.gd")

const WORLD_SIZE := Vector2(1440, 720)
var sensor = SensorScript.new()
var buneko
var enemies: Array = []
var _combat_vision = VisionScript.new()
var _pending_strikes: Array = []
var _defeat_emitted := false

signal baton_checkpoint_reached
signal buneko_defeated

func _ready() -> void:
	sensor.configure(solid_rectangles(), $Exit.position)
	$Fog.vision = sensor.vision
	_combat_vision.occluders = sensor.solids
	$BatonPickup.collected.connect(_on_baton_collected)

func spawn(assembly, checkpoint_active := false):
	buneko = BunekoScene.instantiate()
	buneko.position = $Checkpoint.position if checkpoint_active else $Start.position
	buneko.fall_limit_y = WORLD_SIZE.y + 80
	buneko.configure_attributes(BunekoAttributeResolver.resolve(assembly))
	add_child(buneko)
	buneko.strike_requested.connect(_queue_strike)
	if checkpoint_active:
		buneko.equip_baton()
		$BatonPickup.consume()
	_spawn_enemies()
	sensor.configure_combat(func(): return enemies, buneko.has_baton)
	sensor.update_from_buneko(buneko)
	return buneko

func solid_rectangles() -> Array[Rect2]:
	var result: Array[Rect2] = []
	for solid in $Solids.get_children():
		var collision: CollisionShape2D = solid.get_node("Collision")
		var shape_size: Vector2 = collision.shape.size
		result.append(Rect2(solid.position + collision.position - shape_size / 2, shape_size))
	return result

func reached_exit() -> bool:
	return buneko != null and exit_rect().has_point(buneko.position)

func exit_rect() -> Rect2:
	return Rect2($Exit.position - Vector2(34, 44), Vector2(68, 88))

func _process(_delta: float) -> void:
	if buneko != null:
		sensor.update_from_buneko(buneko)

func _physics_process(_delta: float) -> void:
	_resolve_strikes()
	if buneko != null and not buneko.health.is_alive() and not _defeat_emitted:
		_defeat_emitted = true
		buneko_defeated.emit()

func can_see_between(origin: Vector2, target: Vector2, radius := 240.0) -> bool:
	_combat_vision.origin = origin
	_combat_vision.radius = radius
	return _combat_vision.can_see(target)

func living_enemy_count() -> int:
	return enemies.filter(func(enemy): return enemy.health.is_alive()).size()

func _spawn_enemies() -> void:
	var placements := [
		[Vector2(300, 594), 250.0, 720.0, 1],
		[Vector2(340, 354), 210.0, 520.0, 1],
		[Vector2(760, 354), 620.0, 920.0, -1],
	]
	for placement in placements:
		var enemy = EnemyScene.instantiate()
		enemy.position = placement[0]
		add_child(enemy)
		enemy.configure(buneko, can_see_between, placement[1], placement[2], placement[3])
		enemy.strike_requested.connect(_queue_strike)
		enemies.append(enemy)

func _on_baton_collected() -> void:
	if buneko == null or not buneko.health.is_alive() or not $BatonPickup.consume():
		return
	buneko.equip_baton()
	baton_checkpoint_reached.emit()

func _queue_strike(attacker) -> void:
	_pending_strikes.append(attacker)

func _resolve_strikes() -> void:
	if _pending_strikes.is_empty() or buneko == null:
		return
	var impacts: Array = []
	for attacker in _pending_strikes:
		if attacker == null or not attacker.health.is_alive():
			continue
		var target = buneko if attacker != buneko else _nearest_melee_target(attacker)
		if target == null or not target.health.is_alive():
			continue
		var attack_direction: int = attacker.controller.direction if attacker == buneko else attacker.direction
		if not MeleeAttackScript.can_reach(attacker.position, attack_direction, target.position):
			continue
		if not can_see_between(attacker.position, target.position, MeleeAttackScript.MAX_CENTER_DISTANCE):
			continue
		impacts.append(target)
	_pending_strikes.clear()
	for target in impacts:
		target.receive_damage(MeleeAttackScript.DAMAGE)

func _nearest_melee_target(attacker):
	var nearest
	var nearest_distance := INF
	for enemy in enemies:
		if not enemy.health.is_alive() or not MeleeAttackScript.can_reach(attacker.position, attacker.controller.direction, enemy.position):
			continue
		var distance: float = attacker.position.distance_squared_to(enemy.position)
		if distance < nearest_distance:
			nearest = enemy
			nearest_distance = distance
	return nearest

func _draw() -> void:
	draw_rect(Rect2(Vector2.ZERO, WORLD_SIZE), Color("16272d"))
	for x in range(24, 1440, 80):
		draw_line(Vector2(x, 96), Vector2(x, 620), Color("21363c"))
	for y in [150, 390]:
		for x in range(140, 900, 190):
			draw_rect(Rect2(x, y, 115, 90), Color("263e46"))
			draw_rect(Rect2(x + 8, y + 8, 99, 74), Color("1b505b"), false, 3)
	for x in [240, 520, 770]:
		_draw_bench(Vector2(x, 600))
		_draw_bench(Vector2(x, 360))
	for rect in solid_rectangles():
		draw_rect(rect, Color("425963"))
		draw_line(rect.position, Vector2(rect.end.x, rect.position.y), Color("61b2b2"), 4)
	var exit := exit_rect()
	draw_rect(exit, Color("193e37"))
	draw_rect(exit, Color("57d6aa"), false, 4)
	draw_line(exit.position + Vector2(12, 44), exit.position + Vector2(46, 44), Color("57d6aa"), 4)
	draw_line(exit.position + Vector2(12, 44), exit.position + Vector2(24, 34), Color("57d6aa"), 4)
	draw_line(exit.position + Vector2(12, 44), exit.position + Vector2(24, 54), Color("57d6aa"), 4)
	draw_string(ThemeDB.fallback_font, Vector2(116, 562), "BASTAO / CHECKPOINT", HORIZONTAL_ALIGNMENT_LEFT, -1, 14, Color("8bd8c5"))

func _draw_bench(at: Vector2) -> void:
	draw_rect(Rect2(at - Vector2(0, 18), Vector2(110, 10)), Color("698087"))
	draw_line(at + Vector2(8, -8), at + Vector2(8, 20), Color("425963"), 5)
	draw_line(at + Vector2(100, -8), at + Vector2(100, 20), Color("425963"), 5)
	draw_rect(Rect2(at + Vector2(22, -54), Vector2(43, 34)), Color("192d35"))
	draw_rect(Rect2(at + Vector2(27, -49), Vector2(33, 23)), Color("247f89"))
