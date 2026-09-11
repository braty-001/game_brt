class_name MeleeAttack
extends RefCounted

const DAMAGE := 2
const REACH_BEYOND_BODY := 48.0
const MAX_CENTER_DISTANCE := 80.0
const VERTICAL_RANGE := 48.0
const WINDUP_SECONDS := 0.2
const CYCLE_SECONDS := 0.8

var equipped := false
var busy := false
var elapsed := 0.0
var _strike_emitted := false

func equip() -> void:
	equipped = true

func begin() -> bool:
	if not equipped or busy:
		return false
	busy = true
	elapsed = 0.0
	_strike_emitted = false
	return true

func advance(delta: float) -> bool:
	if not busy:
		return false
	elapsed += maxf(delta, 0.0)
	var strikes_now := not _strike_emitted and elapsed >= WINDUP_SECONDS
	if strikes_now:
		_strike_emitted = true
	if elapsed >= CYCLE_SECONDS:
		busy = false
	return strikes_now

func reset() -> void:
	busy = false
	elapsed = 0.0
	_strike_emitted = false

static func can_reach(attacker: Vector2, direction: int, target: Vector2) -> bool:
	var forward := (target.x - attacker.x) * direction
	return forward >= 0.0 and forward <= MAX_CENTER_DISTANCE and absf(target.y - attacker.y) <= VERTICAL_RANGE
