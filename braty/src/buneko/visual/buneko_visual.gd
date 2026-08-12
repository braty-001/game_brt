class_name BunekoVisual
extends Node2D

const SimpleParts = preload("res://src/buneko/visual/buneko_simple_parts.gd")

func _ready() -> void:
	queue_redraw()

func _draw() -> void:
	SimpleParts.draw_complete(self, Vector2.ZERO, 0.82)
