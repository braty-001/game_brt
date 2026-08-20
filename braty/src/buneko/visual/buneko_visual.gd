class_name BunekoVisual
extends Node2D

const BlockKind = preload("res://src/programming/domain/block_kind.gd")
const SimpleParts = preload("res://src/buneko/visual/buneko_simple_parts.gd")

const PULSE_DURATION := 0.18

var _pulse_color := Color.TRANSPARENT
var _pulse_time_remaining := 0.0

func _ready() -> void:
	queue_redraw()

func _process(delta: float) -> void:
	if _pulse_time_remaining <= 0.0:
		return
	_pulse_time_remaining = maxf(0.0, _pulse_time_remaining - delta)
	queue_redraw()

func show_action_pulse(action_kind: int, refused := false) -> void:
	_pulse_color = Color("ef6a6a") if refused else _color_for_action(action_kind)
	_pulse_time_remaining = PULSE_DURATION
	queue_redraw()

func is_pulsing() -> bool:
	return _pulse_time_remaining > 0.0

func _draw() -> void:
	if is_pulsing():
		var intensity := _pulse_time_remaining / PULSE_DURATION
		var glow_color := Color(_pulse_color, 0.18 + intensity * 0.30)
		draw_circle(Vector2(0, -40), 34.0 + intensity * 8.0, glow_color)
	SimpleParts.draw_complete(self, Vector2.ZERO, 0.82)

func _color_for_action(action_kind: int) -> Color:
	match action_kind:
		BlockKind.Value.WALK:
			return Color("35d1c9")
		BlockKind.Value.RUN:
			return Color("f5c85d")
		BlockKind.Value.JUMP:
			return Color("8dd9ff")
		BlockKind.Value.TURN:
			return Color("9a7cff")
	return Color("f5c85d")
