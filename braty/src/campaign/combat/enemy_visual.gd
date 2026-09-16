class_name EnemyVisual
extends Node2D

const AttackPose = preload("res://src/campaign/presentation/melee_attack_pose.gd")

const DAMAGE_REACTION_SECONDS := 0.12
const AWARENESS_CUE_SECONDS := 0.35

var _damage_time_remaining := 0.0
var _awareness_time_remaining := 0.0
var _defeated := false
var _defeat_elapsed := 0.0
var _defeat_baton_angle := -0.76

func _ready() -> void:
	var enemy = get_parent()
	if enemy != null:
		if enemy.has_signal("damage_received"):
			enemy.damage_received.connect(_on_damage_received)
		if enemy.has_signal("awareness_changed"):
			enemy.awareness_changed.connect(_on_awareness_changed)
		if enemy.has_signal("defeated"):
			enemy.defeated.connect(_on_defeated)
	queue_redraw()

func _process(delta: float) -> void:
	_damage_time_remaining = maxf(0.0, _damage_time_remaining - delta)
	_awareness_time_remaining = maxf(0.0, _awareness_time_remaining - delta)
	if _defeated:
		_defeat_elapsed += delta
	queue_redraw()

func _draw() -> void:
	var enemy = get_parent()
	if enemy == null or not enemy.has_method("is_alive"):
		return
	var defeat_progress := clampf(_defeat_elapsed / 0.35, 0.0, 1.0) if _defeated else 0.0
	var offset := Vector2(0, defeat_progress * 15.0)
	var pose_rotation := defeat_progress * 1.45
	if not _defeated:
		var attack_phase := _attack_phase(enemy)
		if attack_phase == "windup":
			pose_rotation = -0.08
			offset.x = -2.0
		elif attack_phase == "strike":
			pose_rotation = 0.12
			offset.x = 3.0
	if _damage_time_remaining > 0.0:
		offset.x -= 5.0 * (_damage_time_remaining / DAMAGE_REACTION_SECONDS)
	draw_set_transform(offset, pose_rotation, Vector2.ONE)
	var body_color := Color("714a4d").darkened(defeat_progress * 0.55)
	var head_color := Color("cf756c").darkened(defeat_progress * 0.55)
	draw_circle(Vector2(0, -7), 13, head_color)
	draw_rect(Rect2(-13, 6, 26, 26), body_color)
	_draw_baton(enemy, Color("c9a56a").darkened(defeat_progress * 0.55))
	if not _defeated:
		draw_circle(Vector2(5, -9), 2.5, Color("fff1cb"))
		var ratio: float = float(enemy.current_health()) / float(enemy.health_capacity())
		draw_rect(Rect2(-18, -30, 36, 5), Color("321f24"))
		draw_rect(Rect2(-18, -30, 36 * ratio, 5), Color("e66c68"))
	if _awareness_time_remaining > 0.0 and enemy.is_alive():
		var cue_strength := _awareness_time_remaining / AWARENESS_CUE_SECONDS
		draw_circle(Vector2(0, -43), 5.0 + cue_strength * 2.0, Color(1.0, 0.78, 0.3, 0.55 + cue_strength * 0.35))
	if _damage_time_remaining > 0.0:
		var damage_strength := _damage_time_remaining / DAMAGE_REACTION_SECONDS
		draw_circle(Vector2.ZERO, 28.0, Color(1.0, 0.32, 0.25, damage_strength * 0.45))
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)

func presentation_snapshot() -> Dictionary:
	return {
		"attack_phase": _attack_phase(get_parent()),
		"baton_angle": _baton_angle(get_parent()),
		"damage_reacting": _damage_time_remaining > 0.0,
		"awareness_cue": _awareness_time_remaining > 0.0,
		"defeated": _defeated,
	}

func _draw_baton(enemy, baton_color: Color) -> void:
	var hand := Vector2(8, 7)
	var angle := _baton_angle(enemy)
	var tip := hand + Vector2.from_angle(angle) * 44.0
	draw_line(hand, tip, baton_color, 5)
	draw_circle(tip, 3.5, Color("9e704d"))

func _baton_angle(enemy) -> float:
	if _defeated:
		return _defeat_baton_angle
	return AttackPose.baton_angle(enemy, -0.76, -1.72, 0.3)

func _attack_phase(enemy) -> String:
	return AttackPose.phase(enemy)

func _on_damage_received(actor, _amount: int) -> void:
	if not actor.is_alive():
		_defeat_baton_angle = _baton_angle(actor)
	_damage_time_remaining = DAMAGE_REACTION_SECONDS

func _on_awareness_changed(_actor, visible: bool) -> void:
	if visible:
		_awareness_time_remaining = AWARENESS_CUE_SECONDS

func _on_defeated(_enemy) -> void:
	_defeated = true
	_defeat_elapsed = 0.0
