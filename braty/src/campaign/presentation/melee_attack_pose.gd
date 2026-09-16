extends RefCounted

const MeleeAttackScript = preload("res://src/campaign/combat/melee_attack.gd")

const DRAW_BACK_SECONDS := 0.12
const CONTACT_HOLD_SECONDS := 0.16

static func phase(actor) -> String:
	if actor == null or not actor.has_method("is_attack_busy") or not actor.is_attack_busy():
		return "idle"
	var elapsed: float = actor.attack_elapsed()
	if elapsed < MeleeAttackScript.WINDUP_SECONDS:
		return "windup"
	if elapsed < MeleeAttackScript.WINDUP_SECONDS + CONTACT_HOLD_SECONDS:
		return "strike"
	return "recovery"

static func baton_angle(actor, rest: float, raised: float, contact: float) -> float:
	if phase(actor) == "idle":
		return rest
	var elapsed: float = maxf(actor.attack_elapsed(), 0.0)
	if elapsed < DRAW_BACK_SECONDS:
		return lerpf(rest, raised, elapsed / DRAW_BACK_SECONDS)
	if elapsed < MeleeAttackScript.WINDUP_SECONDS:
		return lerpf(raised, contact, (elapsed - DRAW_BACK_SECONDS) / (MeleeAttackScript.WINDUP_SECONDS - DRAW_BACK_SECONDS))
	var recovery_start := MeleeAttackScript.WINDUP_SECONDS + CONTACT_HOLD_SECONDS
	if elapsed < recovery_start:
		return contact
	return lerpf(contact, rest, clampf((elapsed - recovery_start) / (MeleeAttackScript.CYCLE_SECONDS - recovery_start), 0.0, 1.0))
