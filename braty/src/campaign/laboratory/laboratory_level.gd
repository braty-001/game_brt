class_name LaboratoryLevel
extends Node2D

const SensorScript = preload("res://src/campaign/laboratory/laboratory_world_sensor.gd")
const BunekoScene = preload("res://scenes/buneko/buneko.tscn")
const VisionScript = preload("res://src/campaign/laboratory/occluded_vision.gd")
const CombatResolverScript = preload("res://src/campaign/combat/melee_combat_resolver.gd")
const CombatAudioScript = preload("res://src/campaign/presentation/combat_audio_presenter.gd")

const WORLD_SIZE := Vector2(1440, 720)
var sensor = SensorScript.new()
var buneko
var enemies: Array = []
var _combat_vision = VisionScript.new()
var _combat_resolver = CombatResolverScript.new()
var _pending_strikes: Array = []
var _defeat_emitted := false
var _simulation_suspended := false
var combat_audio

signal baton_checkpoint_reached
signal buneko_defeated
signal combat_batch_resolved(results: Array)

func _ready() -> void:
	var rectangles := solid_rectangles()
	sensor.configure(rectangles, $Exit.position)
	$Fog.vision = sensor.vision
	$Fog.known_solids = rectangles
	_combat_vision.occluders = sensor.solids
	_combat_resolver.batch_resolved.connect(_on_combat_batch_resolved)
	combat_audio = CombatAudioScript.new()
	add_child(combat_audio)
	$BatonPickup.collected.connect(_on_baton_collected)

func spawn(assembly, checkpoint_active := false):
	buneko = BunekoScene.instantiate()
	buneko.position = $Checkpoint.position if checkpoint_active else $Start.position
	buneko.fall_limit_y = WORLD_SIZE.y + 80
	buneko.configure_attributes(BunekoAttributeResolver.resolve(assembly))
	add_child(buneko)
	buneko.set_visual_overlay_z($Fog.z_index + 1)
	buneko.strike_requested.connect(_queue_strike)
	combat_audio.observe_buneko(buneko)
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
	if buneko != null and not buneko.is_alive() and not _defeat_emitted:
		_defeat_emitted = true
		buneko_defeated.emit()

func can_see_target(origin: Vector2, direction: int, target: Vector2, radius := 240.0) -> bool:
	_combat_vision.origin = origin
	_combat_vision.facing_direction = direction
	_combat_vision.radius = radius
	return _combat_vision.can_see(target)

func has_clear_combat_line(origin: Vector2, target: Vector2, radius := 240.0) -> bool:
	_combat_vision.origin = origin
	_combat_vision.radius = radius
	return _combat_vision.has_clear_line(target, radius)

func living_enemy_count() -> int:
	return enemies.filter(func(enemy): return enemy.is_alive()).size()

func set_simulation_suspended(suspended: bool) -> void:
	_simulation_suspended = suspended
	set_physics_process(not suspended)
	if buneko != null:
		buneko.set_physics_process(not suspended)
	for enemy in enemies:
		if is_instance_valid(enemy):
			enemy.set_physics_process(not suspended)

func is_simulation_suspended() -> bool:
	return _simulation_suspended

func stop_presentation_audio() -> void:
	if combat_audio != null:
		combat_audio.stop_all()

func _spawn_enemies() -> void:
	for spawn_point in $EnemySpawns.get_children():
		if not spawn_point.has_method("spawn_enemy"):
			continue
		var enemy = spawn_point.spawn_enemy(self, buneko, can_see_target)
		if enemy == null:
			continue
		enemy.strike_requested.connect(_queue_strike)
		enemies.append(enemy)

func _on_baton_collected() -> void:
	if buneko == null or not buneko.is_alive() or not $BatonPickup.consume():
		return
	buneko.equip_baton()
	baton_checkpoint_reached.emit()

func _queue_strike(attacker) -> void:
	_pending_strikes.append(attacker)
	if combat_audio != null and _should_hear_combatant(attacker):
		combat_audio.play_swing()

func _resolve_strikes() -> void:
	if _pending_strikes.is_empty() or buneko == null:
		return
	var attackers := _pending_strikes.duplicate()
	_pending_strikes.clear()
	_combat_resolver.resolve_batch(attackers, _opponents_for, has_clear_combat_line)

func _on_combat_batch_resolved(results: Array) -> void:
	if combat_audio != null and results.any(_is_audible_hit):
		combat_audio.play_hit()
	combat_batch_resolved.emit(results)
	if buneko != null and not buneko.is_alive() and not _defeat_emitted:
		_defeat_emitted = true
		buneko_defeated.emit()

func _is_audible_hit(result: Dictionary) -> bool:
	if not bool(result.get("hit", false)):
		return false
	var target = result.get("target")
	return target == buneko or _should_hear_combatant(target)

func _should_hear_combatant(combatant) -> bool:
	if combatant == null or buneko == null:
		return false
	if combatant == buneko:
		return true
	return combatant.has_method("combat_position") and can_see_target(
		buneko.combat_position(),
		buneko.facing_direction(),
		combatant.combat_position()
	)

func _opponents_for(attacker) -> Array:
	return enemies if attacker == buneko else [buneko]

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
