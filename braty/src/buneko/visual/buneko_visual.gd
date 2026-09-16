class_name BunekoVisual
extends Node2D

const BlockKind = preload("res://src/programming/domain/block_kind.gd")
const SimpleParts = preload("res://src/buneko/visual/buneko_simple_parts.gd")
const AttackPose = preload("res://src/campaign/presentation/melee_attack_pose.gd")

const PULSE_DURATION := 0.18
const DAMAGE_REACTION_SECONDS := 0.12
const LANDING_REACTION_SECONDS := 0.14

var _pulse_color := Color.TRANSPARENT
var _pulse_time_remaining := 0.0
var _damage_time_remaining := 0.0
var _landing_time_remaining := 0.0
var _movement_phase := 0.0
var _defeated := false
var _defeat_elapsed := 0.0
var _defeat_baton_angle := -0.82

func _ready() -> void:
	var buneko = get_parent()
	if buneko != null:
		if buneko.has_signal("damage_received"):
			buneko.damage_received.connect(_on_damage_received)
		if buneko.has_signal("landed"):
			buneko.landed.connect(_on_landed)
		if buneko.has_signal("defeated"):
			buneko.defeated.connect(_on_defeated)
	queue_redraw()

func _process(delta: float) -> void:
	_pulse_time_remaining = maxf(0.0, _pulse_time_remaining - delta)
	_damage_time_remaining = maxf(0.0, _damage_time_remaining - delta)
	_landing_time_remaining = maxf(0.0, _landing_time_remaining - delta)
	if _defeated:
		_defeat_elapsed += delta
	var buneko = get_parent()
	if buneko != null and buneko is CharacterBody2D and buneko.is_physics_processing():
		if buneko.is_on_floor() and absf(buneko.velocity.x) > 1.0:
			_movement_phase += delta * absf(buneko.velocity.x) * 0.045
	queue_redraw()

func show_action_pulse(action_kind: int, refused := false) -> void:
	_pulse_color = Color("ef6a6a") if refused else _color_for_action(action_kind)
	_pulse_time_remaining = PULSE_DURATION
	queue_redraw()

func is_pulsing() -> bool:
	return _pulse_time_remaining > 0.0

func _draw() -> void:
	var buneko = get_parent()
	var pose := _pose_for(buneko)
	draw_set_transform(pose.offset, pose.rotation, pose.scale)
	if is_pulsing():
		var intensity := _pulse_time_remaining / PULSE_DURATION
		var glow_color := Color(_pulse_color, 0.18 + intensity * 0.30)
		draw_circle(Vector2(0, -40), 34.0 + intensity * 8.0, glow_color)
	SimpleParts.draw_complete(self, Vector2.ZERO, 0.82)
	if buneko != null and buneko.has_method("has_baton") and buneko.has_baton():
		_draw_baton(buneko)
	if _damage_time_remaining > 0.0:
		var strength := _damage_time_remaining / DAMAGE_REACTION_SECONDS
		draw_circle(Vector2(0, -31), 38.0, Color(1.0, 0.35, 0.28, strength * 0.38))
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)

func presentation_snapshot() -> Dictionary:
	return {
		"attack_phase": _attack_phase(get_parent()),
		"baton_angle": _baton_angle(get_parent()),
		"damage_reacting": _damage_time_remaining > 0.0,
		"landing_reacting": _landing_time_remaining > 0.0,
		"defeated": _defeated,
	}

func _pose_for(buneko) -> Dictionary:
	var offset := Vector2.ZERO
	var rotation := 0.0
	var scale_factor := Vector2.ONE
	if _defeated:
		var progress := clampf(_defeat_elapsed / 0.45, 0.0, 1.0)
		rotation = progress * 1.45
		offset.y = progress * 18.0
		return {"offset": offset, "rotation": rotation, "scale": scale_factor}
	if buneko != null and buneko is CharacterBody2D:
		if not buneko.is_on_floor():
			scale_factor = Vector2(0.95, 1.06)
			offset.y = -2.0
		elif _landing_time_remaining > 0.0:
			var landing_strength := _landing_time_remaining / LANDING_REACTION_SECONDS
			scale_factor = Vector2(1.0 + landing_strength * 0.08, 1.0 - landing_strength * 0.12)
			offset.y = 4.0 * landing_strength
		elif absf(buneko.velocity.x) > 1.0:
			offset.y = sin(_movement_phase) * 2.0
			rotation = clampf(buneko.velocity.x / 160.0, -1.0, 1.0) * 0.045
		var attack_phase := _attack_phase(buneko)
		if attack_phase == "windup":
			rotation -= 0.06
			offset.x -= 2.0
		elif attack_phase == "strike":
			rotation += 0.10
			offset.x += 3.0
	if _damage_time_remaining > 0.0:
		var damage_strength := _damage_time_remaining / DAMAGE_REACTION_SECONDS
		offset.x -= 5.0 * damage_strength
	return {"offset": offset, "rotation": rotation, "scale": scale_factor}

func _draw_baton(buneko) -> void:
	var hand := Vector2(11, -31)
	var angle := _baton_angle(buneko)
	var tip := hand + Vector2.from_angle(angle) * 43.0
	draw_line(hand, tip, Color("dab171"), 6)
	draw_circle(tip, 4, Color("9e704d"))

func _baton_angle(buneko) -> float:
	if _defeated:
		return _defeat_baton_angle
	return AttackPose.baton_angle(buneko, -0.82, -1.75, 0.28)

func _attack_phase(buneko) -> String:
	return AttackPose.phase(buneko)

func _on_damage_received(actor, _amount: int) -> void:
	if not actor.is_alive():
		_defeat_baton_angle = _baton_angle(actor)
	_damage_time_remaining = DAMAGE_REACTION_SECONDS
	queue_redraw()

func _on_landed(_actor) -> void:
	_landing_time_remaining = LANDING_REACTION_SECONDS
	queue_redraw()

func _on_defeated() -> void:
	_defeated = true
	_defeat_elapsed = 0.0
	queue_redraw()

func _color_for_action(action_kind: int) -> Color:
	match action_kind:
		BlockKind.Value.WALK:
			return Color("35d1c9")
		BlockKind.Value.JUMP:
			return Color("8dd9ff")
		BlockKind.Value.TURN:
			return Color("9a7cff")
	return Color("f5c85d")
