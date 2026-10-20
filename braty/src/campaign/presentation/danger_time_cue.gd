class_name DangerTimeCue
extends RefCounted

const DURATION_MSEC := 500
const RETURN_MSEC := 150
const SLOW_FACTOR := 0.4

var was_visible := false
var started_msec := -1

func observe(enemy_visible: bool, now_msec: int) -> bool:
	var entered := enemy_visible and not was_visible
	was_visible = enemy_visible
	if entered:
		started_msec = now_msec
	return entered

func factor(now_msec: int) -> float:
	if started_msec < 0:
		return 1.0
	var elapsed := now_msec - started_msec
	if elapsed >= DURATION_MSEC:
		started_msec = -1
		return 1.0
	if elapsed <= DURATION_MSEC - RETURN_MSEC:
		return SLOW_FACTOR
	return lerpf(SLOW_FACTOR, 1.0, float(elapsed - (DURATION_MSEC - RETURN_MSEC)) / RETURN_MSEC)

func cancel() -> void:
	started_msec = -1

func reset() -> void:
	cancel()
	was_visible = false
