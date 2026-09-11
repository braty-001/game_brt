class_name BatonPickup
extends Area2D

signal collected

var available := true

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	queue_redraw()

func consume() -> bool:
	if not available:
		return false
	available = false
	set_deferred("monitoring", false)
	hide()
	return true

func _on_body_entered(body: Node2D) -> void:
	if available and body.has_method("equip_baton"):
		collected.emit()

func _draw() -> void:
	draw_circle(Vector2.ZERO, 27, Color("244e4c"))
	draw_arc(Vector2.ZERO, 27, 0, TAU, 32, Color("57d6aa"), 3)
	draw_line(Vector2(-14, 15), Vector2(14, -15), Color("dab171"), 7)
	draw_circle(Vector2(16, -17), 5, Color("9e704d"))
